# Debian (Mobian) + Phosh на ядре mainline для Samsung Galaxy M52 5G (m52xq) — полное руководство

Релиз «unofficial v1», 2026-11-20. English version: [MANUAL-EN.md](MANUAL-EN.md).

## 1. Что это

Debian forky (testing) arm64 с репозиторием Mobian, systemd и Phosh 0.58 на ядре mainline Linux 7.1.13 для Samsung Galaxy
M52 5G (SM-M526B / SM-M526BR, Snapdragon 778G / SM7325 «yupik»). Без Halium, libhybris, Android-ядра и Android-служб. Ядро,
дерево устройств и службы `m52xq-*` общие с портами postmarketOS Phosh, Plasma Mobile и Ubuntu Lomiri для этого же телефона.
Образ boot использует initramfs postmarketOS, который монтирует корень Debian с раздела `system`. Личный неофициальный
проект; проверен на одном SM-M526B.

## 2. Что работает

См. таблицу в [README](../README.md#what-works). Коротко: звонки, SMS и мобильные данные на двух SIM, Wi-Fi, Bluetooth (со
звуком), GPS, датчики, звук, Phosh на GPU, все четыре камеры (фото 64 Мп, видео Venus до 4K), Telegram со звонками, глубокий
сон с пробуждением на звонки, SMS и будильник. Не работает: отпечаток, VoLTE.

Известные проблемы тоже в README: датчики отваливаются после многих часов снов, изредка падает прошивка Wi-Fi при
пробуждении, в долгом сне Wi-Fi может не разбудить телефон, около 2,5 %/ч во сне с Telegram, качество камеры при слабом свете.

## 3. Что нужно

- Разблокированный загрузчик (OEM unlock), TWRP для m52xq:
  <https://github.com/saadelasfur/Action-Recovery-Builder/releases/tag/20261004173308>.
- Резервные копии EFS, persist, modem, boot, vendor_boot и vbmeta (TWRP Backup) и стоковая прошивка для Odin.
- Перед этим должна стоять прошивка на базе Samsung (сток, UN1CA или LineageOS): установщик копирует прошивки устройства с её
  разделов `vendor`, `apnhlos`, `modem`, `persist` и `efs`. UN1CA_3.1.0 даёт самый большой раздел `system`.

## 4. Установка

### 4.1. Zip для TWRP

Видеоинструкция: <https://www.youtube.com/watch?v=UUmmVd8_14Y>

