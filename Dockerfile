# syntax=docker/dockerfile:1

###############################################
# Stage 1: Node build (Vite / Mix)
###############################################
FROM node:20-alpine AS node-build

WORKDIR /app

# Copy only package files first for caching
COPY Kanka-CE/package.json Kanka-CE/package-lock.json ./

RUN npm install

# Copy full app
COPY Kanka-CE/ .

# Build production assets
RUN npm run build

###############################################
# Stage 2: PHP-FPM + Nginx (Linuxserver.io)
###############################################
FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
ARG NGINX_VERSION
LABEL build_version="Kanka-CE version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="kinnewig"

ENV S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    fontconfig \
    mariadb-client \
    memcached \
    php84-bcmath \
    php84-dom \
    php84-exif \
    php84-gd \
    php84-intl \
    php84-mbstring \
    php84-mysqlnd \
    php84-opcache \
    php84-pdo \
    php84-pdo_mysql \
    php84-pecl-memcached \
    php84-sodium \
    php84-tokenizer \
    php84-xml \
    php84-zip \
    qt5-qtbase \
    ttf-freefont && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php84/php-fpm.d/www.conf && \
  if ! grep -qxF 'clear_env = no' /etc/php84/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php84/php-fpm.d/www.conf; fi && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php84/php-fpm.conf 

# TODO: Create releases in the Kanka-Community-Edition repository and directly download them here via curl
RUN \
  echo "**** fetch Kanka-CE ****" && \
  mkdir -p /app/www 
COPY Kanka-CE/ /app/www
RUN \
  cd /app/www \
  rm -rf   \
    .claude  \
    .git     \
    .github  \
    .mariadb \
    .nginx   \
    docker   \
    docs     \
    public/vendor/fontawesome && \
  rm -f \
    .dockerignore      \
    .editorconfig      \
    .env.example       \
    .env.testing       \
    .gitattributes     \
    .gitignore         \
    .jshintrc          \
    boost.json         \
    CLAUDE.md          \
    CODE_OF_CONDUCT.md \
    docker-compose.yml \
    README.md

RUN \
  echo "**** install composer dependencies ****" && \
  composer install -d /app/www/ && \
  printf "Kanka-CE version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer

# Copy built Vite assets from Node stage
COPY --from=node-build /app/public/build /app/www/public/build
COPY --from=node-build /app/public/assets /app/www/public/assets
COPY --from=node-build /app/public/css /app/www/public/css
COPY --from=node-build /app/public/js /app/www/public/js

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443

# TODO: Mount /config instead and symlink, similiar as it is done by linuxserver.io by default
VOLUME /app/www/storage
