#!/bin/bash


apt_update() {
  # Update package list
  apt update

  # Apt upgrade packages
  apt upgrade -y

  # Apt full upgrade 
  apt full-upgrade -y
}

# Function to generate GRUB password hash
generate_grub_password_hash() {
    echo "Enter your desired GRUB password:"
    read -s grub_password
    echo
    grub_password_hash=$(echo -e "$grub_password\n$grub_password" | grub-mkpasswd-pbkdf2 | grep "grub.pbkdf2.*" -o)
}

# configure GRUB with a password. 
# This helps prevent unauthorized access and alterations to the boot configuration
configure_grub() {
    sudo cp /etc/default/grub /etc/default/grub.backup

    sudo tee /etc/default/grub > /dev/null <<EOL
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=0
GRUB_DISABLE_RECOVERY=true
GRUB_DISABLE_SUBMENU=y
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_CMDLINE_LINUX=""
GRUB_PASSWORD="$grub_password_hash"
EOL

    sudo update-grub
}



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

# To comply with security standard of Lynis scan
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
echo "Copied /etc/fail2ban/jail.conf to /etc/fail2ban/jail.local"


# Main script
echo "This script will configure GRUB with a password to prevent altering boot configuration."
echo

generate_grub_password_hash


echo "Configuring GRUB..."
configure_grub

echo "GRUB has been configured with a password."

# Optional: Clean up sensitive information
unset grub_password
unset grub_password_hash

chmod +x suggested_fixes.sh
./suggested_fixes.sh