1. Скопируйте [debian-mobian-phosh-m52xq-mainline-v1.zip](https://drive.google.com/file/d/1XqeCf2KN9WavcbCDK4oOFNDQlPdOteY5/view?usp=sharing) (md5 `7494cc8cb04a9db69ed78072a39d2712`) на карту microSD
   (или `adb push` в `/data` после Format Data в TWRP).
2. В TWRP:

```
Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - Select Storage - Micro SD card - debian-mobian-phosh-m52xq-mainline-v1.zip - Swipe to confirm Flash - Reboot System
```

3. Дождитесь `Updater process ended with RC=0`. Первая загрузка дольше обычной.

Что делает установщик: увеличивает `system` до 8 000 000 000 байт в метаданных LP, проверяет, что образ помещается, пишет
образ из двух чанков, пишет boot, vendor_boot и dtbo, копирует прошивки с разделов телефона (только чтение), добавляет
прошивку IPA в ramdisk boot, готовит реестр датчиков для ADSP, кладёт слой `m52xq-*` (`mainline-extras/rootfs-files`) поверх
корня, включает службы и настраивает `/home` на разделе userdata.

Телефон при установке греется. Если на экране уже есть вертикальные цветные полосы, не устанавливайте: от нагрева они могут
стать хуже.

### 4.2. Пароль и доступ

- Пароль по умолчанию (экран блокировки, `user`, `root`): `1111`. Сменить: `passwd` в приложении «Консоль».
- SSH по USB (RNDIS, примерно через 30 с после загрузки): `ssh root@172.16.42.1`, пароль `1111`.
- Снимок экрана: громкость вверх + громкость вниз, файл в `~/Pictures/Screenshots`.
- Приложение «Reboot menu»: перезагрузка, перезагрузка в рекавери (TWRP), выключение.
- Приложение «SIM cards manager» (`m52xq-sim-manager`): обе SIM / только SIM 1 / только SIM 2, SIM для данных, выключение
  SIM-карт и радио модема.
- Мобильные данные: плитка данных в шторке Phosh или Настройки — Мобильная сеть (подключение «Mobile data», APN `internet`;
  если оператору нужен другой APN, смените его там).
- Telegram: в его настройках выключите «Draw attention to the window» и включите «Close to taskbar». Приложение
  «Громкая связь» переключает звонок Telegram между разговорным динамиком и громким.

### 4.3. Обновления

`apt update && apt upgrade` работает с репозиториями Debian и Mobian. 33 наших пересобранных пакета стоят на `apt-mark hold`
(`apt-mark showhold`): не снимайте удержание, иначе сломаются звонки, две SIM, камера и сон. Обычные пакеты Debian, которые
тянут другой Phosh, ModemManager, libcamera или PipeWire, сначала проверяйте через `apt-get -s`.

## 5. Возврат на Android

Видеоинструкция: <https://www.youtube.com/watch?v=0lgLbtdl4rA>

Войдите в TWRP («Reboot menu» — «Reboot into recovery» или кнопки питания и громкости). Заранее положите zip прошивки на карту.

```
Wipe - Format Data - yes - enter - Back - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - lineage-23.2-2026-nightly-m52xq-signed.zip - Back - Back - Wipe - Format Data - enter - Reboot System
```

Zip LineageOS и UN1CA сами перезаписывают boot, vendor_boot и dtbo. Стоковая прошивка: Odin или Heimdall (BL, AP, CP, CSC).

## 6. Ядро

Mainline Linux 7.1.13, исходники <https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq>, конфиг и патчи этого
релиза — в [`../kernel/`](../kernel/README.md). Образы boot, vendor_boot и dtbo — в zip (`firmware/`). DTB — из
[`../device-tree/`](../device-tree).

## 7. Сборка с нуля

1. Корень: `debootstrap --arch=arm64 forky` с qemu-user-static, репозиторий и ключ Mobian
   ([`../rootfs-overlay/etc/apt/`](../rootfs-overlay/etc/apt)), Phosh, phrog (вход), приложения GNOME, пакеты для железа
   (rmtfs, pd-mapper, tqftpserv, qrtr, hexagonrpcd, iio-sensor-proxy, ModemManager, alsa-ucm), пользователь `user` с UID 10000.
2. Пересобранные пакеты: папки [`../build/`](../build) в сборочном chroot arm64 (копия корня со сборочными зависимостями):
   `apt-get source` + наши патчи в `debian/patches` + `dch` + `dpkg-buildpackage -B`. Порядок: libcamera → PipeWire (нужен
   libcamera-dev 0.8) → Snapshot и m52xq-rawphoto; phosh / phosh-mobile-settings / gnome-calls / chatty — `build-r2-all.sh`;
   modemmanager, network-manager, libssc отдельно. Под qemu не больше `parallel=8` (с 16 сборочный ПК зависал);
   `dpkg-buildpackage -nc` продолжает остановленную сборку (чтобы получить новый бинарник, удалите `debian/debhelper-build-stamp`).
3. Установить пакеты в корень (`apt-get install ./*.deb`, затем `apt-mark hold`) и положить сверху
   [`../rootfs-overlay/`](../rootfs-overlay) (здесь текстовые файлы, бинарники перечислены в `EXCLUDED-FILES.txt`).
4. Минимальный релизный корень: удалить сборочные пакеты, кэш и списки apt, журналы, ключи SSH, machine-id, прошивки и
   данные телефона.
5. Образ и zip: [`../image/build-release.sh`](../image/build-release.sh) (ext4 3420 МиБ, около 200 МБ свободно, два чанка,
   `zip -9` изнутри папки).
6. Состав папки zip: `META-INF/` ([`../installer/`](../installer)), `firmware/` (boot, vendor_boot, dtbo-frag),
   `mainline-extras/rootfs-files/` (файлы, которые установщик кладёт поверх образа), `data/rootfs-chunks/`.

## 8. Состав репозитория

См. [README](../README.md#repository-layout).

## 9. Пересобранные пакеты (`build/`)

См. [README](../README.md#rebuilt-packages-build).

## 10. Службы и скрипты (слой)

| Имя | Что делает |
|---|---|
| `m52xq-adsp-start`, `m52xq-audio-reprobe`, `m52xq-audio-rescue` | запуск ADSP, когда прошивка уже на корне; поднимает звуковую карту после гонки старта ADSP |
| `m52xq-modem-setup`, `m52xq-sim-mode*`, `m52xq-dds`, `m52xq-nas-mode`, `m52xq-flight-mode` | сессия модема и GNSS, режим SIM (обе / SIM 1 / SIM 2), SIM для данных, режимы сети, режим полёта для сотовой связи |
| `m52xq-voicecall`, `m52xq-callaudiod`, `m52xq-voice-mixers.sh`, `m52xq-usb-call-bridge` | голосовой тракт модема в звонке (q6voice + микшеры кодека), D-Bus API CallAudio для Calls, мост USB-гарнитуры |
| `m52xq-tfa-guard` | заново открывает громкий динамик, если настройка усилителя TFA9878 не удалась |
| `m52xq-tg-stream`, `m52xq-voip-audio`, `m52xq-audio-route`, `m52xq-speakerphone` | звонки Telegram: поиск потока по клиенту PulseAudio, разговорный / громкий / гарнитуры, микрофон вместо монитора |
| `m52xq-incall-proximity` | экран гаснет и тач блокируется у уха (звонки модема и Telegram) |
| `m52xq-idle-suspend` | своё засыпание по бездействию (не засыпает, пока приложение держит блокировку или идёт звонок Telegram) |
| хуки system-sleep | тёмное пробуждение (панель не загорается при пробуждениях по сети), пауза GPS, 2G модема во сне, Wi-Fi не отключается, уровень питания UFS, камеры выкл., меньше своих пробуждений |
| `m52xq-wake-restore`, `m52xq-bt-restore` | возвращают Bluetooth, режимы сети и GPS, когда пользователь действительно у телефона |
| `m52xq-wow-params`, `m52xq-wpss-guard`, `m52xq-wpss-restart` | флаги пробуждения по Wi-Fi, защита от цикла падений WPSS и холодный перезапуск |
| `m52xq-bt-firmware`, `m52xq-bt-addr.py` | перезагрузка прошивки Bluetooth, собственный адрес BD телефона |
| `m52xq-sensor-kick` | перезапускает iio-sensor-proxy, когда датчики ADSP поднялись (автоповорот) |
| `m52xq-virtualcam` | виртуальные веб-камеры V4L2 (libcamera → v4l2loopback) для Telegram и браузеров |
| `m52xq-home-on-userdata` | `/home` на разделе userdata |
| `m52xq-vol-screenshot`, `m52xq-reboot-menu`, `m52xq-sim-manager` | снимок экрана кнопками, меню перезагрузки, приложение SIM-карт |
| `m52xq-backlight-min` | яркость не остаётся почти чёрной после перезагрузки с притушенного экрана |

## 11. Подводные камни (коротко)

- `/etc/fstab` не должен быть пустым: тогда initramfs pmOS ждёт раздел `pmOS_boot` и останавливается в отладочной консоли.
- Громкий динамик (TFA9878) молчит в S24_LE: PipeWire открывает карту в S16LE (`51-m52xq-s16.conf`), микрофон тоже (иначе в
  звонках Telegram помехи).
- ModemManager нужен с `--test-quick-suspend-resume`, иначе после сна модем QRTR теряется.
- У потоков telegram-desktop в Debian нет свойств `application.*`, они есть только у клиента PulseAudio: Telegram определяется
  только по клиенту.
- С `GIO_USE_NETWORK_MONITOR=base` Telegram в Debian остаётся «не в сети»; `netlink` работает.
- libcamera 0.8 переименовывает библиотеку (`libcamera0.8`) и свойства расположения камеры: PipeWire нужно пересобрать.
- `MODVERSIONS` выключен: модули ядра только с тем же Image.

## 12. Благодарности

Debian и Mobian, Phosh / phoc / GNOME (Calls, Chatty, Snapshot), libcamera, PipeWire, ModemManager, NetworkManager,
postmarketOS, разработчики mainline Linux для Qualcomm SC7280 / QCM6490, LineageOS (исходники для справки), сопровождающие
TWRP для m52xq.
