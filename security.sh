#!/bin/bash


## This script is to make an outline to implement secure systems on a new linux system. 


# Enable automatic security updates
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Configure and enable firewall (UFW)
sudo apt-get install -y ufw
# COMMANDS TO USE WITH UFW:
    # sudo ufw enable //activates the firewall.
    # sudo ufw disable //deactvates the firewall
    # sudo ufw status //displays the current status and rules of UFW.
    # sudo ufw allow [port_number]  //allow traffic for port
    # sudo ufw allow [port_number]/[protocol]  //allow a specific protocal on port number 
    # sudo ufw allow from [ip_address] //allow traffic from specific IP address
    # sudo ufw deny [port_number] //deny traffic from port number
    # sudo ufw delete [rule_number] //delete a rule
    # sudo ufw reset //removes all rules and resets UFW to its default state.


# To ensure that any incoming traffic that is not explicitly allowed by a specific rule will be denied
sudo ufw default deny incoming 

# Ensure that any outgoing traffic from your system will be allowed by default
sudo ufw default allow outgoing

# Create a rule in the firewall that permits incoming traffic on the SSH port
sudo ufw allow ssh

# Activating firewall
sudo ufw enable

# Enforce strong password policies
sudo apt-get install -y libpam-pwquality
## HOW TO USE THIS IN DEPTH:
    # sudo nano /etc/security/pwquality.conf              // to edit the configuration file
    # minlen = 8                                          // Specifies the minimum length for user passwords
    # maxlen = 16                                         // maximum length for user passwords,
    # minclass = 3                                        // Requires passwords to contain characters from at least three different
    #                                                     // character classes (e.g., uppercase letters, lowercase letters, numbers, special characters).
    #
    # mindiff = 3                                         // Specifies the minimum number of characters that must be different from the previous password.
    # enforce_for_root = 1                                // Enforces the specified password policies for the root user, typically the superuser or administrator account
    # enforce_for_system_accounts = 1                     // Enforces the specified password policies for system accounts, which are usually used by the operating system and not regular users.
    # maxrepeat = 3                                       // Limits the number of consecutive identical characters allowed in a password to three
    # usercheck = 1                                       //  Enables additional checks on the username to ensure it is not part of the password or does not share too many similarities.


    # sudo nano /etc/pam.d/common-password                // Update the PAM configuration file 
    # password requisite pam_pwquality.so retry=3         // ensures that the pam_pwquality.so module is applied during the password management phase, and it enforces password quality rules
    # passwd                                              // test the password quality requirements by changing user password
    # sudo apt-get install -y libpam-tester               // To check the status of PAM modules, use the pamtester tool. If it's not installed, do this command
    # sudo pamtester common-password $USER change_pw      // test the PAM configuration



#!/bin/bash

# Dynamically determine the SSH service name
SSH_SERVICE=$(systemctl list-units --type=service | grep -oE 'ssh[a-zA-Z0-9._-]*\.service')


# Debug output
echo "SSH_SERVICE: $SSH_SERVICE"

# Check if the SSH service name is found
if [ -z "$SSH_SERVICE" ]; then
    echo "SSH service not found."
fi

# Find a line containing "pam_pwquality.so" in the /etc/security/pwquality.conf file, look for the "minlen=" setting, and replace its value with "12".
sudo sed -i "/pam_pwquality.so/s/\(minlen=\)[0-9]*/\\112/" /etc/security/pwquality.conf

# Change the configuration of the SSH daemon to allow password authentication (PasswordAuthentication yes)
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# TO USE SSH RSA KEY INSTEAD:
# ssh-keygen -t rsa -b 2048                   //-t rsa sets rsa key type, and -b 2048 sets the number of bits in the key
# After generating the key pair, you can copy the public key (~/.ssh/id_rsa.pub) 
# to the remote server where you want to authenticate. 
# ssh-copy-id user@remote_server              // ssh-copy-id command to automate the aforementioned process

