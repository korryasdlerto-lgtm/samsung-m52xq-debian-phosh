# samsung-m52xq-debian-phosh

**Debian forky (testing) + Mobian + Phosh** on a **mainline Linux kernel** for the
**Samsung Galaxy M52 5G** (codename `m52xq`, SM-M526B / SM-M526BR, Qualcomm Snapdragon 778G / SM7325, platform "yupik").

It is not Halium, not libhybris and not the Android kernel. The phone runs a mainline Linux 7.1.13 kernel with device drivers
and fixes, and a real Debian forky arm64 root with the Mobian repository, systemd and Phosh 0.58. The hardware layer (kernel,
`m52xq-*` services) is the same as in the sister ports
[samsung-m52xq-postmarketos-phosh](https://github.com/korryasdlerto-lgtm/samsung-m52xq-postmarketos-phosh),
[samsung-m52xq-mainline](https://github.com/korryasdlerto-lgtm/samsung-m52xq-mainline) (Plasma Mobile) and
[samsung-m52xq-ubuntu-lomiri](https://github.com/korryasdlerto-lgtm/samsung-m52xq-ubuntu-lomiri), rebuilt for Debian.
Personal, unofficial project (not a Debian or Mobian release), tested on one SM-M526B.

**Status (release "unofficial v1", 2026-11-20, see [changes](docs/CHANGES-v1.md) / [на русском](docs/CHANGES-v1-RU.md)):
usable, but not yet ready as your only phone.** It has calls, SMS and mobile data on two SIMs, Wi-Fi, Bluetooth, a
GPU-accelerated Phosh, sound, GPS, sensors, all four cameras with 64 MP photos and hardware-encoded 4K video, Telegram with
voice calls, and deep sleep that wakes for calls, SMS and alarms.

## Repositories

| | |
|---|---|
| This repository | installer, rootfs overlay (scripts, services, configs), patches and build scripts of the rebuilt Debian packages, image build script, device tree, kernel config and patches, documentation |
| Kernel source | [sc7280-mainline-linux-m52xq](https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq); the patches of this release on top of it are in [`kernel/patches/`](kernel/patches) |
| Kernel binaries | boot.img, vendor_boot.img and dtbo of this release are inside the flashable zip (`firmware/`) |
| XDA thread | [[ROM][UNOFFICIAL][Debian][Mobian][Phosh] Mainline Linux 7.1 for Galaxy M52 5G](https://xdaforums.com/t/rom-unofficial-debian-mobian-phosh-mainline-linux-7-1-for-galaxy-m52-5g-sm-m526b.4809580/) |

## What works

| Feature | Status | Notes |
|---|---|---|
| Boot, UFS storage | works | `system` grown to 8 GB by the installer; `/home` on the userdata partition (about 100 GB) |
| Display | works | Samsung S6E3HAB AMOLED, brightness, auto-rotation; the panel stays dark on network wake-ups |
| GPU (Adreno 642L) | works | Mesa freedreno, Phosh/phoc composited on the GPU |
| Touchscreen, keyboard | works | Synaptics; Phosh on-screen keyboard |
| Wi-Fi, Bluetooth, BT audio | works | WCN6750 / ath11k; Bluetooth address from the phone's EFS |
| Calls, SMS, mobile data | works | **dual SIM** (DSDS, both active, "SIM 1 / SIM 2" in Phosh, GNOME Calls and Chatty); hold, second call, swap, speaker/earpiece, dial pad in landscape; mobile data is a manual connection ("Mobile data", APN `internet`, IPv4) |
| Audio | works | loudspeaker (TFA9878), earpiece, microphones, in-call noise suppression, USB audio, notification sounds |
| GPS | works | ModemManager GNSS, GeoClue |
| Sensors | works | light, proximity (screen off at the ear in calls), accelerometer (auto-rotation) |
| Battery, charging | works | SM5714 fuel gauge and charger |
| Suspend | works | s2idle; wakes for calls, SMS and alarms (RTC); the screen stays off on network wake-ups |
| Camera | works, partial | GNOME Snapshot with all four cameras (Main 64 MP, Front 32 MP, Wide, Macro), **64 MP / 32 MP photos**, tap to focus, zoom, **video with the hardware encoder (Venus), up to 4K**; image processing in software |
| Telegram | works | Telegram Desktop preinstalled: messages with sound, **voice calls** (earpiece, "Speakerphone" tile in the shade, screen off at the ear, the call wakes the phone), camera through virtual webcams |
| Web | works | Firefox ESR with the mobile configuration |
| Quick settings | works | own tiles: SIM 1 / SIM 2, rotation, **NFC** (on/off), **Speakerphone** (sound of a Telegram call: earpiece, loud speaker, headsets) |
| NFC | partial | the chip is detected and can be switched on/off; no NFC application in the image |
| Fingerprint | no | |
| VoLTE | no | calls use 2G/3G |

### Known issues

- **Sensors after many hours of sleep:** the FastRPC link to the audio DSP runs out of memory ("No space left on device"):
  auto-rotation, proximity and light stop until a reboot.
- **Wi-Fi after a resume:** rarely the Wi-Fi firmware (WPSS) crashes on resume; switch Wi-Fi off and on, or reboot. In a
  long uninterrupted sleep a Wi-Fi packet may not wake the phone: Telegram messages then arrive after the power button.
- **Sleep with Telegram:** Telegram keeps its connections alive, the phone wakes about once a minute (about 2.5 % battery
  per hour). The audio DSP does not sleep yet.
- **Camera image quality:** the viewfinder and videos are processed by the libcamera software ISP: in dim light they look
  hazy and noisy; 64 MP / 32 MP photos are developed by an own GPU pipeline and look better. 4K at a high bitrate may drop
  to about 20 fps.
- **Telegram settings:** turn off "Draw attention to the window" (otherwise every message brings the window to the front
  and no sound plays) and turn on "Close to taskbar" (otherwise closing the window quits Telegram and calls no longer arrive).
  With Telegram's own message sound on, a message may turn the display on (it is taken for a call).
- **Wi-Fi after the router vanished during sleep:** the Wi-Fi firmware may crash on the wake-up; a reboot brings Wi-Fi and
  Bluetooth back.
- **Mobile data and sleep:** with mobile data on the modem wakes the phone every 8–12 s; sleep is much better with it off.
- **Wallpaper** fills only the upper half of the screen (the Debian theme XML has no portrait picture choice for Phosh).

## Install

Requirements: unlocked bootloader, TWRP for m52xq
(<https://github.com/saadelasfur/Action-Recovery-Builder/releases/tag/20261004173308>), the zip on the phone's `/data`
(adb push in TWRP) or on a microSD card, backups of EFS, persist, modem, boot, vendor_boot and vbmeta. If you are not
comfortable restoring a Samsung phone with Odin, do not install this.

- Video guide: <https://www.youtube.com/watch?v=UUmmVd8_14Y>
- Flashable zip (1.05 GB): [debian-mobian-phosh-m52xq-mainline-v1.zip](https://drive.google.com/file/d/1XqeCf2KN9WavcbCDK4oOFNDQlPdOteY5/view?usp=sharing), md5 `7494cc8cb04a9db69ed78072a39d2712`

The phone gets warm during the install. If your display already shows vertical coloured lines, do not install this: the
heat may make them worse.

Flash **UN1CA_3.1.0** first to get the maximum system partition size (the installer grows `system` to 8 000 000 000 bytes).
After LineageOS 23 the partition is 1 GB smaller, but the install still works.

TWRP steps:

```
Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - Select Storage - Micro SD card - debian-mobian-phosh-m52xq-mainline-v1.zip - Swipe to confirm Flash - Reboot System
```

The install takes a few minutes; wait for `Updater process ended with RC=0`. The first boot takes longer.

The installer checks that the root image fits into `system`, writes boot, vendor_boot and dtbo, writes the root image,
puts the `m52xq-*` overlay over it, enables the device services and moves `/home` to the userdata partition. The
Samsung/Qualcomm device firmware is **not** in the zip: the installer copies it, read-only, from the phone's own partitions.
ADSP, GPU zap shader, IPA (mobile data) and Venus come from `apnhlos`. Bluetooth firmware and sensor configs come from
`vendor`, the modem from `modem`, the sensor registry from `persist` and the Bluetooth address from `EFS`. The IPA firmware
is added to the boot ramdisk, because the built-in IPA driver needs it before the root is mounted. `vendor` must come from
a Samsung-based ROM (stock, UN1CA or LineageOS). SSH host keys and the machine ID are created on the first boot.

- Default password (screen unlock, `user` and `root`): `1111`. Change it with `passwd` in the Console app.
- SSH over USB (about 30 s after boot): `ssh root@172.16.42.1` (password `1111`).
- Screenshot: press **Volume Up + Volume Down** at the same time; the picture goes to `~/Pictures/Screenshots`.
- Reboot into recovery: app "Reboot menu" - "Reboot into recovery".

### Back to Android

Video guide: <https://www.youtube.com/watch?v=0lgLbtdl4rA>

Enter TWRP (app "Reboot menu" - "Reboot into recovery", or the power and volume button combination). Copy the firmware zip to
the microSD card first. The LineageOS and UN1CA zips rewrite boot, vendor_boot and dtbo themselves.

```
Wipe - Format Data - yes - enter - Back - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - lineage-23.2-2026-nightly-m52xq-signed.zip - Back - Back - Wipe - Format Data - enter - Reboot System
```

Latest LineageOS build: <https://download.lineageos.org/devices/m52xq/builds>. Stock firmware can always be restored with
Odin or Heimdall (BL, AP, CP, CSC).

## Repository layout

| Path | Content |
|---|---|
| `installer/` | `META-INF/.../update-binary` of the flashable zip (TWRP shell installer) |
| `rootfs-overlay/` | our files over the Debian root: `m52xq-*` scripts and services, system-sleep hooks, systemd drop-ins, udev and polkit rules, WirePlumber / ModemManager / NetworkManager configs, UCM, GSettings overrides, libcamera tuning, Mobian apt source. Binaries (kernel modules, libssc, firmware) are not here: see `rootfs-overlay/EXCLUDED-FILES.txt` (path, size, md5) |
| `build/` | patches and build scripts of every rebuilt Debian package (table below) |
| `kernel/` | kernel config (`config-7.1.13`) and `patches/` on top of the kernel repository |
| `device-tree/` | `sm7325-samsung-m52xq.dts` (upstream-style) and `sm7325-samsung-m52xq-local.dts` (local additions, RTC enabled): the DTB in vendor_boot of this release |
| `image/` | `build-release.sh` (root image and zip) and notes on the release image |
| `docs/` | manuals (EN/RU), change list of v1, list of the packages in the image |

### Rebuilt packages (`build/`)

Each one is the Debian (or Mobian) source package with our patches added to `debian/patches`, a `+m52xqN` version and
`apt-mark hold` in the image. The scripts run `dpkg-buildpackage` in an arm64 Debian forky chroot (qemu).

| Folder | What and why |
|---|---|
| `phosh` | Phosh 0.58 + dual-SIM indicators and tiles (empty slot hidden), rotation tile, auto-rotation that recovers by itself, hold / add call on the lock screen; patch 0003: NFC and Speakerphone quick setting plugins |
| `phosh-mobile-settings` | keeps the on/off switch of the Bluetooth and Wi-Fi panels |
| `calls` | GNOME Calls 51.1 + patches 0001–0013 (hold, "Add call" on the same SIM, second call, swap, SIM in the history, the call window comes to the front, no hang-up when the window is hidden, landscape call display) and the landscape dial pad |
| `chatty` | Chatty 0.8.9 + SMS on both SIMs and chat actions |
| `modemmanager` | ModemManager 1.24.2 + patches 0100–0106: dual SIM (DSDS) with two modem objects on QRTR, data SIM, netlink use-after-free fix, always power up; 0107: backport from 1.25 — no abort on suspend with mobile data on (IPA modem: multiplexed bearers counted) |
| `network-manager` | NetworkManager 1.58.1 + an option to ignore the logind sleep signal (`/etc/NetworkManager/m52xq-ignore-suspend`): apps no longer see every phone suspend as a network loss |
| `libcamera` | libcamera 0.8.0 + patches: soft-ISP output sizes, quad-Bayer CFA, sensor info on configure, NV12 output of the GPU debayer, pipeline links without the cached flags, faster auto exposure |
| `pipewire` | PipeWire 1.6.9 rebuilt against libcamera 0.8 (renamed camera location properties) |
| `snapshot` | GNOME Snapshot 51 + the camera patch of the postmarketOS port (rotation, all four cameras, tap to focus, zoom, 64 MP photos through `m52xq-rawphoto`, Venus video up to 4K) and 0002 (photos of the back cameras are not turned) |
| `m52xq-rawphoto` | own helper: raw 64 MP / 32 MP capture through libcamera and development on the GPU |
| `libssc` | libssc 0.4.4 (not in Debian) + proximity sensor fixes and a report dump (used by the in-call proximity service) |

`build/build-r2-all.sh` builds phosh, phosh-mobile-settings, gnome-calls and chatty in one queue. The `.deb` packages
themselves are not in the repository.

## Building

- Kernel: see [`kernel/README.md`](kernel/README.md) (`make ARCH=arm64 LLVM=1 Image` with clang/LLD 22 using
  `kernel/config-7.1.13` and `kernel/patches/`). `MODVERSIONS` is off: use the modules only with the same Image.
- Root from scratch: debootstrap Debian forky arm64, the Mobian repository (`rootfs-overlay/etc/apt/`), Phosh and the
  hardware packages, then the packages of `build/` and the overlay.
- Release image and zip: [`image/build-release.sh`](image/build-release.sh), see [`image/README.md`](image/README.md).

## Manuals

| Language | Markdown |
|---|---|
| English | [docs/MANUAL-EN.md](docs/MANUAL-EN.md) |
| Русский | [docs/MANUAL-RU.md](docs/MANUAL-RU.md) |


## Bug reports

Please write in the [XDA thread](https://xdaforums.com/t/rom-unofficial-debian-mobian-phosh-mainline-linux-7-1-for-galaxy-m52-5g-sm-m526b.4809580/): your model (SM-M526B / SM-M526BR), what you did and what happened. Logs help a lot: `journalctl -b` and
`dmesg` over SSH or in the Console app.

## Credits

Debian and the Mobian project, the Phosh and GNOME developers (Phosh, phoc, Calls, Chatty, Snapshot), libcamera, PipeWire,
ModemManager, NetworkManager, postmarketOS (initramfs, reference packages), the mainline Linux developers for Qualcomm
SC7280 / QCM6490 (Fairphone 5 and others), LineageOS (device and kernel sources used as reference), the TWRP maintainers for
m52xq.

## License

Kernel code: GPL-2.0 (see the kernel repository). Patches follow the license of the patched project. Scripts and
documentation in this repository: GPL-2.0.
