#!/bin/bash

unameOutM="$(uname -m)"
case "${unameOutM}" in
    i286)   flofarch="286";;
    i386)   flofarch="386";;
    i686)   flofarch="386";;
    x86_64) flofarch="amd64";;
    arm)    dpkg --print-flofarch | grep -q "arm64" && flofarch="arm64" || flofarch="arm";;
    riscv64) flofarch="riscv64"
esac

echo "Installing NFC..."
echo "Preparing to install NFC..."
$maysudo apt-get update
$maysudo apt-get install pcscd pcsc-tools rename #task: dont attempt to install if already installed; upgrade instead

cat >> /etc/modprobe.d/blacklist.conf <<EOF
install nfc /bin/false
install pn533 /bin/false
EOF

unzip ACS-Unified-PKG-Lnx-118-P.zip
echo "Installing NFC drivers..."
if [ "$flofarch" = "386" ]; then
   $maysudo dpkg -i ACS-Unified-PKG-Lnx-118-P/ubuntu/disco/libacsccid1_1.1.8-1~ubuntu19.04.1_i386.deb
fi
if [ "$flofarch" = "amd64" ]; then
   $maysudo dpkg -i ACS-Unified-PKG-Lnx-118-P/ubuntu/disco/libacsccid1_1.1.8-1~ubuntu19.04.1_amd64.deb
fi
rm -rf ACS-Unified-PKG-Lnx-118-P

sudo service pcscd restart
#sudo /etc/init.d/pcscd restart
#- from https://oneguyoneblog.com/2016/11/02/acr122u-nfc-usb-reader-linux-mint/

./nfctools-latest.AppImage --appimage-extract
mv squashfs-root nfctools
$maysudo mv nfctools /1/programs/

#mark to run after next restart: "sudo service pcscd restart"