# Restart the SSH service using the dynamically determined name
sudo systemctl restart "$SSH_SERVICE"

    # Check if the restart was successful
    if [ $? -ne 0 ]; then
        echo "Failed to restart SSH service: $SSH_SERVICE"
    else
        echo "SSH service ($SSH_SERVICE) restarted successfully."
    fi
fi


# Implement fail2ban for intrusion prevention
sudo apt-get install -y fail2ban

# Enable the Fail2Ban service to start automatically at boot time on a Linux system
sudo systemctl enable fail2ban 
    # COMMANDS TO USE WITH fail2ban:
           # sudo systemctl start fail2ban                      // Start the Fail2Ban service.
           # sudo systemctl stop fail2ban                       // Stop the Fail2Ban service.
           # sudo systemctl restart fail2ban                    // Restart the Fail2Ban service.
           # sudo systemctl status fail2ban                     // Check the status of the Fail2Ban service.
           # sudo systemctl disable fail2ban                    // disable fail2ban at boot
           # sudo fail2ban-client reload                        // Reload Fail2Ban Configuration
           # sudo fail2ban-client version                       // check fail2ban version
           # sudo fail2ban-client status                        // output will show the status of each jail, indicating 
           #                                                    // whether they are active or inactive. If a jail is active, it means 
           #                                                    // that Fail2Ban is actively monitoring the corresponding log files and taking action 
           #                                                    // against malicious activity
           #                                                    // May also display a list of IP addresses that are currently banned by Fail2Ban.
           # sudo fail2ban-client set JAIL unbanip IP_ADDRESS   // Replace JAIL with the name of the jail (e.g., sshd) and IP_ADDRESS with the IP address you want to unban.
           # sudo fail2ban-client get JAIL filter               // Display filters for jail

# Start the Fail2Ban service
sudo systemctl start fail2ban

# Enable and configure system logging
sudo apt-get install -y rsyslog

# Check if the rsyslog service is found
RSYSLOG_SERVICE=$(systemctl list-units --type=service | grep -oE 'rsyslog[a-zA-Z0-9._-]*\.service')

if [ -z "$RSYSLOG_SERVICE" ]; then
    echo "rsyslog service not found."
fi

# Enable the rsyslog service to start automatically at boot time on a Linux system
sudo systemctl enable "$RSYSLOG_SERVICE"

# Start the rsyslog service using the dynamically determined name
sudo systemctl restart "$RSYSLOG_SERVICE"

  # Check if the restart was successful
    if [ $? -ne 0 ]; then
        echo "Failed to restart SSH service: $SSH_SERVICE"
    else
        echo "SSH service ($SSH_SERVICE) restarted successfully."
    fi

# Enable and configure system logging
sudo systemctl enable rsyslog
    # COMMANDS TO GO WITH:
        # sudo systemctl start rsyslog                           // Start the rsyslog service.
        # sudo systemctl stop rsyslog                            // Stop the rsyslog service.
        # sudo systemctl restart rsyslog                         // Restart the rsyslog service.
        # sudo systemctl status rsyslog                          // Check the status of the rsyslog service.

# This command is configuring a systemd timer for snaps to automatically refresh, ensuring that the installed snaps receive updates regularly
echo 'refresh.timer: 4x daily' | sudo tee -a /etc/systemd/system/snapd.refresh.timer
    # AGGREGATE COMMANDS:
        # sudo systemctl daemon-reload                          // Reloads the systemd manager configuration to pick up changes.
        # sudo systemctl restart snapd.refresh.timer            // Restarts the timer for snap refreshes to apply the new configuration immediately.


# AppArmor is a Linux security module that implements mandatory access control (MAC) using security profiles. 
# These profiles define what resources (files, capabilities, network access, etc.) a specific application or process is 
# allowed to access.
sudo apt-get install -y apparmor apparmor-utils

