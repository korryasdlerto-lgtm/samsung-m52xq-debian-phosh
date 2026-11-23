#!/bin/sh
# Release root image and zip of the Debian (Mobian) + Phosh port, as done for unofficial v1. Run as root on the build PC (x86_64 with qemu-user-static / binfmt for arm64).
#   BASE  - the minimal release root (rootfs-release: working root with build packages, apt cache, logs, SSH keys,
#           machine-id and the phone's own firmware/data removed)
#   DEBS  - folder with the rebuilt .deb packages (build/*: phosh, calls, chatty, libcamera, PipeWire, Snapshot, NM, ...)
#   ZIPD  - zip folder: META-INF (../installer), firmware/ (boot, vendor_boot, dtbo-frag), mainline-extras/rootfs-files
#           (../rootfs-overlay files the installer copies + the binaries of EXCLUDED-FILES.txt), data/rootfs-chunks/
set -e
BASE=$1; DEBS=$2; ZIPD=$3; OUT=$4
[ -d "$BASE/etc" ] && [ -d "$DEBS" ] && [ -d "$ZIPD/META-INF" ] && [ -n "$OUT" ] || { echo "usage: $0 BASE DEBS ZIPD OUT.zip"; exit 1; }
R=$BASE-new; W=$(mktemp -d)
cp -a "$BASE" "$R"
# 1. rebuilt packages into the root, kept by apt-mark hold
mkdir "$R/root/debs"; cp "$DEBS"/*.deb "$R/root/debs/"
mount --bind /dev "$R/dev"; mount -t proc proc "$R/proc"; mount -t sysfs sys "$R/sys"
chroot "$R" sh -c 'cd /root/debs && apt-get -s install ./*.deb | grep -E "^(Inst|Remv)"; LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y ./*.deb &&
  for d in ./*.deb; do dpkg-deb -f "$d" Package; done | xargs apt-mark hold && dpkg --audit'
rm -rf "$R/root/debs" "$R"/var/cache/apt/*.bin "$R"/var/cache/apt/archives/*.deb
umount "$R/sys" "$R/proc" "$R/dev"
# 2. no SSH host keys, empty machine-id (created on the first boot by m52xq-ssh-hostkeys.service / systemd)
rm -f "$R"/etc/ssh/ssh_host_*; : > "$R/etc/machine-id"
# 3. ext4 image with ~200 MB free for the firmware the installer copies from the phone
truncate -s 3420M "$W/root.img"
mkfs.ext4 -q -F -L pmOS_root -O ^metadata_csum_seed -i 16384 "$W/root.img"
mkdir "$W/mnt"; mount -o loop "$W/root.img" "$W/mnt"
rsync -aHAXx --numeric-ids --exclude=/usr/bin/qemu-aarch64-static "$R/" "$W/mnt/"
df -m "$W/mnt"; umount "$W/mnt"; e2fsck -fn "$W/root.img"; md5sum "$W/root.img"
# 4. two equal chunks, zip -9 from inside the folder (no folder prefix), no dangling symlinks
rm -f "$ZIPD"/data/rootfs-chunks/samsung-m52xq.img.part-*
split -n 2 -d -a 1 "$W/root.img" "$ZIPD/data/rootfs-chunks/samsung-m52xq.img.part-"
[ -z "$(find "$ZIPD" -xtype l)" ] || { echo "dangling symlinks"; exit 2; }
( cd "$ZIPD" && zip -9 -r -q "$OUT" . -x 'test-images/*' -x 'packages/*' -x 'patches/*' )
unzip -tq "$OUT"; md5sum "$OUT"
