#!/bin/bash

# Save the current directory path
current_dir=$(pwd)

# Function to change ownership of Lynis directory to root
change_ownership() {
    sudo chown -R root:root "$1"
}

# Clone Lynis repository
git clone https://github.com/CISOfy/lynis
cd lynis

# Change ownership of Lynis directory to root
change_ownership "$current_dir/lynis"

# Run Lynis audit with sudo
sudo ./lynis audit system

# Restore the original directory
cd "$current_dir"
