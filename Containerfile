# Pull directly from official Fedora infrastructure
FROM quay.io/fedora/fedora-bootc:latest

# Install minimal KDE Plasma desktop and necessary library services
RUN dnf install -y \
    @kde-desktop-environment \
    sddm \
    cups \
    system-config-printer \
    firefox \
    && dnf clean all

# Enable KDE's Display Manager as default
RUN systemctl enable sddm

# Enable printing service
RUN systemctl enable cups

# Pre-configure Flathub for sandboxed applications (LibreOffice, etc.)
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
