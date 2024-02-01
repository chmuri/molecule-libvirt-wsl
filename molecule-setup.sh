#!/bin/bash

# Function to add lines to a specified RC file
add_lines_to_rc_file() {
    rc_file="$1"
    lines=("export VAGRANT_DEFAULT_PROVIDER=libvirt" "export VAGRANT_PREFERRED_PROVIDERS=libvirt")

    # Iterate over the lines to add
    for line in "${lines[@]}"; do
        # Check if the line already exists in the RC file
        grep -qF "$line" "$rc_file" || echo "$line" >> "$rc_file"
    done
}

# Check and add lines to .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    add_lines_to_rc_file "$HOME/.bashrc"
fi

# Check and add lines to .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    add_lines_to_rc_file "$HOME/.zshrc"
fi
rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg
# Download and add HashiCorp GPG key for package verification
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository to the package manager
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package manager
sudo apt update

# Install necessary packages using apt
sudo apt -y install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils vagrant libvirt-dev virt-manager

# Install the Vagrant libvirt plugin
vagrant plugin install vagrant-libvirt

# Add the user to kvm and libvirt groups
sudo usermod --append --groups kvm,libvirt "${USER}"

# Set ownership and permissions for /dev/kvm
sudo chown root:kvm /dev/kvm
sudo chmod 660 /dev/kvm

# Restart libvirtd and virtlogd services
sudo systemctl restart libvirtd
sudo systemctl restart virtlogd
