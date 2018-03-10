#!/bin/bash

USER="liveuser"
OSNAME="Archman"

function initFunc() {
    set -e -u
    umask 022
}

function localeGenFunc() {
    # Set locales
    sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
    locale-gen
}

function setTimeZoneAndClockFunc() {
    # Timezone
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

    # Set clock to UTC
    hwclock --systohc --utc
}

function setDefaultsFunc() {
    #set default Browser
    export _BROWSER=firefox
    echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/environment
    echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/profile

    #Set Nano Editor
    export _EDITOR=nano
    echo "EDITOR=${_EDITOR}" >> /etc/environment
    echo "EDITOR=${_EDITOR}" >> /etc/profile
}

function initkeysFunc() {
    #Setup Pacman
    pacman-key --init archlinux
    pacman-key --populate archlinux
}

function fixHaveged(){
    systemctl start haveged
    systemctl enable haveged

    rm -fr /etc/pacman.d/gnupg
}

function fixPermissionsFunc() {
    #add missing /media directory
    mkdir -p /media
    chmod 755 -R /media

    #fix permissions
    chown root:root /
    chown root:root /etc
    chown root:root /etc/default
    chown root:root /usr
    chmod 755 /etc
}

function enableServicesFunc() {
    systemctl enable pacman-init.service lightdm.service choose-mirror.service
    systemctl enable org.cups.cupsd.service
    systemctl enable avahi-daemon.service
    systemctl enable vboxservice.service
    systemctl enable bluetooth.service
    systemctl enable haveged
    systemctl enable systemd-networkd.service
    systemctl enable systemd-resolved.service
    systemctl -fq enable NetworkManager
    systemctl mask systemd-rfkill@.service
    systemctl set-default graphical.target
}

function enableSudoFunc() {
    chmod 750 /etc/sudoers.d
    chmod 440 /etc/sudoers.d/g_wheel
    chown -R root /etc/sudoers.d
    chmod -R 755 /etc/sudoers.d
    echo "Enabled Sudo"
}
#
#function enableCalamaresAutostartFunc() {
#    #Enable Calamares Autostart
#    mkdir -p /home/liveuser/.config/autostart
#    ln -s /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
#    chmod +rx /home/liveuser/.config/autostart/calamares.desktop
#    chown liveuser /home/liveuser/.config/autostart/calamares.desktop
#}

#function enableCalamaresAutostartFunc() {
#    #Enable Calamares Desktop
#    ln -s /usr/share/applications/calamares.desktop /home/liveuser/Desktop/calamares.desktop
#    chmod +rx /home/liveuser/Desktop/calamares.desktop
#    chown liveuser /home/liveuser/Desktop/calamares.desktop
#}

function fixWifiFunc() {
    #Wifi not available with networkmanager
    su -c 'echo "" >> /etc/NetworkManager/NetworkManager.conf'
    su -c 'echo "[device]" >> /etc/NetworkManager/NetworkManager.conf'
    su -c 'echo "wifi.scan-rand-mac-address=no" >> /etc/NetworkManager/NetworkManager.conf'
}

function setDefaultCursorFunc() {
    #Set Default Cursor Theme
    rm -rf /usr/share/icons/Default
    ln -s /usr/share/icons/mac-rainbow-cursor/ /usr/share/icons/Default
}

function deleteObsoletePackagesFunc() {
    # delete obsolete network packages
    pacman -Rns --noconfirm openresolv netctl dhcpcd
}

function configRootUserFunc() {
    usermod -s /usr/bin/bash root
    echo 'export PROMPT_COMMAND=""' >> /root/.bashrc
    chmod 700 /root
}

function createLiveUserFunc () {
    # add groups autologin and nopasswdlogin (for lightdm autologin)
    groupadd -r autologin
    groupadd -r nopasswdlogin

    # add liveuser
    id -u $USER &>/dev/null || useradd -m $USER -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel,autologin,nopasswdlogin"
    passwd -d $USER
    echo 'Live User Created'
}

function editOrCreateConfigFilesFunc () {
    # Locale
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "LC_COLLATE=C" >> /etc/locale.conf

    # Vconsole
    echo "KEYMAP=us" > /etc/vconsole.conf
    echo "FONT=" >> /etc/vconsole.conf

    # Hostname
    echo "archman" > /etc/hostname

    sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
    sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
}

#function renameOSFunc() {
#    #Name Archman
#    osReleasePath='/usr/lib/os-release'
#    rm -rf $osReleasePath
#    touch $osReleasePath
#    echo 'NAME="'${OSNAME}'"' >> $osReleasePath
#    echo 'ID=archman' >> $osReleasePath
#    echo 'PRETTY_NAME="'${OSNAME}'"' >> $osReleasePath
#    echo 'ANSI_COLOR="0;35"' >> $osReleasePath
#    echo 'HOME_URL="http://archman.org"' >> $osReleasePath
#    echo 'SUPPORT_URL="http://archman.org/forum"' >> $osReleasePath
#    echo 'BUG_REPORT_URL="http://archman.org/forum"' >> $osReleasePath
#
#    arch=`uname -m`
#}

#function doNotDisturbTheLiveUserFunc() {
#    #delete old config file
#    pathToPerchannel="/home/$USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-notifyd.xml"
#    rm -rf $pathToPerchannel
#    #create a new file
#    touch $pathToPerchannel
#    echo '<?xml version="1.0" encoding="UTF-8"?>' >> $pathToPerchannel
#    echo '' >> $pathToPerchannel
#    echo '<channel name="xfce4-notifyd" version="1.0">' >> $pathToPerchannel
#    echo '  <property name="notify-location" type="uint" value="3"/>' >> $pathToPerchannel
#    echo '  <property name="do-not-disturb" type="bool" value="true"/>' >> $pathToPerchannel
#    echo '</channel>' >> $pathToPerchannel
#}

#function upgradeSystem() {
#    pacman -Syuu --noconfirm
#}

umaskFunc
initFunc
initkeysFunc
localeGenFunc
setTimeZoneAndClockFunc
editOrCreateConfigFilesFunc
configRootUserFunc
createLiveUserFunc
#doNotDisturbTheLiveUserFunc (enable on Xfce)
#renameOSFunc
setDefaultsFunc
enableSudoFunc
#enableCalamaresAutostartFunc
enableServicesFunc
deleteObsoletePackagesFunc
setDefaultCursorFunc
fixWifiFunc
fixPermissionsFunc
initkeysFunc
#upgradeSystem
#dconf update # apply dconf settings
