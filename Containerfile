# Pull directly from official Fedora infrastructure
FROM quay.io/fedora/fedora-bootc:latest

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# 1. Copy all '_system' overlay folders into root
RUN --mount=type=bind,source=features,target=/tmp/features \
    find /tmp/features -type d -name "_system" | while read -r sysdir; do \
        echo "📂 Copying system files from ${sysdir}..."; \
        cp -av "${sysdir}/." /; \
    done 

# 2. Make all '_build' scripts executable, then run them sequentially
RUN --mount=type=bind,source=features,target=/tmp/features \
    --mount=type=cache,target=/var/cache \
    --mount=type=cache,target=/var/log \
    --mount=type=tmpfs,target=/tmp \
    find /tmp/features -type f -path "*/_build/*.sh" -exec chmod +x {} + && \
    find /tmp/features -type f -path "*/_build/*.sh" | sort | while read -r script; do \
        echo "🚀 Running build script: $(basename "$script")"; \
        bash "$script" || exit 1; \
    done