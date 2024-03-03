#!/bin/bash

# Function to install a package
install_package() {
    local package_name="$1"
    sudo apt-get install -y "$package_name"
    echo "Installed $package_name"
}

# Install ModemManager package (MEDIUM)
install_package "modemmanager"

# Install NetworkManager package (EXPOSED)
install_package "network-manager"

# Install accounts-daemon package (MEDIUM)
install_package "accountsservice"

# Install alsa-state package (UNSAFE)
install_package "alsa-utils"

# Install anacron package (UNSAFE)
install_package "anacron"

# Install auditd package (EXPOSED)
install_package "auditd"

# Install avahi-daemon package (UNSAFE)
install_package "avahi-daemon"

# Install clamav-daemon package (UNSAFE)
# install_package "clamav-daemon"

# Install colord package (EXPOSED)
install_package "colord"

# Install cron package (UNSAFE)
install_package "cron"

# Install cups-browsed package (UNSAFE)
install_package "cups-browsed"

# Install cups package (UNSAFE)
install_package "cups"

# Install dbus package (UNSAFE)
# install_package "dbus"

# Install emergency package (UNSAFE)
install_package "emergency"

# Install fail2ban package (UNSAFE)
# install_package "fail2ban"

# Install fwupd package (EXPOSED)
install_package "fwupd"

#Instal list-bugs package
install_package apt-listbugs
