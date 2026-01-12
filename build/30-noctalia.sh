#!/usr/bin/bash

set -eoux pipefail

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Install Niri and Noctalia Shell"

dnf5 install -y niri \
		niri-settings \
		xdg-desktop-portal-gtk \
		xdg-desktop-portal-gnome \
		gdm

copr_install_isolated "zhangyi6324/noctalia-shell" noctalia-shell

# Configure default settings for Niri in /etc/skel
mkdir -p /etc/skel/.config/niri
cp /usr/share/doc/niri/default-config.kdl /etc/skel/.config/niri/config.kdl
sed -i 's/^spawn-at-startup \"waybar\"/\/\/&/' /etc/skel/.config/niri/config.kdl
mkdir -p /etc/skel/.config/quickshell
ln -s /usr/share/quickshell/noctalia-shell /etc/skel/.config/quickshell/noctalia-shell

# Create systemd unit for Noctalia
mkdir -p /usr/lib/systemd/user
cat > /usr/lib/systemd/user/noctalia.service << 'NOCTALIA'
[Unit]
Description=Noctalia Shell Service
BindsTo=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=qs -c noctalia-shell
Restart=on-failure
RestartSec=1

[Install]
WantedBy=graphical-session.target
NOCTALIA

systemctl --global add-wants niri.service noctalia.service

echo "Niri and Noctalia Shell installed successfully"
echo "::endgroup::"

echo "::group:: Configure Display Manager"

# Enable GDM
systemctl enable gdm
systemctl set-default graphical.target

echo "Display Manager configured"
echo "::endgroup::"

echo "::group:: Install Additional Utilities"

# Install additional utilities that work well with Noctalia
dnf5 install -y \
    nautilus \
    cava \
    wlsunset \
    ddcutil
copr_install_isolated "lbarrys/cliphist" cliphist
copr_install_isolated "purian23/matugen" matugen
copr_install_isolated "scottames/ghostty" ghostty

echo "Additional utilities installed"
echo "::endgroup::"

echo "Ornimegalonyx installation complete!"
echo "After booting, select 'Niri' session at the login screen"
