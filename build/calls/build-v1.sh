#!/bin/sh
set -e
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck parallel=16"
cd /root/src
apt-get source gnome-calls
cd gnome-calls-*/
ls debian/patches 2>/dev/null | head -5 || true
for p in /root/src/m52xq-calls-patches/*.patch; do
  cp "$p" debian/patches/
  echo "$(basename $p)" >> debian/patches/series
done
dch -v "$(dpkg-parsechangelog -S Version)+m52xq1" -D forky "M52XQ patches: dial pad, hold/add call/swap, second call, show remaining call"
dpkg-buildpackage -b -us -uc
