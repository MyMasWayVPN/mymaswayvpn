#!/bin/bash
#
#
echo "Pilih OS yang ingin anda install"
echo "	1) Windows 11 64bit"
echo "	2) Windows 10 64bit "
echo "	3) Windows 10 64bit Spectre"
echo "	4) Windows 2012"
echo "	5) Windows 2016"
echo "	6) Windows 2022"
echo "	7) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
	1|"") PILIHOS="https://files.sowan.my.id/windows2019.gz"  IFACE="Ethernet Instance 0 2";;
	2) PILIHOS="http://128.199.78.158/W10MasWay.gz" IFACE="Ethernet Instance";;
	3) PILIHOS="https://rizzcode.my.id/2:/W10MasWay.xz" IFACE="Ethernet Instance 0 0";; 
	4) PILIHOS="http://128.199.78.158/windows12.gz" IFACE="Ethernet Instance";; 
	5) PILIHOS="http://128.199.78.158/windows16.gz" IFACE="Ethernet Instance";; 
	6) PILIHOS="http://128.199.78.158/windows22.gz" IFACE="Ethernet Instance";; 
	7) read -p "Masukkan Link GZ mu : " PILIHOS;;
	*) echo "pilihan salah"; exit;;
esac

echo "Merasa terbantu dengan script ini? Anda bisa memberikan dukungan melalui QRIS kami https://nixpoin.com/qris"

read -p "Masukkan password untuk akun Admin (minimal 8 karakter): " PASSADMIN

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
echo SCRIPT INI AKAN MERUBAH PORT RDP MENJADI 2222, SETELAH RESTART UNTUK MENYAMBUNG KE RDP GUNAKAN ALAMAT
echo HOST : $IP4:2222
echo USERNAME : Administrator atau admin
echo PASSWORD : $PASSADMIN
echo KETIK YES LALU ENTER!

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

set PORT=2222
set RULE_NAME="RDP_PORT_%PORT%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME% already exists.
    echo Hey, you already got a out rule by that name, you cannot put another one in!
) else (
    echo Rule %RULE_NAME% does not exist. Creating...
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)

reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v PortNumber /t REG_DWORD /d 2222

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

####wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress
wget --no-check-certificate -O- $PILIHOS | xzcat | dd of=/dev/vda  bs=3M status=progress
mount.ntfs-3g /dev/vda2 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
wget https://nixpoin.com/ChromeSetup.exe
cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

echo 'Your server will turning off in 3 second'
sleep 3
poweroff
