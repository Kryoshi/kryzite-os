#!/bin/bash

set -ouex pipefail

### Enable COPR

### Installation

# Starship prompt
curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin

echo "eval \"\$(starship init bash)\"" >> /etc/bashrc

# Generic
PACKAGES_INSTALL=(
  "code"
  "git"
)
for PACKAGE in ${PACKAGES_INSTALL[@]}; do
  dnf5 install -y "$PACKAGE"
done

# Github CLI
dnf5 install -y gh --repo gh-cli

# Docker
PACKAGES_INSTALL_DOCKER=(
  "docker-ce"
  "docker-ce-cli"
  "containerd.io"
  "docker-buildx-plugin"
  "docker-compose-plugin"
)
for PACKAGE in ${PACKAGES_INSTALL_DOCKER[@]}; do
  dnf5 install -y "$PACKAGE"
done

# Gnome extensions
EXTENSIONS=(
  "gnome-shell-extension-pop-shell"
  # "gnome-shell-extension-blur-my-shell"
  # "gnome-shell-extension-caffeine"
  # "gnome-shell-extension-appindicator"
  "gnome-shell-extension-vertical-workspaces"
  "gnome-shell-extension-system-monitor"
  "gnome-shell-extension-frippery-move-clock"
)
for EXTENSION in ${EXTENSIONS[@]}; do
  dnf5 install -y "$EXTENSION"
done

# Remove packages
PACKAGES_REMOVE=(
  "waydroid"
  "input-remapper"
  "webapp-manager"
  "rom-properties-gtk3"
)
for PACKAGE in ${PACKAGES_REMOVE[@]}; do
  dnf5 remove -y "$PACKAGE"
done

# Remove bazzite extras
rm -rf usr/share/applications/Waydroid
rm -f usr/share/applications/bazzite-documentation.desktop
rm -f usr/share/applications/bazzite-steam-bpm.desktop
rm -f usr/share/applications/discourse.desktop
rm -f usr/share/applications/system-update.desktop
rm -f usr/share/applications/waydroid-container-restart.desktop
rm -f usr/share/applications/bbrew.desktop

### Services

#Enable docker
systemctl enable docker