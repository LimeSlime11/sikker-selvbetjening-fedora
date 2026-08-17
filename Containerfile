# Pull directly from official Fedora infrastructure
FROM quay.io/fedora/fedora-bootc:latest

# Switch shell to bash with strict error handling
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# 1. Enable DNF parallel downloads and disable documentation to speed up installs & save space
# 2. Install minimal KDE Plasma desktop and necessary library services in a single cached layer
RUN echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf && \
    echo "fastestmirror=True" >> /etc/dnf/dnf.conf && \
    dnf install -y --nodocs \
        @kde-desktop-environment \
        sddm \
        cups \
        system-config-printer \
        firefox && \
    dnf clean all

# Enable services
RUN systemctl enable cups && \
    systemctl enable --force sddm

# Pre-configure Flathub for sandboxed applications (LibreOffice, etc.)
RUN flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
