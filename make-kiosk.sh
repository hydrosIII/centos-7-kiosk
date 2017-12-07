#!/bin/bash

# KIOSK generator for Scientific Linux and CentOS (versions 5; 6 and 7)
# Created using Scientific Linux
# Wasn't made and never tested on different distros than SL/CentOS/EL!
# Version 1.4 for i386 and x86_64
#
# Feel free to contact me: marcin@marcinwilk.eu
# www.marcinwilk.eu
# Marcin Wilk
#
# Changelog:
# v 1.4 - 14.01.2016
# +Make browser history and setting reset every reboot 
# -and after user inactivity of 15 minutes
# -Use Chromium browser as main web browser in EL7
# +Add Matchbox Window Manager to handle fullscreen of browsers windows
# +Disable screen saver and blank screen
#
# v 1.3 - 12.01.2016
# Added SL/CentOS 7 support
#
# v 1.2 - 06.06.2014
# Added SL/CentOS 5 support (for older computers with low RAM)
#
# v 1.1 - 31.05.2014
# Not released, no changes in code, tested on EL6 and Fedora 20
#
# v 1.0 - 30.05.2014
# First release, tested on Scientific Linux 6 and CentOS 6
#
# Future plans:
# From now on there are no future plans (done in v 1.3)
# + Add support for 5.x tree (done in v 1.2)
# + Add support for 7.x tree (done in v 1.3)
#
# + Opera do not show license window (done in v 1.3)
# + Less controll on Opera browser by user (done in v 1.3)
# + Add flash support (done in v 1.2)
# + Add configuration options for users (first options in v 1.2)

############### Configuration

mainsite=http://google.com
#Site that will be loaded as default after KIOSK start.

cpu=$( uname -i )
# Change it to cpu=i386 or cpu=x86_64 to force it to work when you got
# non standard kernel or unknown CPU architecture.

log=/var/log/make-kiosk.log
# The directiry and file name where log output will be saved.
# You may specify any location because script run from root account.

user=$( whoami )
# User name that run the script. No reasons to change it.
# Used only for testing.

el5=$( cat /etc/redhat-release | grep "release 5" )
# Check if release version is 5. You may change it to el5=release 5
# so it will use options prepared for that versions.

el6=$( cat /etc/redhat-release | grep "release 6" )
el7=$( cat /etc/redhat-release | grep "release 7" )
# Same like above but checking for version 6 and 7.
# You may force to use instructions for all releases by setting
# them elX=release X in here. Where X is the EL version.

flash=yes
# Change it to flash=no, if you do not want to have flash installed.

############### End of configuration options

echo -e "Welcome in \e[93mKIOSK generator \e[39mfor Scientific Linux and CentOS."
echo -e "Version \e[91m1.4 \e[39msupporting EL/SL/CentOS version 5; 6 and 7."
echo ""
echo "This script will install additional software and will make changes"
echo "in system config files to make it work in KIOSK mode after reboot"
echo "with firefox started as web browser."
echo ""
echo "The log file will be created in /var/log/make-kiosk.log"
echo "Please attach this file for error reports."
echo ""
if [ $user != root ]
then
    echo "You must be root. Mission aborted!"
    echo "You are trying to start this script as: $user"
    echo "User $user didn't have root rights!" >> make-kiosk.log
    exit 0
else
    echo "Kernel processor architecture detected: $cpu"
