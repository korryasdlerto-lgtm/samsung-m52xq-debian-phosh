# Debian (Mobian) + Phosh on a mainline kernel for the Samsung Galaxy M52 5G (m52xq) — full manual

Release "unofficial v1", 2026-11-20. Russian version: [MANUAL-RU.md](MANUAL-RU.md).

## 1. What this is

Debian forky (testing) arm64 with the Mobian repository, systemd and Phosh 0.58 on a mainline Linux 7.1.13 kernel for the
Samsung Galaxy M52 5G (SM-M526B / SM-M526BR, Snapdragon 778G / SM7325 "yupik"). No Halium, no libhybris, no Android kernel
or Android services. The kernel, device tree and `m52xq-*` services are shared with the postmarketOS Phosh, Plasma Mobile
and Ubuntu Lomiri ports of the same phone. The boot image uses the postmarketOS initramfs, which mounts the Debian root from
the `system` partition. Personal, unofficial project; tested on one SM-M526B.

## 2. What works

See the table in the [README](../README.md#what-works). In short: calls, SMS and mobile data on two SIMs, Wi-Fi, Bluetooth
(with audio), GPS, sensors, sound, a GPU-accelerated Phosh, all four cameras (64 MP photos, Venus video up to 4K), Telegram
with voice calls, deep sleep with wake-ups for calls, SMS and alarms. Not working: fingerprint, VoLTE.

Known issues are listed in the README as well: sensors stop after many hours of sleep, rare Wi-Fi firmware crash on
resume, Wi-Fi may not wake the phone in a long sleep, about 2.5 %/h in sleep with Telegram, camera image quality in dim light.

## 3. Requirements

- Unlocked bootloader (OEM unlock), TWRP for m52xq:
  <https://github.com/saadelasfur/Action-Recovery-Builder/releases/tag/20261004173308>.
- Backups of EFS, persist, modem, boot, vendor_boot and vbmeta (TWRP Backup) and the stock firmware for Odin.
- A Samsung-based ROM installed before (stock, UN1CA or LineageOS): the installer copies the device firmware from its
  `vendor`, `apnhlos`, `modem`, `persist` and `efs` partitions. UN1CA_3.1.0 gives the largest `system` partition.

## 4. Installation

### 4.1. Flashable zip (TWRP)

Video guide: <https://www.youtube.com/watch?v=UUmmVd8_14Y>

1. Copy [debian-mobian-phosh-m52xq-mainline-v1.zip](https://drive.google.com/file/d/1XqeCf2KN9WavcbCDK4oOFNDQlPdOteY5/view?usp=sharing) (md5 `7494cc8cb04a9db69ed78072a39d2712`) to the microSD card
   (or `adb push` it to `/data` after Format Data in TWRP).
2. In TWRP:

```
Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - Select Storage - Micro SD card - debian-mobian-phosh-m52xq-mainline-v1.zip - Swipe to confirm Flash - Reboot System
```

3. Wait for `Updater process ended with RC=0`. The first boot takes longer.

What the installer does: grows `system` to 8 000 000 000 bytes in the LP metadata, checks that the root image fits,
writes the image from its two chunks, writes boot, vendor_boot and dtbo, copies the device firmware from the phone's own
partitions (read-only), adds the IPA firmware to the boot ramdisk, sets up the sensor registry for the ADSP, puts the
`m52xq-*` overlay (`mainline-extras/rootfs-files`) over the root, enables the services and sets up `/home` on the userdata
partition.

The phone gets warm during the install. If the display already shows vertical coloured lines, do not install: the heat may
make them worse.

### 4.2. Password and access

- Default password (screen unlock, `user`, `root`): `1111`. Change it with `passwd` in the Console app.
- SSH over USB (RNDIS, about 30 s after boot): `ssh root@172.16.42.1`, password `1111`.
- Screenshot: Volume Up + Volume Down, saved to `~/Pictures/Screenshots`.
- "Reboot menu" app: reboot, reboot into recovery (TWRP), power off.
- "SIM cards manager" app (`m52xq-sim-manager`): both SIMs / only SIM 1 / only SIM 2, data SIM, SIM cards and modem radio off.
- Mobile data: the data tile in the Phosh quick settings or Settings - Mobile Network (connection "Mobile data", APN
  `internet`; change the APN there if your operator needs another one).
- Telegram: in its settings turn off "Draw attention to the window" and turn on "Close to taskbar". The "Speakerphone" app
  switches a Telegram call between the earpiece and the loudspeaker.

### 4.3. Updates

`apt update && apt upgrade` works with the Debian and Mobian repositories. Our 33 rebuilt packages are on `apt-mark hold`
(`apt-mark showhold`): do not unhold them, or calls, dual SIM, the camera and sleep break. Plain Debian packages that pull
another Phosh, ModemManager, libcamera or PipeWire should be checked with `apt-get -s` first.

## 5. Going back to Android

Video guide: <https://www.youtube.com/watch?v=0lgLbtdl4rA>

Enter TWRP ("Reboot menu" - "Reboot into recovery", or power + volume keys). Copy the ROM zip to the microSD card first.

```
Wipe - Format Data - yes - enter - Back - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - lineage-23.2-2026-nightly-m52xq-signed.zip - Back - Back - Wipe - Format Data - enter - Reboot System
```

The LineageOS and UN1CA zips rewrite boot, vendor_boot and dtbo themselves. Stock firmware: Odin or Heimdall (BL, AP, CP, CSC).

## 6. Kernel

Mainline Linux 7.1.13, source <https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq>, config and the
patches of this release in [`../kernel/`](../kernel/README.md). The boot, vendor_boot and dtbo images are in the zip
(`firmware/`). The DTB comes from [`../device-tree/`](../device-tree).

## 7. Building from scratch

1. Root: `debootstrap --arch=arm64 forky` with qemu-user-static, the Mobian repository and key
   ([`../rootfs-overlay/etc/apt/`](../rootfs-overlay/etc/apt)), Phosh, phrog (login), GNOME apps, the hardware packages
   (rmtfs, pd-mapper, tqftpserv, qrtr, hexagonrpcd, iio-sensor-proxy, ModemManager, alsa-ucm), user `user` with UID 10000.
2. Rebuilt packages: the folders of [`../build/`](../build) in an arm64 build chroot (a copy of the root with the build
   dependencies): `apt-get source` + our patches in `debian/patches` + `dch` + `dpkg-buildpackage -B`. Order: libcamera →
   PipeWire (needs libcamera-dev 0.8) → Snapshot and m52xq-rawphoto; phosh / phosh-mobile-settings / gnome-calls / chatty
   with `build-r2-all.sh`; modemmanager, network-manager, libssc separately. Under qemu use `parallel=8` at most (16 hung the
   build PC); `dpkg-buildpackage -nc` resumes a stopped build (remove `debian/debhelper-build-stamp` to force a new binary).
3. Install the packages into the root (`apt-get install ./*.deb`, then `apt-mark hold`) and put [`../rootfs-overlay/`](../rootfs-overlay)
   over it (text files here, binaries listed in `EXCLUDED-FILES.txt`).
4. Minimal release root: purge the build packages, remove apt cache and lists, logs, SSH host keys, machine-id and the
   phone's own firmware and data.
5. Image and zip: [`../image/build-release.sh`](../image/build-release.sh) (ext4 3420 MiB with about 200 MB free, two
   chunks, `zip -9` from inside the folder).
6. Zip folder layout: `META-INF/` ([`../installer/`](../installer)), `firmware/` (boot, vendor_boot, dtbo-frag),
   `mainline-extras/rootfs-files/` (files the installer copies over the image), `data/rootfs-chunks/`.

## 8. Repository layout

See the [README](../README.md#repository-layout).

## 9. Rebuilt packages (`build/`)

See the [README](../README.md#rebuilt-packages-build).

## 10. Services and scripts (overlay)

| Name | What it does |
|---|---|
| `m52xq-adsp-start`, `m52xq-audio-reprobe`, `m52xq-audio-rescue` | start the ADSP once the firmware is on the root; bring the sound card up after the ADSP start race |
| `m52xq-modem-setup`, `m52xq-sim-mode*`, `m52xq-dds`, `m52xq-nas-mode`, `m52xq-flight-mode` | modem session and GNSS setup, SIM mode (both / SIM 1 / SIM 2), data SIM, network modes, cellular flight mode |
| `m52xq-voicecall`, `m52xq-callaudiod`, `m52xq-voice-mixers.sh`, `m52xq-usb-call-bridge` | modem voice path for a call (q6voice + codec mixers), CallAudio D-Bus API for Calls, USB headset bridge |
| `m52xq-tfa-guard` | re-opens the loudspeaker if the TFA9878 amplifier setup fails |
| `m52xq-tg-stream`, `m52xq-voip-audio`, `m52xq-audio-route`, `m52xq-speakerphone` | Telegram calls: find its stream by the PulseAudio client, earpiece / loudspeaker / headsets, the microphone instead of a monitor source |
| `m52xq-incall-proximity` | screen off and touch locked at the ear in calls (modem and Telegram) |
| `m52xq-idle-suspend` | own idle suspend (no suspend while an app inhibits idle or a Telegram call is on) |
| system-sleep hooks | dark resume (panel stays dark on network wake-ups), GPS pause, modem 2G in sleep, keep Wi-Fi, UFS power level, cameras off, fewer self-caused wake-ups |
| `m52xq-wake-restore`, `m52xq-bt-restore` | give back Bluetooth, network modes and GPS when the user is really there |
| `m52xq-wow-params`, `m52xq-wpss-guard`, `m52xq-wpss-restart` | Wi-Fi wake-on-LAN flags, WPSS crash-loop guard and cold restart |
| `m52xq-bt-firmware`, `m52xq-bt-addr.py` | Bluetooth firmware reload, the phone's own BD address |
| `m52xq-sensor-kick` | starts iio-sensor-proxy again once the ADSP sensors are up (auto-rotation) |
| `m52xq-virtualcam` | virtual V4L2 webcams (libcamera to v4l2loopback) for Telegram and browsers |
| `m52xq-home-on-userdata` | `/home` on the userdata partition |
| `m52xq-vol-screenshot`, `m52xq-reboot-menu`, `m52xq-sim-manager` | screenshot keys, reboot menu, SIM cards app |
| `m52xq-backlight-min` | no almost-black brightness after a reboot from a dimmed screen |

## 11. Pitfalls (short)

- `/etc/fstab` must not be empty: the pmOS initramfs then waits for a `pmOS_boot` partition and ends in its debug shell.
- The loudspeaker (TFA9878) stays silent in S24_LE: PipeWire opens the card in S16LE (`51-m52xq-s16.conf`), the microphone too
  (otherwise Telegram calls get noise).
- ModemManager needs `--test-quick-suspend-resume`, otherwise the QRTR modem is lost after a suspend.
- Debian's telegram-desktop streams carry no `application.*` properties: only its PulseAudio client does. Every Telegram
  detection goes through the client.
- With `GIO_USE_NETWORK_MONITOR=base` Telegram on Debian stays "offline"; `netlink` works.
- libcamera 0.8 renames its library (`libcamera0.8`) and the camera location properties: PipeWire must be rebuilt.
- `MODVERSIONS` is off: kernel modules only with the same Image.

## 12. Credits

Debian and Mobian, Phosh / phoc / GNOME (Calls, Chatty, Snapshot), libcamera, PipeWire, ModemManager, NetworkManager,
postmarketOS, the mainline Linux developers for Qualcomm SC7280 / QCM6490, LineageOS (reference sources), the TWRP
maintainers for m52xq.
