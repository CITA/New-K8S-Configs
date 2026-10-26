FROM rockylinux:9

# ------------------------------------------------------------
# Base repositories + Remi PHP 8.4
# ------------------------------------------------------------

RUN dnf -y install \
        epel-release \
        dnf-plugins-core \
    && dnf -y install \
        https://rpms.remirepo.net/enterprise/remi-release-9.rpm \
    && dnf -y module reset php \
    && dnf -y module enable php:remi-8.4 \
    && dnf --refresh -y install \
        httpd \
        mod_ssl \
        php \
        php-bcmath \
        php-cli \
        php-common \
        php-curl \
        php-fpm \
        php-gd \
        php-intl \
        php-mbstring \
        php-mysqlnd \
        php-opcache \
        php-pdo \
        php-process \
        php-soap \
        php-xml \
        php-zip \
        gzip \
        tar \
        unzip \
    && php -r 'exit(version_compare(PHP_VERSION, "8.4.27", ">=") ? 0 : 1);' \
    && rm -f /etc/httpd/conf.d/ssl.conf \
    && dnf clean all \
    && rm -rf /var/cache/dnf

# ------------------------------------------------------------
# Runtime directories
# ------------------------------------------------------------

RUN mkdir -p \
        /run/php-fpm \
        /var/lib/php/session \
        /var/lib/php/wsdlcache \
        /usr/share/wordpress \
    && chown -R apache:apache \
        /var/lib/php/session \
        /var/lib/php/wsdlcache

# ------------------------------------------------------------
# Startup script
# ------------------------------------------------------------

COPY start.sh /usr/local/sbin/cita-wordpress-start

RUN chmod 755 /usr/local/sbin/cita-wordpress-start

# ------------------------------------------------------------
# Ports and startup
# ------------------------------------------------------------

EXPOSE 80 443

CMD ["/usr/local/sbin/cita-wordpress-start"]
