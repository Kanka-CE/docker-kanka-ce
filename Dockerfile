# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KANKACE_RELEASE
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

RUN \
  echo "**** install nodejs + npm for vite build ****" && \
  apk add --no-cache nodejs npm

RUN \
  echo "**** fetch Kanka-CE ****" && \
  mkdir -p /app/www
RUN \
  if [ -z ${KANKACE_RELEASE+x} ]; then \
    KANKACE_RELEASE=$(curl -sX GET "https://api.github.com/repos/Kanka-CE/kanka-community-edition/releases/latest" \
    | jq -r '.tag_name'); \
  fi && \
  curl -o \
    /tmp/kanka-ce.tar.gz -L \
    "https://github.com/Kanka-CE/kanka-community-edition/archive/refs/tags/${KANKACE_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/kanka-ce.tar.gz -C \
    /app/www/ --strip-components=1 && \
  rm -f \
    /tmp/kanka-ce.tar.gz

RUN \
  cd /app/www \
  rm -rf    \
    .git    \
    .github \
    .dockerignore

# Build frontend assets
RUN \
  echo "**** install npm dependencies ****" \
    && cd /app/www \
    && npm install --legacy-peer-deps \
    && npm run build \
    && rm -rf node_modules

RUN \
  echo "**** install composer dependencies ****" && \
  composer install -d /app/www/ && \
  printf "Kanka-CE version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443

# TODO: Mount /config instead and symlink, similiar as it is done by linuxserver.io by default
VOLUME /app/www/storage
