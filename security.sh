#!/bin/bash

# Lynis recommended security configurations

# Log file for script output
LOG_FILE="/var/log/lynis_security_config.log"

# Function to log and print errors
log_error() {
  echo "Error: $1" | tee -a "$LOG_FILE"
  exit 1
}

# Prompt for GRUB password
read -s -p "Enter GRUB superuser password: " grub_password

# Install libpam-tmpdir for setting $TMP and $TMPDIR for PAM sessions
sudo apt-get install -y libpam-tmpdir >> "$LOG_FILE" 2>&1 || log_error "Failed to install libpam-tmpdir"

# Install apt-listbugs for displaying a list of critical bugs prior to each APT installation
sudo apt-get install -y apt-listbugs >> "$LOG_FILE" 2>&1 || log_error "Failed to install apt-listbugs"

# Install needrestart to determine which daemons are using old versions of libraries and need restarting
sudo apt-get install -y needrestart

# Install fail2ban to automatically ban hosts that commit multiple authentication errors
sudo apt-get install -y fail2ban

# Set a password on GRUB boot loader to prevent altering boot configuration
echo "set superusers=\"root\"\npassword_pbkdf2 root $grub_password" | sudo tee -a /etc/grub.d/40_custom >> "$LOG_FILE" 2>&1 \ || log_error "Failed to set GRUB password"
sudo update-grub >> "$LOG_FILE" 2>&1 || log_error "Failed to update GRUB"

# Consider hardening system services by running '/usr/bin/systemd-analyze security SERVICE' for each service
# This can be done manually based on Lynis recommendations

# If not required, explicitly disable core dumps in /etc/security/limits.conf
echo '* hard core 0' | sudo tee -a /etc/security/limits.conf

# Configure password hashing rounds in /etc/login.defs
# Replace 'number_of_rounds' with the desired number, e.g., 10000
echo 'Rounds number_of_rounds' | sudo tee -a /etc/login.defs

# Install a PAM module for password strength testing like pam_cracklib or pam_passwdqc
sudo apt-get install -y libpam-cracklib

# When possible, set expiration dates for all password-protected accounts
# Example: sudo passwd -e <username>

# Configure minimum password age in /etc/login.defs
echo 'PASS_MIN_DAYS 7' | sudo tee -a /etc/login.defs

# Configure maximum password age in /etc/login.defs
echo 'PASS_MAX_DAYS 90' | sudo tee -a /etc/login.defs

# Default umask in /etc/login.defs could be more strict like 027
echo 'UMASK 027' | sudo tee -a /etc/login.defs

# To decrease the impact of a full /home, /tmp, /var file system, place each on a separate partition
# This should be done during the system installation or partitioning

# Disable drivers like USB storage when not used
# Check and disable unused USB storage drivers

# Disable drivers like firewire storage when not used
# Check and disable unused firewire storage drivers

# Check DNS configuration for the DNS domain name
# Review and update DNS configuration if needed

# Install debsums utility for the verification of packages with a known good database
sudo apt-get install -y debsums

# Update your system with apt-get update, apt-get upgrade, apt-get dist-upgrade, and/or unattended-upgrades
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo unattended-upgrades

# Install package apt-show-versions for patch management purposes
sudo apt-get install -y apt-show-versions

# Consider using a tool to automatically apply upgrades
# This can be a manual process based on system requirements

# Determine if protocols 'dccp', 'sctp', 'rds', 'tipc' are really needed on this system
# Review and disable unnecessary protocols in the system configuration

# Access to CUPS configuration could be more strict
# Review and update CUPS (Common UNIX Printing System) configuration for stricter access

# Install Apache mod_evasive to guard the webserver against DoS/brute force attempts
sudo apt-get install -y libapache2-mod-evasive

# Install Apache modsecurity to guard the webserver against web application attacks
sudo apt-get install -y libapache2-mod-security2

# Enable logging to an external logging host for archiving purposes and additional protection
# Configure syslog/rsyslog to forward logs to an external server

# Check what deleted files are still in use and why
# Investigate and remove any deleted files still in use

# Add a legal banner to /etc/issue to warn unauthorized users
echo 'Your legal warning message' | sudo tee /etc/issue

# Add a legal banner to /etc/issue.net to warn unauthorized users
echo 'Your legal warning message' | sudo tee /etc/issue.net

# Enable process accounting
sudo apt-get install -y acct
sudo systemctl enable acct
sudo systemctl start acct

# Enable sysstat to collect accounting
sudo apt-get install -y sysstat >> "$LOG_FILE" 2>&1 || log_error "Failed to install sysstat"
sudo systemctl enable sysstat >> "$LOG_FILE" 2>&1 || log_error "Failed to enable sysstat service"
sudo systemctl start sysstat >> "$LOG_FILE" 2>&1 || log_error "Failed to start sysstat service"

# Enable auditd to collect audit information
sudo systemctl enable auditd
sudo systemctl start auditd

# Install a file integrity tool to monitor changes to critical and sensitive files
sudo apt-get install -y aide

# Determine if automation tools are present for system management
# Manually check and verify the presence of automation tools

# Consider restricting file permissions
# Review and adjust file permissions based on Lynis recommendations

# One or more sysctl values differ from the scan profile and could be tweaked
# Review and adjust sysctl values as per Lynis recommendations

# Harden compilers like restricting access to root user only
# Review and adjust compiler access based on Lynis recommendations

# Harden the system by installing at least one malware scanner
# Install a malware scanner like rkhunter, chkrootkit, or OSSEC

# Lynis recommended security configurations end

echo "Lynis recommended security configurations applied successfully!"

echo "Installing tools to help utilize Copy and Paste"

sudo apt install open-vm-tools-desktop
