ARG BASE_BUILDER_IMAGE
ARG BASE_IMAGE

###############################################################################
# [STAGE] caddy-builder
###############################################################################
FROM caddy:${BASE_BUILDER_IMAGE} AS caddy-builder

RUN xcaddy build \
    # Build caddy binary with vulcain support
    --with github.com/dunglas/vulcain \
    --with github.com/dunglas/vulcain/caddy

###############################################################################
# [STAGE] caddy-base
###############################################################################
FROM caddy:${BASE_IMAGE} as caddy-base

RUN set -eux; \
    # Install OS packages
    apk add --no-cache tzdata;

# Copy caddy binary
COPY --link --from=caddy-builder /usr/bin/caddy /usr/bin/caddy