fi
echo "------------------- ---------- -------- ----- -" >> $log
date >> $log
echo "Generating detected CPU & Kernel log."
cat /etc/*-release >> $log
uname -a >> $log
if [ -n "$el5" ]
then
echo "No lscpu in EL5, skipping CPU logging." >> $log
else
lscpu 1>> $log 2>> $log
fi
echo "This process will take some time, please be patient..."
if [ ! -f /etc/redhat-release ]
then
    echo "Your Linux distribution isn't supported by this script."
    echo "Mission aborted!"
    echo "Unsupported Linux distro!" >> $log
    exit 0
fi
if [ $cpu = x86_64 ]
then
    echo "Detected Kernel CPU arch. is x86_64!" >> $log
elif [ $cpu = i386 ]
then
    echo "Detected Kernel CPU arch. is i386!" >> $log
else
    echo "No supported kernel architecture. Aborting!" >> $log
    echo "I did not detected x86_64 or i386 kernel architecture."
    echo "It looks like your configuration isn't supported."
    echo "Mission aborted!"
    exit 0
fi

echo "Operation done in 5%"
echo "Adding user kiosk."
echo "Adding user kiosk." >> $log
useradd kiosk 1>> $log 2>> $log
echo "Installing wget."
echo "Installing wget." >> $log
yum -y install wget 1>> $log 2>> $log
echo "Operation done in 10%"
echo "Installing X Window system with GDM/Gnome/Matchbox. It will take very long!!! Be patient!!! Downloading up to ~300MB"
echo "Installing X Window system with GDM/Gnome/Matchbox." >> $log
yum -y groupinstall basic-desktop x11 fonts base-x 1>> $log 2>> $log
yum -y install gdm 1>> $log 2>> $log
yum -y install matchbox-window-manager 1>> $log 2>> $log
yum -y install rsync 1>> $log 2>> $log

echo "Operation done in 60%"
echo "Checking EL version..."
echo "Installing Firefox"
yum install -y firefox
echo "Adding Xinit Session support." >> $log
echo "Adding Xinit Session support."
yum -y install gnome-session-xsession 1>> $log 2>> $log
yum -y install xorg-x11-xinit-session 1>> $log 2>> $log


echo "Operation done in 85%"
echo "Configuring login manager (GDM), adding lines for autologin kiosk user."
autologin=$( cat /etc/gdm/custom.conf | grep AutomaticLoginEnable=true )
loginname=$( cat /etc/gdm/custom.conf | grep AutomaticLogin=kiosk )
if [ -n "$autologin" ]
then
    echo "File is already configured for automatic login."
    echo "Current automatic login config:"
    grep AutomaticLoginEnable /etc/gdm/custom.conf
    echo ""
    echo "Check the GDM file /etc/gdm/custom.conf."
    echo "Aborting adding AutomaticLoginEnable=true!" >> $log
    cat /etc/gdm/custom.conf 1>> $log 2>> $log
else
    echo "Adding line to /etc/gdm/custom.conf for automatic login."
    echo "Adding line to /etc/gdm/custom.conf for automatic login." >> $log
    sed -i '/daemon]/aAutomaticLoginEnable=true' /etc/gdm/custom.conf 1>> $log 2>> $log
fi
if [ -n "$loginname" ]
then
    echo "File is already configured for user kiosk to autologin."
    echo "Aborting adding AutomaticLogin=kiosk!" >> $log
    grep AutomaticLogin /etc/gdm/custom.conf 1>> $log 2>> $log
else
    echo "Adding line to /etc/gdm/custom.conf for login user name."
    echo "Adding line to /etc/gdm/custom.conf for login user name." >> $log
    sed -i '/AutomaticLoginEnable=true/aAutomaticLogin=kiosk' /etc/gdm/custom.conf 1>> $log 2>> $log
fi
if [ -n "$el7" ]
then
    echo "Adding line to /etc/gdm/custom.conf for default X Session in EL7." >> $log
    echo "And creating session file for specific user in /var/lib/AccountsService/users/kiosk." >> $log
    sed -i '/AutomaticLogin=kiosk/aDefaultSession=xinit-compat.desktop' /etc/gdm/custom.conf 1>> $log 2>> $log
    touch /var/lib/AccountsService/users/kiosk
    chmod 644 /var/lib/AccountsService/users/kiosk
    echo "[User]" >> /var/lib/AccountsService/users/kiosk
    echo "Language=" >> /var/lib/AccountsService/users/kiosk
    echo "XSession=xinit-compat" >> /var/lib/AccountsService/users/kiosk
    echo "SystemAccount=false" >> /var/lib/AccountsService/users/kiosk
else
    echo "No need for default session in gdm.conf." >> $log
fi
echo "Operation done in 90%"
echo "Configuring system to start in graphical mode."
echo "Configuring system to start in graphical mode." >> $log
if [ -n "$el7" ]
then
echo "Current starting mode in EL7 (text or graphical is:" >> $log
systemctl get-default 1>> $log 2>> $log
echo "Setting up graphical boot in EL7." >> $log
systemctl set-default graphical.target 1>> $log 2>> $log
else
    gfxboot=$( cat /etc/inittab | grep id:5:initdefault: )
    if [ -n "$gfxboot" ]
    then
	echo "System is already configured for graphical boot."
	echo "Aborting configuring graphical boot. Already enabled!" >> $log
    else
	echo "Parsing /etc/inittab for graphical boot."
	echo "Parsing /etc/inittab for graphical boot." >> $log
        sed -i 's/id:1:initdefault:/id:5:initdefault:/g' /etc/inittab 1>> $log 2>> $log
        sed -i 's/id:2:initdefault:/id:5:initdefault:/g' /etc/inittab 1>> $log 2>> $log
        sed -i 's/id:3:initdefault:/id:5:initdefault:/g' /etc/inittab 1>> $log 2>> $log
        sed -i 's/id:4:initdefault:/id:5:initdefault:/g' /etc/inittab 1>> $log 2>> $log
    fi
fi

echo "Operation done in 93%"
echo "Disabling firstboot."
echo "Disabling firstboot." >> $log
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot
echo "Operation done in 94%"
echo "Generating Firefox browser startup config file."
echo "Generating firefox 12 browser startup config file." >> $log
echo "xset s off" > /home/kiosk/.xsession
echo "xset -dpms" >> /home/kiosk/.xsession
echo "matchbox-window-manager &" >> /home/kiosk/.xsession
echo "while true; do" >> /home/kiosk/.xsession
echo "rsync -qr --delete --exclude='.Xauthority' /opt/kiosk/ /home/kiosk/" >> /home/kiosk/.xsession
echo "firefox &" >> /home/kiosk/.xsession
echo "done" >> /home/kiosk/.xsession
chmod +x /home/kiosk/.xsession 1>> $log 2>> $log
ln -s /home/kiosk/.xsession /home/kiosk/.xinitrc
chown kiosk:kiosk /home/kiosk/.xsession 1>> $log 2>> $log
echo "Creating desktop profile session file."
echo "Creating .dmrc desktop profile session file." >> $log
echo "[Desktop]" > /home/kiosk/.dmrc
echo "Session=xinit-compat" >> /home/kiosk/.dmrc
echo "Language=$LANG" >> /home/kiosk/.dmrc
chown kiosk:kiosk /home/kiosk/.dmrc 1>> $log 2>> $log
echo "Operation done in 96%"
echo "Copying files for reseting every user restart." >> $log
echo "Copying files for reseting every user restart."
cp -r /home/kiosk /opt/
chmod 755 /opt/kiosk
chown kiosk:kiosk -R /opt/kiosk
echo "Operation done in 100%"
echo "Mission completed!"
echo "Installing printer drivers"

yum install -y wget 
wget https://github.com/hydrosIII/centos-7-kiosk/raw/master/tmx-cups-2.0.3.0.tar.gz
tar -xvf tmx-cups-2.0.3.0.tar.gz
yum install -y cups cups-client
cd tmx-cups
./install.sh

echo "Disable SELINUX"
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux 
echo "Disable Firewall"
systemctl disable firewalld

echo "If You got any comments or questions: marcin@marcinwilk.eu"
echo "Remember that after reboot it should start directly in KIOSK."
echo -e "\e[92mUse \e[93mCTRL+ALT+F2 \e[92mto go to console in KIOSK mode!!!"
echo -e "\e[39mThank You."
echo "Marcin Wilk"
echo "Job done!" >> $log
sleep 6
