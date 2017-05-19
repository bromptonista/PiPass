#!/bin/bash

# Enforce command permissions.
SUDO=""
if (( $EUID != 0 )); then
    SUDO="sudo"
fi

# PiPass installer header.
echo "[ PiPass - Nintendo 3DS Homepass for the Raspberry Pi ]"
echo ""

# Check network connectivity.
echo "[+] Verifying network connectivity..."
$SUDO wget -q --tries=10 --timeout=20 --spider https://github.com/Matthew-Hsu/PiPass/archive/master.zip
if [[ $? -eq 0 ]]; then
    echo "[+] PiPass is now installing..."
else
    echo ""
    echo "[!] Unable to download PiPass from GitHub. Please check your network connection and try again."
    echo ""
    echo "[ Installation Aborted ]"
    exit
fi

# Installer variables.
DASHBOARD_PATH="/var/www/html"
PIPASS_PATH="/opt/PiPass/"
WORKING_DIRECTORY="/tmp/PiPass/"

# Updating installed packages.
echo "[+] Updating installed packages..."
$SUDO apt-get update > /dev/null 2>&1
$SUDO apt-get upgrade -y > /dev/null 2>&1

# Installing dependencies.
echo "[+] Installing dependencies..."
$SUDO apt-get install apache2 -y > /dev/null 2>&1
$SUDO apt-get install bridge-utils -y > /dev/null 2>&1
$SUDO apt-get install hostapd -y > /dev/null 2>&1
$SUDO apt-get install iputils-ping -y > /dev/null 2>&1
$SUDO apt-get install nano -y > /dev/null 2>&1
$SUDO apt-get install p7zip-full -y > /dev/null 2>&1
$SUDO apt-get install php5 -y > /dev/null 2>&1
$SUDO apt-get install php5-common -y > /dev/null 2>&1
$SUDO apt-get install php5-cli -y > /dev/null 2>&1
$SUDO apt-get install libapache2-mod-php5 -y > /dev/null 2>&1
$SUDO apt-get install python -y > /dev/null 2>&1
$SUDO apt-get install sudo -y > /dev/null 2>&1
$SUDO apt-get install usbutils -y > /dev/null 2>&1
$SUDO apt-get install wireless-tools -y > /dev/null 2>&1

# Installing WiFi drivers.
echo "[+] Installing WiFi Drivers..."
$SUDO apt-get install firmware-linux-nonfree -y > /dev/null 2>&1
$SUDO apt-get install firmware-ralink -y > /dev/null 2>&1
$SUDO apt-get install firmware-realtek -y > /dev/null 2>&1
$SUDO apt-get install zd1211-firmware -y > /dev/null 2>&1

# Configure a working directory.
if [ -d "$WORKING_DIRECTORY" ]; then
    $SUDO rm -rf $WORKING_DIRECTORY > /dev/null 2>&1
fi

$SUDO mkdir $WORKING_DIRECTORY > /dev/null 2>&1

# Downloading PiPass.
echo "[+] Downloading PiPass from the PiPass Master Branch..."
$SUDO wget -P $WORKING_DIRECTORY https://github.com/Matthew-Hsu/PiPass/archive/master.zip > /dev/null 2>&1

# Install PiPass.
echo "[+] Installing PiPass..."
$SUDO 7z x $WORKING_DIRECTORY/master.zip -o$WORKING_DIRECTORY -y > /dev/null 2>&1
$SUDO chmod -R 755 $WORKING_DIRECTORY > /dev/null 2>&1

if [ ! -d "$DASHBOARD_PATH" ]; then
    $SUDO mkdir $DASHBOARD_PATH > /dev/null 2>&1
fi

if [ ! -d "$PIPASS_PATH" ]; then
    $SUDO mkdir $PIPASS_PATH > /dev/null 2>&1
fi

$SUDO cp -r /tmp/PiPass/PiPass-master/etc/default/* /etc/default/ > /dev/null 2>&1
$SUDO cp -r /tmp/PiPass/PiPass-master/etc/hostapd/* /etc/hostapd/ > /dev/null 2>&1
$SUDO cp -r /tmp/PiPass/PiPass-master/etc/network/* /etc/network/ > /dev/null 2>&1
$SUDO cp -r /tmp/PiPass/PiPass-master/opt/PiPass/* $PIPASS_PATH > /dev/null 2>&1
$SUDO cp -r /tmp/PiPass/PiPass-master/var/www/html/* $DASHBOARD_PATH > /dev/null 2>&1

$SUDO rm /etc/udev/rules.d/70-persistent-net.rules > /dev/null 2>&1

# Setting permissions.
echo "[+] Setting Permissions..."
$SUDO grep -rwq "/etc/sudoers" -e "www-data ALL=(ALL:ALL) NOPASSWD: ALL"
if [[ ! $? -eq 0 ]]; then
    echo "www-data ALL=(ALL:ALL) NOPASSWD: ALL" | $SUDO tee --append /etc/sudoers > /dev/null 2>&1
fi

$SUDO chmod -R 755 $DASHBOARD_PATH > /dev/null 2>&1
$SUDO chmod -R 755 $PIPASS_PATH > /dev/null 2>&1

# Installation cleanup.
echo "[+] Cleaning up..."
$SUDO rm -rf $WORKING_DIRECTORY > /dev/null 2>&1
$SUDO apt-get autoremove -y > /dev/null 2>&1
$SUDO apt-get clean > /dev/null 2>&1

# Completing installation.
echo ""
echo "[!] Please go to a web browser on another device and enter: $(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}') as the URL to access the PiPass Dashboard."
echo ""
echo "[ Installation Completed ]"
echo ""
echo "[ Restarting Raspbery Pi ]"
$SUDO /sbin/shutdown -r now > /dev/null 2>&1
exit
