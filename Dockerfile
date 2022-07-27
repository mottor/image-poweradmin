ARG MLOCATI_PHP_EXTENSION_INSTALLER_VERSION=1.5.28
ARG PHP_VERSION=7.4.30

FROM mlocati/php-extension-installer:$MLOCATI_PHP_EXTENSION_INSTALLER_VERSION AS php-extension-installer
FROM php:$PHP_VERSION-fpm-buster

ENV POWERADMIN_VERSION 2.2.2

ENV DB_HOST localhost
ENV DB_PORT 3306
ENV DB_NAME pdns
ENV DB_USER pdns
ENV DB_PASS pdns
ENV DB_TYPE mysql
ENV DNS_NS1 8.8.8.8
ENV DNS_NS2 8.8.4.4

ENV CLEANIMAGE_VERSION main
ENV CLEANIMAGE_URL https://raw.githubusercontent.com/mottor/docker-cleanimage/$CLEANIMAGE_VERSION/cleanimage

USER root

COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
ADD ["$CLEANIMAGE_URL", "/usr/local/bin/"]
ADD docker/php/entrypoint.sh /entrypoint.sh

# https://github.com/poweradmin/poweradmin

RUN apt-get update \
    && chmod +x /usr/local/bin/cleanimage \
    && chmod +x /entrypoint.sh \
    && DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends apt-utils | grep -v "debconf: delaying package configuration, since apt-utils is not installed" \
    && DEBIAN_FRONTEND=noninteractive apt-get install -q -y curl zip \
    && install-php-extensions intl gettext pdo-mysql \
    && curl -sLo poweradmin-${POWERADMIN_VERSION}.zip https://github.com/poweradmin/poweradmin/archive/refs/tags/v${POWERADMIN_VERSION}.zip \
    && unzip poweradmin-${POWERADMIN_VERSION}.zip -d /tmp \
    && rm -f /var/www/html/* \
    && mv /tmp/poweradmin-${POWERADMIN_VERSION}/* /var/www/html/ \
    && cp /var/www/html/inc/config-me.inc.php /var/www/html/config.inc.php \
    && rm -rf /var/www/html/install \
    && rm -rf poweradmin-${POWERADMIN_VERSION}.zip \
    && chown -R www-data:www-data /var/www \
    && cleanimage

COPY ./docker/php/php.ini $PHP_INI_DIR/php.ini
COPY ./docker/php/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY ./docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

USER www-data
EXPOSE 9000
CMD ["/entrypoint.sh"]