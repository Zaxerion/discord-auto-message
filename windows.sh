#!/bin/bash
#
# CREATED By NIXPOIN.COM
#
mount -o remount,rw /mnt

echo "Pilih OS yang ingin anda install"
echo "	1) Windows 11 rill"
echo "	2) Windows 10"
echo "	3) Windows 2012"
echo "	4) Windows 10"
echo "	5) Windows 2022"
echo "	6) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
	1|"") PILIHOS="https://bit.ly/3xWPgHG"  IFACE="Ethernet Instance 0 2";;
	2) PILIHOS="https://archive.org/download/10.ENT.x64.EVAL.USEnglish_201902/10.ENT.x64.EVAL.US-English.gz "  IFACE="Ethernet Instance 0 2";;
	3) PILIHOS="https://files.sowan.my.id/windows2012.gz"  IFACE="Ethernet";;
	4) PILIHOS="https://files.sowan.my.id/windows10.gz"  IFACE="Ethernet Instance 0 2";;
	5) PILIHOS="https://files.sowan.my.id/windows2022.gz"  IFACE="Ethernet Instance 0 2";;
	6) read -p "Masukkan Link GZ mu : " PILIHOS;;
	*) echo "pilihan salah"; exit;;
esac

echo "Merasa terbantu dengan script ini? Anda bisa memberikan dukungan melalui QRIS kami https://nixpoin.com/qris"

read -p "Masukkan password untuk akun Administrator (minimal 12 karakter): " PASSADMIN

IP4=$(curl -4 -s icanhazip.com)
GW=$(ip route | awk '/default/ { print $3 }')


cat >/tmp/net.bat<<EOF
@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)
net user Administrator $PASSADMIN


netsh -c interface ip set address name="$IFACE" source=static address=$IP4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="$IFACE" address=1.1.1.1 index=1 validate=no
netsh -c interface ip add dnsservers name="$IFACE" address=8.8.4.4 index=2 validate=no

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit
EOF


cat >/tmp/dpart.bat<<EOF
@ECHO OFF
echo JENDELA INI JANGAN DITUTUP
echo SCRIPT INI AKAN MERUBAH PORT RDP MENJADI 5000, SETELAH RESTART UNTUK MENYAMBUNG KE RDP GUNAKAN ALAMAT $IP4:5000
echo KETIK YES LALU ENTER!

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

set PORT=5000
set RULE_NAME="Open Port %PORT%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 5000

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"
cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q dpart.bat
timeout 50 >nul
del /f /q ChromeSetup.exe
echo JENDELA INI JANGAN DITUTUP
exit
EOF

wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget https://dw53.uptodown.com/dwn/o4kz4s1Ow4U-Tnwo9AS-tP9QmXstBRv67tC_wN6Bf5Z50i8aPzxcmSwvKjvhjXPqbZgS4g0Ys9TVbQniqjQjU2c-hTj-XQpgv2eOXU47jJ0pVQpRZ4hzn9JExPs_2hGh/VOyMtc4HnT0XweX9zer5j4qGVmDBAONt227BrfYjoM1laeFoU5l9_1HUWold9vQjQUGPlLGdCXxfnlrAP8YEoU0kvu8hu32O2F_cCjUMTTBQWbj61vl5UEGqYVcL_hSk/S4AUqA6LXy5CefEzyBInQlKmp2VWRDv21Q89H4xpNOdwmx_kqqIl29fNJJVST5UEDxeRDeWRjWhESqLMdP4YbOmPcshEZ23BO4rec5XqwoA=/mozilla-firefox-122-0.exe
cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

mount -o remount,ro /mnt
