#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_FILE="${SCRIPT_DIR}/packages.txt"
FLATPAK_FILE="${SCRIPT_DIR}/flatpaks.txt"

# 1. Configure DNF5
cat >> /etc/dnf/dnf.conf <<'EOF'
max_parallel_downloads=10
fastestmirror=True
EOF

# 2. Install RPM packages
if [[ -f "${PKG_FILE}" ]]; then
    echo "📦 Installing essential RPM packages..."

    mapfile -t packages < <(
        grep -vE '^[[:space:]]*(#|$)' "${PKG_FILE}"
    )

    if ((${#packages[@]})); then
        dnf5 install -y --nodocs "${packages[@]}"
    fi

    dnf5 clean all

    echo "  ✓ Base RPM installation complete."
fi

# 3. Enable system services
systemctl enable cups.service
systemctl enable sddm.service

# 4. Configure Flathub
echo "🌐 Setting up Flathub remote..."

flatpak remote-add \
    --if-not-exists \
    --system \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# 5. Install Flatpak applications
if [[ -f "${FLATPAK_FILE}" ]]; then
    echo "📦 Pre-installing Flatpak applications..."

    while IFS= read -r app; do
        echo "  → Installing Flatpak: ${app}"
        flatpak install -y --system flathub "${app}"
    done < <(
        grep -vE '^[[:space:]]*(#|$)' "${FLATPAK_FILE}"
    )

    echo "  ✓ Flatpak installation complete."
fi