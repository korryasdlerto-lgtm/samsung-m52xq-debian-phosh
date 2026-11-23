#!/bin/sh
# 2026-11-20 (в6): phosh 0.58.0-1+m52xq3 = +m52xq2 (m52xq-all.patch) + m52xq-0003 (NFC and speakerphone quick settings); reuses the r2 build dir; parallel=8
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=8"
cd /root/src/r2/phosh/src || exit 1
dch -v "0.58.0-1+m52xq3" -D forky "M52XQ: NFC quick setting (rfkill) and speakerphone quick setting (Telegram calls)"
echo "start $(date -u +%T)"
dpkg-buildpackage -b -us -uc -nc; rc=$?
echo "rc=$rc end $(date -u +%T)"; ls -l /root/src/r2/phosh/*0.58.0-1+m52xq3*.deb 2>/dev/null
exit $rc
