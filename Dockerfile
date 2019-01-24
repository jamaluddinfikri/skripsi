FROM resin/raspberry-pi-alpine:3.4

MAINTAINER jamaluddin fikri <jamaluddin8157@gmail.com>

RUN apk --update add wget \
    nginx \
    supervisor \
    bash \
    curl \
    php5-fpm \
    php5-pdo \
    php5-pdo_mysql \
    php5-mysql \
    php5-mysqli \
    php5-mcrypt \
    php5-xml \
    php5-ctype \
    php5-zlib \
    php5-curl \
    php5-openssl \
    php5-iconv \
    php5-json \
    php5-phar \
    php5-dom && \
    rm /var/cache/apk/*            && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    mkdir -p /etc/nginx            && \
    mkdir -p /var/www/app          && \
    mkdir -p /run/nginx            && \
    mkdir -p /var/log/supervisor   && \
    rm /etc/nginx/nginx.conf

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/start.sh /start.sh
ADD conf/php-fpm.conf  /etc/php5/php-fpm.conf

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/php.ini                                           && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 500M/g" /etc/php5/php.ini                          && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 500M/g" /etc/php5/php.ini                                      && \
    sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" /etc/php5/php.ini                           && \
    rm -Rf /etc/nginx/conf.d/*                && \
    rm -Rf /etc/nginx/sites-available/default && \
    mkdir -p /etc/nginx/ssl/                  && \
    chmod 755 /start.sh                       && \
    find /etc/php5/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \; && \
    mkdir /home/www

ADD conf/default.conf /etc/nginx/conf.d/default.conf
ADD index.html /home/www
ADD phpinfo.php /home/www

# Expose Ports
EXPOSE 443 80

# Start Supervisord
CMD ["/bin/sh", "/start.sh"]
#test guys
