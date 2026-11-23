#!/bin/sh
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16"
cd /root/src || exit 1
SRC=/root/src/phosh-0.58.0
rm -rf phosh-base phosh-work
cp -r $SRC phosh-base && cp -r $SRC phosh-work
# Debian's phosh already carries its own patches (e.g. launch-panel instead of launch-mobile-panel): our patches are applied with fuzz 3 to the
# Debian tree and turned into ONE new patch for debian/patches
( cd phosh-work && for p in /root/src/m52xq-phosh-patches/*.patch; do
    if patch -p1 -F3 -N < "$p" > /tmp/phosh-p.log 2>&1 && ! grep -q "FAILED" /tmp/phosh-p.log; then echo "OK   $(basename $p)"; grep -E "Hunk .*(fuzz|offset)" /tmp/phosh-p.log | head -4;
    else echo "FAIL $(basename $p)"; cat /tmp/phosh-p.log | head -12; exit 1; fi
  done ) || { echo PATCHES-DO-NOT-APPLY; exit 20; }
find phosh-work -name '*.orig' -o -name '*.rej' | grep -v debian | head
diff -ruN --exclude=debian --exclude=.pc --exclude='*.orig' --exclude='*.rej' phosh-base phosh-work | sed -e 's#^--- phosh-base/#--- a/#' -e 's#^+++ phosh-work/#+++ b/#' -e '/^diff -ruN/d' > /root/src/m52xq-phosh-all.patch
echo "combined patch: $(grep -c '^+++ b/' /root/src/m52xq-phosh-all.patch) files, $(wc -l < /root/src/m52xq-phosh-all.patch) lines"
cd $SRC || exit 3
mkdir -p debian/patches
cp /root/src/m52xq-phosh-all.patch debian/patches/m52xq-phosh-all.patch
grep -qx m52xq-phosh-all.patch debian/patches/series 2>/dev/null || echo m52xq-phosh-all.patch >> debian/patches/series
dch -v "$(dpkg-parsechangelog -S Version)+m52xq1" -D forky "M52XQ patches: dual SIM indicators, rotation tile, lock screen hold/add call"
dpkg-buildpackage -B -us -uc
