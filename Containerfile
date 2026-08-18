# Build-time feature context
FROM scratch AS ctx
COPY features /features


# Fedora bootc base
FROM quay.io/fedora/fedora-bootc:43


### 1. DISTRIBUTE SYSTEM FILES

COPY --from=ctx /features/*/_system/ /


### 2. RUN BUILD SCRIPTS

RUN --mount=type=bind,from=ctx,source=/features,target=/tmp/features \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    find /tmp/features/ \
        -type f \
        -path "*/_build/*.sh" \
        | awk -F/ '{print $NF, $0}' \
        | sort -n \
        | cut -d' ' -f2- \
        | while read -r script; do \
            echo "🚀 Running feature script: $(basename "$script")"; \
            bash "$script" || exit 1; \
        done


### 3. GLOBAL CONFIGURATION

RUN ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime && \
    echo "Europe/Copenhagen" > /etc/timezone

RUN chmod 755 /usr/libexec/*.sh /usr/libexec/*.py 2>/dev/null || true

RUN dconf update


### 4. VALIDATE

RUN bootc container lint