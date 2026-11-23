#!/bin/sh
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16"
cd /root/src
apt-get -y build-dep phosh || exit 11
apt-get source phosh || exit 12
cd phosh-*/ || exit 13
# sequential dry-run on a scratch copy: the patches depend on each other
rm -rf /root/src/phosh-seq && cp -r . /root/src/phosh-seq
( cd /root/src/phosh-seq && for p in /root/src/m52xq-phosh-patches/*.patch; do patch -p1 -s < "$p" && echo "OK   $(basename $p)" || { echo "FAIL $(basename $p)"; exit 1; }; done ) || { echo PATCHES-DO-NOT-APPLY; exit 20; }
mkdir -p debian/patches
for p in /root/src/m52xq-phosh-patches/*.patch; do cp "$p" debian/patches/; echo "$(basename $p)" >> debian/patches/series; done
dch -v "$(dpkg-parsechangelog -S Version)+m52xq1" -D forky "M52XQ patches: dual SIM indicators, rotation tile, lock screen hold/add call"
dpkg-buildpackage -B -us -uc
