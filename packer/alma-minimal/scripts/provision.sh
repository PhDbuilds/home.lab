#!/bin/bash
# provision.sh — Golden image provisioning
# Run by Packer after kickstart install completes
set -euo pipefail

echo "=== [1/7] Updating system ==="
dnf update -y

echo "=== [2/7] Installing base tools ==="
dnf install -y \
    vim \
    curl \
    wget \
    git \
    tmux \
    tree \
    unzip \
    tar \
    bind-utils \
    net-tools \
    traceroute \
    nmap-ncat \
    bash-completion \
    rsync \
    lsof \
    jq \
    cloud-init \
    cloud-utils-growpart \
    qemu-guest-agent

# qemu-guest-agent: required for Proxmox to read VM IPs, do graceful
# shutdowns, and fully support cloud-init. Essentially mandatory.

echo "=== [3/7] Creating ansible user ==="
useradd -m -s /bin/bash ansible
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 440 /etc/sudoers.d/ansible

# Set up SSH key from the file Packer copied in
mkdir -p /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
cp /tmp/ansible_authorized_key.pub /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
rm -f /tmp/ansible_authorized_key.pub

echo "=== [4/7] Hardening SSH ==="
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^#\?AllowAgentForwarding.*/AllowAgentForwarding no/' /etc/ssh/sshd_config

echo "=== [5/7] Enabling services ==="
systemctl enable qemu-guest-agent
systemctl enable cloud-init
systemctl enable firewalld

echo "=== [6/7] Configuring firewall ==="
# Ensure SSH is permitted (should already be from kickstart, but be explicit)
firewall-offline-cmd --add-service=ssh 2>/dev/null || true

echo "=== [7/7] Cleaning up for template ==="
# Lock root account
passwd -l root

# Clean package cache
dnf clean all
rm -rf /var/cache/dnf/*

# Remove machine-specific identifiers so each clone gets unique ones
rm -f /etc/machine-id
touch /etc/machine-id
truncate -s 0 /etc/hostname

# Remove SSH host keys — regenerated on first boot of each clone
rm -f /etc/ssh/ssh_host_*

# Reset cloud-init so it runs fresh on each clone
cloud-init clean --logs --seed

# Clear logs
truncate -s 0 /var/log/messages
truncate -s 0 /var/log/secure
truncate -s 0 /var/log/cron
rm -f /var/log/audit/audit.log
journalctl --vacuum-time=0

# Clear temp and build artifacts
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f /root/ks-post.log
rm -f /root/anaconda-ks.cfg
rm -f /root/original-ks.cfg

# Force SELinux relabel on next boot so new files get correct contexts
touch /.autorelabel

# Clear shell history
unset HISTFILE
rm -f /root/.bash_history

echo "=== Provisioning complete ==="
