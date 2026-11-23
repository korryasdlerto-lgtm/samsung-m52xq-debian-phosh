# Unofficial v1 (first public release)

Audience: users of the port and developers who want to know what is in the first public release of Debian (Mobian) +
Phosh for the Samsung Galaxy M52 5G and why.

| | |
|---|---|
| Kernel | 7.1.13, the same build as the postmarketOS Phosh port: q6voice in-place device switch, panel sleep at brightness 0, ath11k radio-off power save, GPI shared-SE read fix, Venus HFI 6xx QP/bitrate (`kernel/patches/`) |
| Device tree | DTB from the upstream-style `sm7325-samsung-m52xq.dts` + local nodes, RTC enabled; `snd_usb_audio.index=-2` (`device-tree/`) |
| Root | Debian forky arm64 + Mobian, systemd, Phosh 0.58, 1039 packages ([packages-debian.txt](packages-debian.txt)), 33 of ours on hold |
| Image | clean image: no personal data, keys or proprietary firmware, ext4 3420 MiB, 2 chunks |
| Zip | `debian-mobian-phosh-m52xq-mainline-v1.zip` (1.05 GB), md5 `7494cc8cb04a9db69ed78072a39d2712` |

A clean install is required: Format Data as described in the README.

## Installer and image

- **No proprietary firmware in the zip.** ADSP, modem, IPA, Venus, GPU zap shader, Bluetooth firmware, sensor configs and
  the sensor registry are copied from the phone's own partitions during the install.
- The installer grows `system` to 8 GB, checks that the image fits before writing anything, writes boot, vendor_boot and
  dtbo.
- `/home` lives on the userdata partition (`m52xq-home-on-userdata`): about 100 GB for photos and videos.
- SSH host keys and the machine ID are created on the first boot; the Bluetooth address is read from EFS.
- `/etc/fstab` has a `proc` line: with an empty fstab the pmOS initramfs waited for a boot partition and stopped in its debug
  shell.

## Calls, SMS, mobile data

- **Dual SIM (DSDS)** in ModemManager (patches 0100–0106): both SIMs active, a second modem object for SIM 2, data SIM,
  "SIM 1 / SIM 2" in Phosh, Calls and Chatty, the tile of an empty slot hidden; "SIM cards manager" app.
- **GNOME Calls:** hold, "Add call" on the same SIM, second call, swap, SIM in the history, the call window comes to the
  front, the call is not hung up when the window is hidden, landscape call display and **dial pad in landscape**.
- Earpiece, loudspeaker, USB and Bluetooth headsets in calls; screen off at the ear; hold / add call on the lock screen.
- Mobile data: a manual connection "Mobile data" (APN `internet`, IPv4) for the Phosh data tile.

## Telegram

- Telegram Desktop with **voice calls**: the call sound goes to the earpiece ("Speakerphone" button to switch), the
  microphone is clean (PipeWire opens the microphone in S16LE too), the screen turns off at the ear, an incoming call in
  sleep turns the screen on and rings (`m52xq-tg-stream`, `m52xq-voip-audio`, `m52xq-audio-route`, `m52xq-speakerphone`).
- The call is no longer declined when the phone is unlocked: Telegram starts with `GIO_USE_NETWORK_MONITOR=netlink`
  (GLib's NetworkManager monitor reported "network changed" when the modem modes were given back after a wake-up).
- Message sounds: `libcanberra-pulse` is installed (Phosh/feedbackd were silent without it).
- Camera in Telegram through virtual webcams (`m52xq-virtualcam`, libcamera to v4l2loopback).

## Camera (GNOME Snapshot)

- libcamera 0.8.0 with our patches, PipeWire rebuilt against it, Snapshot with the camera patch of the postmarketOS port.
- All four cameras: Main 64 MP, Front 32 MP, Wide, Macro; frames turned by the display rotation; photos of the Wide and
  Macro cameras are no longer saved on their side.
- **64 MP / 32 MP photos** through `m52xq-rawphoto` (raw capture, development on the GPU); tap to focus, zoom.
- **Video with the hardware encoder (Venus)**: 1080p and 4K, sensible bitrates after the kernel Venus fix.

## Sleep and power

- NetworkManager ignores the logind sleep signal (`network-manager` patch + flag file): apps no longer see a network loss on
  every suspend, and the phone no longer wakes every 15 s with Telegram open (sleep share about 45 % → 75–83 %).
- s2idle with "dark resume": network wake-ups do not turn the screen on; wakes for calls, SMS and alarms (RTC).
- The brightness no longer stays almost black after a reboot from a dimmed screen (`m52xq-backlight-min`).
- Own idle suspend (`m52xq-idle-suspend`) recognises Telegram calls and recovers after a PipeWire restart.

## Other

- Phosh: auto-rotation recovers by itself after the boot; Mobile Settings keeps the Bluetooth / Wi-Fi switches.
- "Reboot menu" app with "Reboot into recovery".
- USB headset plugged in at boot no longer takes sound card 0.

## Fixes of the last builds

- **ModemManager no longer aborts when the phone goes to sleep with mobile data on** (patch 0107, backport from
  ModemManager 1.25): the data of this modem go only through multiplexed (IPA/rmnet) connections, and 1.24 compared their
  number with the maximum of the non-multiplexed ones (0). ModemManager restarted while the phone was already asleep, and
  incoming calls during that sleep were lost. Checked: 248 suspends with mobile data on, a call in sleep rings.
- **A camera left open no longer keeps the phone awake all night:** Snapshot asks the session not to go idle while its
  window is open; now it is closed when the screen is locked (unless it records a video), and the phone sleeps.
- **Quick settings:** NFC tile (rfkill, state kept over reboots) and Speakerphone tile (replaces the "Speakerphone" app).
- SIM cards manager shows the mode that is really active when only one SIM card is inserted.

## Known issues

See the README: sensors stop after many hours of sleep (FastRPC), rare Wi-Fi firmware crash on resume, Wi-Fi may not wake
the phone in a long sleep, about 2.5 %/h in sleep with Telegram (the audio DSP does not sleep yet), camera image quality in
dim light, 4K at a high bitrate about 20 fps.
