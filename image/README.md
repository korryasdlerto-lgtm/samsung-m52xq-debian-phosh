# Release image

[`build-release.sh`](build-release.sh) makes the root image and the zip of the release from the minimal release root and
the rebuilt packages.

- Root: ext4 3420 MiB, label `pmOS_root` (the pmOS initramfs of the boot image looks for it), about 217 MiB free for the
  firmware the installer copies from the phone; md5 of the v1 image `ee110da2fa832872976769a3eacbc9f2`.
- Two equal chunks `data/rootfs-chunks/samsung-m52xq.img.part-0/1`; the installer checks that their sum fits into
  `system` before writing anything.
- `/etc/fstab` must not be empty (`proc /proc proc defaults 0 0`): with only comments in it the pmOS initramfs waits for a
  `pmOS_boot` partition and ends in its debug shell.
- Packages of the image: [`../docs/packages-debian.txt`](../docs/packages-debian.txt) (33 of ours on `apt-mark hold`).
