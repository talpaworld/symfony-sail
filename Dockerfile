# Build args used to fetch base images
ARG CADDY_VERSION=2
ARG PHP_VERSION=8.2
ARG MARIADB_VERSION=10.9
ARG NODE_VERSION=lts

# Build args used to install tools and run commands
ARG COMPOSER_AUTH=
ARG COMPOSER_VERSION=lts
ARG KNOWN_HOSTS="bitbucket.org github.com gitlab.com"

###############################################################################
### [STAGE] composer
###############################################################################
FROM composer:${COMPOSER_VERSION} as composer

###############################################################################
# [STAGE] assets-builder
###############################################################################
FROM node:${NODE_VERSION}-alpine as assets-builder
WORKDIR /app

# Copy metadata and configuration files for npm, Yarn, Webpack Encore and Babel
COPY --link package.jso[n] package-lock.jso[n] yarn.loc[k] .npmr[c] .yarnr[c] webpack.config.* babel.config.* .babelr[c] .babelrc.* ./

RUN set -eux; \
    # Install dependencies using npm or Yarn
    if [ -f package.json ]; then \
        if [ -f package-lock.json ]; then \
            npm ci; \
        else \
            if [ -f yarn.lock ]; then \
                yarn install --no-progress --frozen-lockfile; \
            else \
                npm install --no-progress; \
            fi; \
        fi; \
    fi;

# We need to copy the entire source tree without making assumptions. In fact,
# many frontend libraries like Tailwind CSS scans source files and extract
# CSS class names in order to purge them.
COPY --link . .

RUN set -eux; \
    # Build assets using Webpack Encore
    if [ -f node_modules/.bin/encore ]; then \
        node_modules/.bin/encore production; \
    fi;

###############################################################################
# [STAGE] php-prod
###############################################################################
FROM gremo/symfony-sail-php-prod:${PHP_VERSION} AS php-prod
WORKDIR /var/www/html

ARG COMPOSER_AUTH
ARG KNOWN_HOSTS

# Copy composer binary
COPY --link --from=composer /usr/bin/composer /usr/local/bin/

# Copy PHP/FPM project configuration file(s)
COPY --link config/docker/php/php.ini ${PHP_INI_DIR}/conf.d/zz0-php.ini
COPY --link config/docker/php/php.prod.in[i] ${PHP_INI_DIR}/conf.d/zz1-php.prod.ini
COPY --link config/docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Copy files needed for dependencies installation
COPY --link composer.* symfony.* ./

RUN set -eux; \
    # Get known hosts SSH keys
    if [ ! -z "${KNOWN_HOSTS}" ]; then \
        mkdir -p -m 0700 ~/.ssh; \
        echo "${KNOWN_HOSTS}" | sed 's/ /\n/g' | xargs ssh-keyscan -H > ~/.ssh/known_hosts; \
    fi; \
    # Install Composer dependencies
    if [ -f composer.json ]; then \
        composer install --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress; \
    fi

# Copy the entire source tree
COPY --link . .

RUN set -eux; \
    # Composer autoload, env dump and post-install-cmd
    if [ -f composer.json ]; then \
        composer dump-autoload --no-dev --classmap-authoritative; \
        if composer list --raw | grep -q dump-env; then \
            composer dump-env prod; \
        fi; \
        if composer run-script --list | grep -q post-install-cmd; then \
            composer run-script --no-dev post-install-cmd; \
        fi; \
    fi; \
    # Create PHP preload configuration
    if [ -f config/preload.php ]; then \
        echo "opcache.preload_user = root" >> ${PHP_INI_DIR}/conf.d/preload.ini; \
        echo "opcache.preload = /var/www/html/config/preload.php" >> ${PHP_INI_DIR}/conf.d/preload.ini; \
    fi; \
    # Cleanup
    composer clear-cache; \
    rm -rf config/docker/; \
    rm -f /usr/bin/install-php-extensions

# Copy all public resources from the assets builder stage, this is needed
# because of the metadata files (i.e. manifest.json from Webpack Encore)
# used by Symfony at runtime.
COPY --link --from=assets-builder /app/publi[c]/ public/

###############################################################################
# [STAGE] php-dev
###############################################################################
FROM gremo/symfony-sail-php-dev:${PHP_VERSION} AS php-dev

ARG NODE_VERSION

# Copy composer binary
COPY --link --from=composer /usr/bin/composer /usr/local/bin/

RUN set -eux; \
    # Install Node.js, update npm and install Yarm
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -; \
    apt-get install -y --no-install-recommends nodejs; \
    npm update -g npm; \
    npm install -g yarn; \
    # Cleanup
    rm -rf /root/.npm; \
    rm -rf /var/lib/apt/lists/*

###############################################################################
# [STAGE] caddy-prod
###############################################################################
FROM gremo/symfony-sail-caddy-base:${CADDY_VERSION} as caddy-prod
WORKDIR /srv

# Copy Caddy configuration
COPY --link config/docker/caddy/Caddyfile /etc/caddy/Caddyfile

# Copy public resources from the builder stage
COPY --link --from=assets-builder /app/publi[c]/ public/

###############################################################################
# [STAGE] caddy-dev
###############################################################################
FROM gremo/symfony-sail-caddy-base:${CADDY_VERSION} as caddy-dev

###############################################################################
# [STAGE] mariadb-dev
###############################################################################
FROM gremo/symfony-sail-mariadb-base:${MARIADB_VERSION} as mariadb-dev

###############################################################################
# [STAGE] mariadb-prod
###############################################################################
FROM gremo/symfony-sail-mariadb-base:${MARIADB_VERSION} as mariadb-prod

# Copy MariaDB configuration file(s)
COPY --link config/docker/mariadb/mariadb.cnf /etc/mysql/mariadb.conf.d/990-mariadb.cnf
COPY --link config/docker/mariadb/mariadb.prod.cn[f] /etc/mysql/mariadb.conf.d/991-mariadb.prod.cnf
