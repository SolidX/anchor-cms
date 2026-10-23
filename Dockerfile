FROM alpine:3.24.3

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk upgrade && \
    apk add bash wget curl apache2

RUN apk add php86-mbstring php86-apache2 \
    php86-openssl php86-curl \
    php86-pdo php86-pdo_mysql php86-gd \
    php86-intl php86-session composer

RUN sed -i "s|display_errors = Off|display_errors = On|" /etc/php86/php.ini && \
    sed -i "s|variables_order = .*|variables_order = EGPCS|" /etc/php86/php.ini && \
    sed -i "s|;cgi.fix_pathinfo=1|cgi.fix_pathinfo=0|" /etc/php86/php.ini

RUN sed -i "s|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|" /etc/apache2/httpd.conf && \
    sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/html"#g' /etc/apache2/httpd.conf && \
    echo '<Directory "/var/www/html/">' >> /etc/apache2/httpd.conf && \
    echo 'Require all granted' >> /etc/apache2/httpd.conf && \
    echo 'AllowOverride FileInfo' >> /etc/apache2/httpd.conf && \
    echo '</Directory>' >> /etc/apache2/httpd.conf && \
    echo 'HttpProtocolOptions "Unsafe"' >> /etc/apache2/httpd.conf

RUN ln -sf /dev/null /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

RUN rm -rf /var/cache/apk/*

WORKDIR /var/www/html
VOLUME ["/var/www/html"]

EXPOSE 80

ENTRYPOINT ["/usr/sbin/httpd"]
CMD ["-D", "FOREGROUND"]
