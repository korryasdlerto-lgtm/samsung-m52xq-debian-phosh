#!/bin/sh
# 2026-11-19: one queue with ALL pmOS Phosh v1 patches: phosh (0001 r101 + 0002), phosh-mobile-settings (0001 BT/Wi-Fi switch),
# gnome-calls (0001..0013), chatty (1492 + 0001 dual SIM). Each: clean Debian source, our patches with fuzz 3 (already present -> skipped),
# one combined debian/patches/m52xq-all.patch, version +m52xq2 (calls: +m52xq2, the others +m52xq1 for the first build of ours).
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16"
W=/root/src/r2; mkdir -p $W
apt-get update -qq || true
apt-get build-dep -y phosh-mobile-settings chatty gnome-calls phosh > $W/build-dep.log 2>&1 || { echo BUILD-DEP-FAILED; tail -20 $W/build-dep.log; }
build() {  # $1 source name, $2 new version suffix, $3 changelog text
  S=$1; D=$W/$S; rm -rf $D; mkdir -p $D; cd $D || return 1
  echo "===== $S $(date -u +%T)"
  if [ -f /root/src/${S}_*.dsc ] 2>/dev/null; then :; fi
  DSC=$(ls /root/src/${S}_*.dsc 2>/dev/null | head -1)
  if [ -n "$DSC" ]; then dpkg-source -x "$DSC" src >/dev/null || return 2; else apt-get source -qq "$S" >/dev/null 2>&1 || return 2; mv $(ls -d */ | grep -v '^src/' | head -1) src; fi
  cp -r src base; cp -r src work
  for p in /root/src/r2-patches/$S/*.patch; do
    if (cd work && patch -p1 -R --dry-run -f < "$p" >/dev/null 2>&1); then echo "SKIP (already in Debian) $(basename $p)"; continue; fi
    if (cd work && patch -p1 -F3 -N -f < "$p" > /tmp/r2-p.log 2>&1) && ! grep -q FAILED /tmp/r2-p.log; then echo "OK   $(basename $p)"; grep -E "Hunk .*(fuzz|offset)" /tmp/r2-p.log | head -6
    else echo "FAIL $(basename $p)"; head -25 /tmp/r2-p.log; return 20; fi
  done
  diff -ruN --exclude=debian --exclude=.pc --exclude=gvc --exclude='*.orig' --exclude='*.rej' base work | sed -e 's#^--- base/#--- a/#' -e 's#^+++ work/#+++ b/#' -e '/^diff -ruN/d' > m52xq-all.patch
  echo "combined patch: $(grep -c '^+++ b/' m52xq-all.patch) files, $(wc -l < m52xq-all.patch) lines, md5 $(md5sum < m52xq-all.patch | cut -c1-32)"
  cd src; cp ../m52xq-all.patch debian/patches/m52xq-all.patch; echo m52xq-all.patch >> debian/patches/series
  dch -v "$(dpkg-parsechangelog -S Version)+$2" -D forky "$3"
  dpkg-buildpackage -B -us -uc > ../build.log 2>&1; rc=$?
  echo "$S dpkg-buildpackage rc=$rc $(date -u +%T)"; tail -3 ../build.log
  ls -1 $D/*.deb 2>/dev/null
  return $rc
}
build phosh m52xq2 "M52XQ (pmOS Phosh v1: 0001 r101 + 0002): dual SIM indicators, empty SIM slot tile hidden, rotation tile, accelerometer claim self-recovery, lock screen hold/add call"; echo "RESULT phosh $?"
build phosh-mobile-settings m52xq1 "M52XQ: keep the on/off switch of the Bluetooth and Wi-Fi panels"; echo "RESULT phosh-mobile-settings $?"
build gnome-calls m52xq2 "M52XQ (pmOS Phosh v1: 0001..0013): dial pad, hold/add/swap, second call, SIM in history, no hangup on window hide, landscape, present window"; echo "RESULT gnome-calls $?"
build chatty m52xq1 "M52XQ: dual SIM SMS and chat actions; upstream MR 1492 (vCard attributes with e-d-s 3.60)"; echo "RESULT chatty $?"
echo ALL-DONE
