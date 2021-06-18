#wordpress with wp cli -> https://github.com/conetix/docker-wordpress-wp-cli/blob/master/Dockerfile
FROM wordpress:5.7.2-php7.4-fpm-alpine

# Add php config
ADD php.ini /usr/local/etc/php

# Add xdebug config
ADD xdebug.ini /usr/local/etc/php/conf.d

# Install dependencies
RUN apk add --no-cache sudo less mysql-client

# Fix sudo issue https://gitlab.alpinelinux.org/alpine/aports/issues/11122
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

## Add WP-CLI
RUN curl -o /bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN echo '#!/bin/bash' >> /bin/wp && \
    echo 'sudo -E -u www-data /bin/wp-cli.phar "$@"' >> /bin/wp
RUN chmod +x /bin/wp-cli.phar /bin/wp
RUN mkdir -p /root/.wp-cli/cache
RUN chown www-data:www-data /root/.wp-cli/cache

## Add Xdebug
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.9.8 \
    && docker-php-ext-enable xdebug

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
