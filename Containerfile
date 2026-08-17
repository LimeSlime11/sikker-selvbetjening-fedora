# Pull directly from official Fedora infrastructure
FROM quay.io/fedora/fedora-bootc:latest

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# 1. Copy all '_system' overlay folders into root and set permissions on copied files inside root
RUN --mount=type=bind,source=features,target=/tmp/features \
    find /tmp/features -type d -name "_system" | while read -r sysdir; do \
        echo "📂 Copying system files from ${sysdir}..."; \
        cp -av "${sysdir}/." /; \
    done && \
    find /usr/libexec /usr/bin /usr/local/bin -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null || true

# 2. Run all '_build' scripts sequentially directly using bash
RUN --mount=type=bind,source=features,target=/tmp/features \
    --mount=type=cache,target=/var/cache \
    --mount=type=cache,target=/var/log \
    --mount=type=tmpfs,target=/tmp \
    find /tmp/features -type f -path "*/_build/*.sh" | sort | while read -r script; do \
        echo "🚀 Running build script: $(basename "$script")"; \
        bash "$script" || exit 1; \
    done