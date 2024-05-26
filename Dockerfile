# RHEL 8 as the base image and downloading all the dependencies
FROM registry.access.redhat.com/ubi8/ubi-init
RUN dnf module reset php
RUN dnf module enable -y php:7.4
RUN dnf install -y httpd php php-fpm php-mysqlnd php-gd php-xml  php-mbstring php-json  php-intl php-apcu wget
# Download, unpacking and moving the mediawiki tar
RUN wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.1.tar.gz
RUN tar -zxf  mediawiki-1.41.1.tar.gz
RUN mv mediawiki-1.41.1 mediawiki
RUN mv mediawiki /var/www/
# Modifying the http.conf
RUN  sed -i -e 's|^DocumentRoot "/var/www/html"|DocumentRoot "/var/www/mediawiki"|' -e 's|    DirectoryIndex index.html|    DirectoryIndex index.html index.html.var index.php|' -e 's|^<Directory "/var/www/html">|<Directory "/var/www/mediawiki">|' /etc/httpd/conf/httpd.conf
RUN chown -R apache:apache /var/www/mediawiki
RUN chmod -R 755 /var/www/mediawiki
RUN sed -i 's|^LoadModule http2_module modules/mod_http2.so|#LoadModule http2_module modules/mod_http2.so|' /etc/httpd/conf.modules.d/00-base.conf

#To resolbe php-fpm issues.
RUN mkdir -p /run/php-fpm && \
    chown apache:apache /run/php-fpm && \
    sed -i 's|^;listen.owner = nobody|listen.owner = apache|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^;listen.group = nobody|listen.group = apache|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^;listen.mode = 0660|listen.mode = 0660|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^listen = 127.0.0.1:9000|listen = /run/php-fpm/www.sock|' /etc/php-fpm.d/www.conf

# Start PHP-FPM and Apache on container start
CMD /usr/sbin/php-fpm --nodaemonize & /usr/sbin/httpd -DFOREGROUND
