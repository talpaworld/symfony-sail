ARG BASE_IMAGE
ARG EXTENSIONS="apcu gd intl opcache pdo_mysql pdo_pgsql xsl zip"
ARG EXTENSIONS_PROD=""
ARG EXTENSIONS_DEV="xdebug"

###############################################################################
# [STAGE] php-base
###############################################################################
FROM php:${BASE_IMAGE} as php-base

ARG EXTENSIONS
ARG EXTENSIONS_PROD
ARG EXTENSIONS_DEV

# See https://getcomposer.org/doc/03-cli.md#environment-variables
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

RUN set -eux; \
    # Configure OS
    mkdir -p /var/run/php; \
    # Install OS packages
    apt-get update; \
    apt-get install -y --no-install-recommends acl git openssh-client unzip; \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

# Copy the base configuration
COPY --link php.ini /usr/local/etc/php/conf.d/symfony-sail.ini

# Copy the new entrypoint
COPY --link docker-php-entrypoint /usr/local/bin/

# Copy install-php-extensions binary
COPY --link --from=mlocati/php-extension-installer:latest /usr/bin/install-php-extensions /usr/local/bin/

RUN set -eux; \
    chmod +x /usr/local/bin/docker-php-entrypoint; \
    ## Install extensions
    if [ ! -z "${EXTENSIONS}" ]; then \
        install-php-extensions ${EXTENSIONS}; \
    fi; \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

###############################################################################
# [STAGE] php-prod
###############################################################################
FROM php-base AS php-prod

# Copy the base configuration
COPY --link php.prod.ini /usr/local/etc/php/conf.d/symfony-sail.prod.ini

RUN set -eux; \
    # Copy base configuration file
    cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini; \
    # Install production-only extensions
    if [ ! -z "${EXTENSIONS_PROD}" ]; then \
        install-php-extensions ${EXTENSIONS_PROD}; \
    fi; \
    # Cleanup
    rm -rf /var/lib/apt/lists/*

###############################################################################
# [STAGE] php-dev
###############################################################################
FROM php-base AS php-dev

RUN set -eux; \
    # Copy base configuration file
    cp ${PHP_INI_DIR}/php.ini-development ${PHP_INI_DIR}/php.ini; \
    # Install development-only extensions
    if [ ! -z "${EXTENSIONS_DEV}" ]; then \
        install-php-extensions ${EXTENSIONS_DEV}; \
    fi; \
    # Cleanup
    rm -rf /var/lib/apt/lists/*
