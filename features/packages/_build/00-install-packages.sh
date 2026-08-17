#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_FILE="${SCRIPT_DIR}/packages.txt"
FLATPAK_FILE="${SCRIPT_DIR}/flatpaks.txt"

# 1. Enable DNF speed optimizations
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
echo "fastestmirror=True" >> /etc/dnf/dnf.conf

# 2. Install essential RPM base packages
if [ -f "${PKG_FILE}" ]; then
    echo "📦 Installing essential RPM packages..."
    dnf5 install -y --nodocs --pkg-file "${PKG_FILE}"
    dnf5 clean all
    echo "  ✓ Base RPM installation complete."
fi

# 3. Enable system services
systemctl enable cups
systemctl enable --force sddm

# 4. Add Flathub repository and pre-install user applications
echo "🌐 Setting up Flathub remote..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

if [ -f "${FLATPAK_FILE}" ]; then
    echo "📦 Pre-installing Flatpak applications..."
    grep -v '^#' "${FLATPAK_FILE}" | grep -v '^\s*$' | while read -r app; do \
        echo "  → Installing Flatpak: ${app}"
        flatpak install -y --system flathub "${app}"
    done
    echo "  ✓ Flatpak installation complete."
fi