# ensure that all the AppArmor profiles in the /etc/apparmor.d/ directory are actively enforced on the system.
# This step is important for the effective implementation of AppArmor's security measures.
sudo aa-enforce /etc/apparmor.d/*

# auditd package will be installed on your system, and the auditing system will be available
# for configuration and use. You can configure audit rules, define what events to monitor, and use tools 
# like ausearch to search and analyze audit logs.
sudo apt-get install -y auditd
    # COMMANDS THAT COME WITH auditd
        # sudo systemctl start auditd                            // start service
        # sudo systemctl stop auditd                             // stop service
        # sudo systemctl restart auditd                          // restart service
        # sudo systemctl status auditd                           // check status
        # sudo systemctl enable auditd                          // enable at boot
        # sudo systemctl disable auditd                         // disable at boot
        # sudo auditd --version                                 // display version
        # sudo auditctl -w /path/to/file -p permissions -k key_name      // configure audit rules
        # sudo auditctl -l                                      // display audit rules
        # sudo ausearch -k key_name                             // search audit logs
        # sudo aureport                                         // display audit statistics
        # sudo ausearch -f /path/to/log/file                    // view audit log file

# enable at boot
sudo systemctl enable auditd

# start service
sudo systemctl start auditd

# Disable unnecessary services
    # COMMANDS IN ORDER TO DISABLE/ STOP SERVICES:
        # sudo systemctl disable <service_name>
        # sudo systemctl stop <service_name>


# Install and configure antivirus/antimalware software

# ClamAV commands can scan files and directories for malware, update 
# the virus database, and configure other settings related to antivirus 
# protection
sudo apt-get install -y clamav

# manually update the virus databases for ClamAV on a Linux system
sudo freshclam
    # COMMANDS THAT COME WITH freshclam
        # sudo freshclam                                           // update virus database
        # freshclam --version                                      // display version
        # sudo freshclam --check                                   // check for updates
        # freshclam --help                                         // display help
        # sudo freshclam --config-file=/path/to/freshclam.conf     // update freshlam config
        # sudo freshclam --force                                   // force database update
        # sudo freshclam -d                                       // run freshclam in background



# clamav-freshclam service will be set to start automatically whenever the system boots up
sudo systemctl enable clamav-freshclam

# Check if clamav-daemon service exists
if systemctl list-unit-files | grep -q 'clamav-daemon.service'; then
    # Enable and start clamav-daemon service
    sudo systemctl enable clamav-daemon
    sudo systemctl start clamav-daemon
    echo "clamav-daemon service enabled and started."
else
    echo "Error: clamav-daemon service not found. Please check your installation."
fi

# Outputs the progress of the freshclam service.
sudo systemctl start clamav-freshclam

# Outputs the progress of the service startup. Once started, the ClamAV daemon will continue to run in the background,
# providing real-time scanning capabilities.
sudo systemctl start clamav-daemon


# Configure secure remote access (SSH):
    # These changes collectively enhance the security of your SSH server by preventing direct root login and disabling
    # password-based authentication. Always ensure that you have tested the changes and have an alternative way to access 
    # your system (such as an SSH key) before making these modifications to avoid getting locked out.
       # sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config                                           // It disables direct root login via SSH, improving security by requiring users to log in as a 
       #                                                                                                                        // regular user and then use su or sudo to switch to the root user
       # sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config                             // Disables password-based authentication, meaning that only public key authentication will be allowed
       # sudo systemctl restart ssh                                                                                             // Restarts the SSH service to apply the changes made to the configuration file (sshd_config).


# sudo ufw deny <port_number>/tcp                                         // Disable unnecessary network ports and services


echo "Security configurations applied successfully!"

# analyze processes and save the results in top.log
top -n 1 -b > top.log

# Display different users in the top.log file
echo "Different Users in top.log:"
awk '{if(NR>7)print $2}' top.log | sort | uniq

