# Start from the official Fedora Kinoite base image
FROM quay.io/fedora-ostree-desktops/kinoite:latest

# Install system-level utilities (e.g., cups for printing, extra drivers)
RUN dnf install -y \
    cups \
    system-config-printer \
    vim \
    && dnf clean all

# Copy custom configurations (e.g., KDE Kiosk settings or custom scripts)
# COPY config/kdeglobals /etc/xdg/kdeglobals

# Ensure Flatpak remotes are configured for users
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
