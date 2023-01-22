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

echo "Preparing to install NFC..."
$maysudo apt-get update
echo "Installing NFC..."
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

echo "Installing NFC Tools (yes, that tool you may use on your phone)..."
./nfctools-latest.AppImage --appimage-extract
mv squashfs-root nfctools
$maysudo mv -f nfctools /1/programs/

$maysudo cat > /usr/bin/nfctools <<EOF
#!/bin/bash

/1/programs/nfctools/./AppRun
EOF
$maysudo chmod +x /usr/bin/nfctools
$maysudo cat > /usr/share/applications/nfctools.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Name=NFC Tools
Comment=Read and write your NFC chips with a simple and lightweight user interface.
Type=Application
Exec=nfctools
Icon=nfctools
Categories=Office;
Keywords=nfc;chips;wireless;authentication;data;
EOF

#mark to run after next restart: "sudo service pcscd restart"
