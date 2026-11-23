#!/bin/sh
# phosh 0.58.0-1+m52xq2: pmOS Phosh v1 patches 0001 r101 (empty SIM slot tile hidden, accelerometer claim self-recovery) + 0002
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16"
set -e
mkdir -p /root/src/phosh-r2 && cd /root/src/phosh-r2
rm -rf phosh-base phosh-work phosh-0.58.0
cp ../phosh_0.58.0-1.dsc ../phosh_0.58.0-1.debian.tar.xz ../phosh_0.58.0.orig.tar.xz . 2>/dev/null || cp ../phosh_0.58.0-1.dsc ../phosh_0.58.0-1.debian.tar.xz ../phosh_0.58.0.orig.tar.* .
dpkg-source -x phosh_0.58.0-1.dsc phosh-0.58.0
cp -r phosh-0.58.0 phosh-base && cp -r phosh-0.58.0 phosh-work
( cd phosh-work && for p in /root/src/m52xq-phosh-patches-r101/*.patch; do
    if patch -p1 -F3 -N < "$p" > /tmp/phosh-p.log 2>&1 && ! grep -q "FAILED" /tmp/phosh-p.log; then echo "OK   $(basename $p)"; grep -E "Hunk .*(fuzz|offset)" /tmp/phosh-p.log | head -6;
    else echo "FAIL $(basename $p)"; head -20 /tmp/phosh-p.log; exit 1; fi
  done ) || { echo PATCHES-DO-NOT-APPLY; exit 20; }
diff -ruN --exclude=debian --exclude=.pc --exclude='*.orig' --exclude='*.rej' phosh-base phosh-work | sed -e 's#^--- phosh-base/#--- a/#' -e 's#^+++ phosh-work/#+++ b/#' -e '/^diff -ruN/d' > m52xq-phosh-all.patch || true
echo "combined patch: $(grep -c '^+++ b/' m52xq-phosh-all.patch) files, $(wc -l < m52xq-phosh-all.patch) lines, md5 $(md5sum < m52xq-phosh-all.patch)"
cd phosh-0.58.0
cp ../m52xq-phosh-all.patch debian/patches/m52xq-phosh-all.patch
echo m52xq-phosh-all.patch >> debian/patches/series
dch -v "0.58.0-1+m52xq2" -D forky "M52XQ (pmOS Phosh v1 patches 0001 r101 + 0002): dual SIM indicators, empty SIM slot tile hidden, rotation tile, accelerometer claim self-recovery, lock screen hold/add call"
dpkg-buildpackage -B -us -uc
echo BUILD-EXIT=0
