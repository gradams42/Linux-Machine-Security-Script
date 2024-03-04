#!/bin/bash

# Reboot system
echo "Rebooting system..."
reboot

# Check and fix apt-get issues
echo "Running apt-get check..."
apt-get check

# Update system
echo "Updating system with apt-get..."
apt-get update
apt-get upgrade
apt-get dist-upgrade
unattended-upgrades

# Install debsums utility
echo "Installing debsums utility..."
apt-get install debsums

# Verify package database consistency
echo "Verifying package database consistency..."
apt-get check

# Install apt-show-versions
echo "Installing apt-show-versions..."
apt-get install apt-show-versions

# Harden GRUB bootloader
echo "Setting password on GRUB bootloader..."
# Replace 'your_grub_password' with the actual password
grub-mkpasswd-pbkdf2 | tee -a /etc/grub.d/40_custom
echo 'set superusers="root"' | tee -a /etc/grub.d/40_custom
echo 'password_pbkdf2 root <your_grub_password>' | tee -a /etc/grub.d/40_custom
update-grub

# Harden system services
echo "Hardening system services..."
systemd-analyze security SERVICE

# Disable core dump if not required
echo "Disabling core dump in /etc/security/limits.conf..."
echo "* hard core 0" >> /etc/security/limits.conf

# Configure password hashing rounds
echo "Configuring password hashing rounds in /etc/login.defs..."
# Replace 'your_password_rounds' with the desired value
echo "ENCRYPT_METHOD SHA512" >> /etc/login.defs
echo "SHA_CRYPT_MIN_ROUNDS <your_password_rounds>" >> /etc/login.defs

# Set password expiration for all accounts
echo "Setting password expiration for all accounts..."
chage -l <username> # Replace '<username>' with an actual username
chage -M 90 -m 7 -W 14 <username> # Replace '<username>' with an actual username

# Configure minimum and maximum password age
echo "Configuring minimum and maximum password age in /etc/login.defs..."
# Replace '<min_age>' and '<max_age>' with desired values
echo "PASS_MIN_DAYS <min_age>" >> /etc/login.defs
echo "PASS_MAX_DAYS <max_age>" >> /etc/login.defs

# Configure default umask
echo "Configuring default umask in /etc/login.defs..."
echo "UMASK 027" >> /etc/login.defs

# Move /home, /tmp, and /var to separate partitions
echo "Moving /home, /tmp, and /var to separate partitions..."
# Assuming you have created separate partitions for these
# Update /etc/fstab accordingly

# Disable USB storage and firewire storage drivers
echo "Disabling USB storage and firewire storage drivers..."
echo "blacklist usb-storage" >> /etc/modprobe.d/blacklist.conf
echo "blacklist firewire-core" >> /etc/modprobe.d/blacklist.conf

# Check DNS configuration
echo "Checking DNS configuration..."
cat /etc/resolv.conf

# Check iptables rules
echo "Checking iptables rules..."
iptables -L --line-numbers

# Install Apache mod_evasive and modsecurity
echo "Installing Apache mod_evasive and modsecurity..."
apt-get install libapache2-mod-evasive libapache2-mod-security2

# Harden SSH configuration
echo "Hardening SSH configuration..."
# Edit /etc/ssh/sshd_config based on the provided details

# Enable logging to an external logging host
echo "Enabling logging to an external logging host..."
# Edit /etc/rsyslog.conf or equivalent

# Check deleted files still in use
echo "Checking deleted files still in use..."
lsof | grep '(deleted)'

# Add legal banners
echo "Adding legal banners to /etc/issue and /etc/issue.net..."
echo "Your legal banner" > /etc/issue
echo "Your legal banner" > /etc/issue.net

# Enable process accounting
echo "Enabling process accounting..."
systemctl enable acct

# Enable sysstat
echo "Enabling sysstat..."
systemctl enable sysstat

# Disable audit daemon or define rules
echo "Disabling audit daemon or defining rules..."
systemctl disable auditd

# Install file integrity tool
echo "Installing file integrity tool..."
apt-get install aide

# Check for automation tools
echo "Checking for automation tools..."
# Check installed automation tools

# Confirm freshclam configuration
echo "Confirming freshclam configuration..."
# Update freshclam.conf as needed

# Restrict file permissions
echo "Restricting file permissions..."
# Use chmod to change file permissions based on screen output or log file

# Tweak sysctl values
echo "Tweaking sysctl values..."
# Update sysctl values based on the provided details

# Harden compilers
echo "Hardening compilers..."
echo "root: /usr/bin/gcc" > /etc/security/limits.conf

# Print completion message
echo "Script completed. Please review any manual changes needed."
