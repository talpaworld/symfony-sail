# Symfony Sail

> **Warning**: *this project is still in development and still not ready for production. Use it for testing purposes and suggest changes and improvements.*

<p align="center">
  <img alt="Banner" src="https://user-images.githubusercontent.com/1532616/230768406-97023b97-e254-45e4-88e9-7323095f7062.png" />
</p>

<p align="center">
  <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/gremo/symfony-sail">
  <img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/gremo/symfony-sail/build-push-images.yaml">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/gremo/symfony-sail">
  <img alt="GitHub license" src="https://img.shields.io/github/license/gremo/symfony-sail">
  <a href="https://paypal.me/marcopolichetti" target="_blank">
    <img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg"/>
  </a>
</p>

<p align="center">
  A complete <b>development & production environment</b> for Symfony 5 and 6 projects, powered by Docker.
</p>

This project is largely inspired by the great work of [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker). It comes with fewer features, but it should be easier to use for most users. And comes with assets building support, Webpack Encore and MariaDB.

💫 Main **features**:

- ✅ Visual Studio Code [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) support
- ✅ Production-ready, automatic HTTPS, HTTP/2 and [Vulcain](https://vulcain.rocks) support
- ✅ PHP OPcache [preloading](https://www.php.net/manual/en/opcache.preloading.php) support
- ✅ Assets building and [Webpack Encore](https://github.com/symfony/webpack-encore) support
- ✅ [MariaDB](https://mariadb.com/products/community-server) DBMS

🔮 Coming **soon**:

- Cron jobs support
- Doctrine migrations support

## 🚀 Installation

The only requirements are [Docker Desktop](https://www.docker.com/products/docker-desktop) and [Visual Studio Code](https://code.visualstudio.com), with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed.

👉 Grab the latest release [here](https://github.com/gremo/symfony-sail/releases/latest). 👈

**New project** or **existing project**:

1. Extract the archive into your project root folder
2. **Double check for any overwritten file**
3. Open the project in Visual Studio Code
4. (Optional) Create or edit the `.env` file and change the [configuration](#-configuration)
5. Reopen the project in Container

Important notes for **production**:

- To update your project pull changes from the VCS and run `docker compose up -d --build`; this rebuilds all images defined in the Docker Compose file, restarting any containers whose images have changed
- Ensure that `DB_USER`/`DB_PASSWORD` or `DB_ROOT_PASSWORD` are being set
- In case of errors check [common errors](#-common-errors)

## ⚙️ Configuration

The environment and the configuration can be changed in two ways: by setting variables in `.env` file and editing the configuration files in [`config/docker/`](config/docker/) sub-folders.

### Environment variables

> **Note**: other environment files like Symfony `.env.local` are **not** taken into account. Only the main file is used.

**Version-related variables**

| Variable           | Allowed values                       | Default value  | Notes        |
| :----------------- | :----------------------------------- | -------------- | ------------ |
| `CADDY_VERSION`    | "latest", `x`, `x.y`                 | 2              | Down to 2.6  |
| `PHP_VERSION`      | "latest", `x`, `x.y`                 | 8.2            | Down to 7.4  |
| `COMPOSER_VERSION` | "latest", "lts", `x`, `x.y`, `x.y.z` | lts            |              |
| `NODE_VERSION`     | "current", "lts", `x`                | lts            |              |
| `MARIADB_VERSION`  | "latest", `x`, `x.y`                 | 10.9           | Down to 10.6 |

**Database-related variables**

| Variable           | Allowed values | Default value | Notes                                                           |
| ------------------ | -------------- | ------------- | --------------------------------------------------------------- |
| `DB_USER`          | `string`       |               | Creates a new database user, with full permissions on `DB_NAME` |
| `DB_PASSWORD`      | `string`       |               | Password for the new database user                              |
| `DB_NAME`          | `string`       |               | Creates a new database with this name                           |
| `DB_ROOT_PASSWORD` | `string`       |               | Password for root database user                                 |

If left all blank, connection is allowed as `root` with an empty password.

**Server-related variables**

| Variable           | Allowed values           | Default value                       | Notes                                              |
| ------------------ | ------------------------ | ----------------------------------- | -------------------------------------------------- |
| `SERVER_NAME`      | `list` (comma-separated) | localhost:80, localhost             | Server domain names (see [faq](#-faq))             |
| `TZ`               | `string`                 | UTC                                 | Timezone for services and synced with PHP timezone |
| `WRITABLE_DIRS`    | `list` (space-separated) | public/uploads var                  | Space-separated directories writable by the server |
| `COMPOSER_AUTH`    | `string`                 |                                     | Composer authentication (see [faq](#-faq))         |
| `KNOWN_HOSTS`      | `list` (space-separated) | bitbucket.org github.com gitlab.com | Known SSH hosts (see [faq](#-faq))                 |

<details>
  <summary><b>Other variables</b> (click to show)</summary>
  <p dir="auto"></p>

  | Variable             | Allowed values | Default value                         | Notes                                       |
  | :------------------- | :------------- | ------------------------------------- | --------------------------------------------|
  | `CADDY_ADMIN_OPTION` | `string`       | *Environment based*                   | Caddy admin option (disabled in production) |
  | `CADDY_DEBUG_OPTION` | `string`       | *Environment based*                   | Caddy debug option (disabled in production) |
</details>

### Configuration files

- [`caddy/Caddyfile`](config/docker/caddy/Caddyfile): Caddy development/production configuration
- [`php/php-fpm.conf`](config/docker/php/php-fpm.conf): PHP FPM development/production configuration
- [`php/php.ini`](config/docker/php/php.ini): PHP development/production configuration
- `php/php.prod.ini`: (Optional) PHP production configuration
- [`mariadb/mariadb.cnf`](config/docker/mariadb/mariadb.cnf): MariaDB development/production configuration
- `mariadb/mariadb.prod.cnf`: (Optional) MariaDB production configuration

<details>
  <summary><b>Default configuration files</b> (click to show)</summary>
  <p dir="auto"></p>

  - [`docker/php/php.ini`](docker/php/php.ini): PHP development configuration
  - [`docker/php/php.prod.ini`](docker/php/php.prod.ini): PHP production configuration
</details>

## 🧑‍🏫 Tools, directories and assumptions

> **Note**: your project will build and run just fine even without any of the following.

- Public directory is `public/`
- PHP dependencies installed using Composer
- PHP preload file is `config/preload.php`
- Assets dependencies installed using npm or Yarn
- Webpack Encore is a dependency
- Webpack Encore output directory is a sub-directory of `public/`

Want to overcome these limitations? See the [Contributing](#-contributing) section!

## ❓ FAQ

### How do I configure `SERVER_NAME`?

Leave the default and add your domain name: `SERVER_NAME="localhost:80, localhost, example.com"`. This way, you can access your local development environment with both HTTP and HTTPS (without the automatic redirect) and you get the automatic HTTPS and redirect for your production domain.

### How do I work in Windows without trouble?

Disable the line-ending conversion globally (see [working with Git](https://code.visualstudio.com/docs/devcontainers/containers#_working-with-git)):

```bash
git config --global core.autocrlf false
```

I suggest also taking a look at [share SSH keys](https://code.visualstudio.com/remote/advancedcontainers/sharing-git-credentials#_using-ssh-keys) with the container. Under Windows, if you get any errors running `ssh-add` then try to update OpenSSH to the [latest version](https://github.com/PowerShell/Win32-OpenSSH/releases).

### How do I fetch private Composer repositories?

Sharing SSH keys is tricky, particularly in the production environment. During development, Visual Studio Code will do the hard work and your SSH keys will work just fine.

In production, those SSH keys are not copied in the final image. To fetch private repositories, take advance of the [`COMPOSER_AUTH`](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#authentication-using-the-composer-auth-environment-variable) in your `.env` file. An example using GitHub token:

```env
COMPOSER_AUTH={"github-oauth":{"github.com": "<your GitHub token>"}}
```

When building for production, the `ssh-keyscan` is used to collect the SSH public keys of `KNOWN_HOSTS`, thus avoiding interactive prompts.

### Why OPcache timestamps are disabled in production?

The `opcache.validate_timestamps` directive is disabled by the [default configuration](docker/php/php.prod.ini) because there is no need to check for updated scripts with every request. As soon as you update any PHP file (actually, any file) and run `docker compose up -d --build`, the php-fpm service will restart, thus invalidating the OPcache.

### How do I manage uploads in production?

To easily access dynamic public resources (i.e. uploads) in production, you probably want to mount your uploads directory to the `caddy` service public directory.

Modify [`docker-compose.override.yml`](docker-compose.override.yml) and bind-mount project `public/uploads` folder to `/srv/public/uploads`:

```yaml
services:
  caddy:
    volumes:
      - ./public/uploads:/srv/public/uploads
```

## ✋ Common errors

### PDO error in the production build

If you are getting *PDO::__construct(): php_network_getaddresses: getaddrinfo failed: Name or service not known* during the build process, it's because Doctrine will try to guess the database server version automatically when clearing the cache. Add the `server_version` option as explained [in the documentation](https://symfony.com/doc/current/reference/configuration/doctrine.html).

### Symfony skeleton error in the production build

Building the project in production with a fresh copy of `composer.json` from [Symfony skeleton](https://github.com/symfony/skeleton) isn't supported. During the production build, `composer install` is executed with the `--no-script`, making Symfony flex unable to update `composer.json` itself. To solve the problem, do a `composer install` in the development environment first.

### Call to PHP `file_get_contents()` hangs

See [this thread on Docker forum](https://forums.docker.com/t/132885) and [this issue on GitHub](https://github.com/docker/for-win/issues/13159). Under Windows, I managed to solve it by simply disabling the automatic proxy option.

### Dev container won't start

When Visual Studio Code can't start the dev container (without outputting errors) most likely there is some kind of problem with Docker Compose configuration.

You can debug the development configuration running:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml config
```

For the prod environment:

```bash
docker compose config
```

## 🐋 Docker internals

Project [`Dockerfile`](Dockerfile) is a [multi-stage build](https://docs.docker.com/build/building/multi-stage/) where multiple `FROM` statements are used to build the final artifact(s).

The development flow involves two Docker compose files:

> **Note**: both files are loaded automatically by Visual Studio Code Dev Container extension.

- [`docker-compose.yml`](docker-compose.yml)
- [`docker-compose.dev.yml`](docker-compose.dev.yml)

The production flow involves two Docker compose files:

> **Note**: both files are loaded automatically by Docker Compose.

- [`docker-compose.yml`](docker-compose.yml)
- [`docker-compose.override.yml`](docker-compose.override.yml)

## 🛟 Contributing

New features, ideas and bug fixes are always welcome! In order to contribute to this project, follow a few easy steps:

<p align="center">
  <a href="https://paypal.me/marcopolichetti" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg"/></a>
</p>

1. [Fork](https://help.github.com/en/github/getting-started-with-github/fork-a-repo) this repository and clone it on your machine
2. Create a branch `my-awesome-feature` and commit to it
5. Push `my-awesome-feature` branch to GitHub and open a [pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests)
