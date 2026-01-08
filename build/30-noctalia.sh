#!/usr/bin/bash

set -eoux pipefail

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Install Noctalia"

dnf5 install -y niri \
		niri-settings \
		xdg-desktop-portal-gtk \
		xdg-desktop-portal-gnome \
		gdm
copr_install_isolated "zhangyi6324/noctalia-shell" noctalia-shell

echo "Noctalia installed successfully"
echo "::endgroup::"

echo "::group:: Configure Session"

# Enable GDM
systemctl enable gdm

# Create systemd unit for Noctalia
mkdir -p /usr/lib/systemd/user
cat > /usr/lib/systemd/user/noctalia.service << 'NOCTALIA'
[Unit]
Description=Noctalia Shell Service
PartOf=graphical-session.target
Requisite=graphical-session.target
After=graphical-session.target

[Service]
ExecStart=noctalia-shell
Restart=on-failure
RestartSec=1

[Install]
WantedBy=graphical-session.target
NOCTALIA

systemctl --user add-wants niri.service noctalia.service

echo "Session configured"
echo "::endgroup::"

echo "::group:: Install Additional Utilities"

# Install additional utilities that work well with Noctalia
dnf5 install -y \
    ghostty \
    nautilus \
    cava \
    wlsunset \
    power-profiles-daemon \
    ddcutil
copr_install_isolated "lbarrys/cliphist" cliphist
copr_install_isolated "purian23/matugen" matugen

echo "Additional utilities installed"
echo "::endgroup::"

echo "Noctalia shell installation complete!"
echo "After booting, select 'Niri' session at the login screen"
