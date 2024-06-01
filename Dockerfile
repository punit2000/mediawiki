FROM registry.access.redhat.com/ubi8/ubi-init

# Install necessary packages
RUN dnf module reset php -y && \
    dnf module enable -y php:7.4 && \
    dnf install -y httpd php php-fpm php-mysqlnd php-gd php-xml php-mbstring php-json php-intl php-apcu wget

# Download and unpack the MediaWiki tarball
RUN wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.1.tar.gz && \
    tar -zxf mediawiki-1.41.1.tar.gz && \
    mv mediawiki-1.41.1 /var/www/mediawiki

# Modify the httpd.conf file to change the port to 8080, set ServerName, and update PidFile location
RUN sed -i -e 's|^Listen 80|Listen 8080|' /etc/httpd/conf/httpd.conf && \
    sed -i -e 's|^DocumentRoot "/var/www/html"|DocumentRoot "/var/www/mediawiki"|' \
    -e 's|    DirectoryIndex index.html|    DirectoryIndex index.html index.html.var index.php|' \
    -e 's|^<Directory "/var/www/html">|<Directory "/var/www/mediawiki">|' /etc/httpd/conf/httpd.conf && \
    sed -i 's|^LoadModule http2_module modules/mod_http2.so|#LoadModule http2_module modules/mod_http2.so|' /etc/httpd/conf.modules.d/00-base.conf && \
    echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf && \
    echo "PidFile /run/httpd/httpd.pid" >> /etc/httpd/conf/httpd.conf

# Set up php-fpm
RUN mkdir -p /run/php-fpm && \
    sed -i 's|^;listen.owner = nobody|listen.owner = apache|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^;listen.group = nobody|listen.group = apache|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^;listen.mode = 0660|listen.mode = 0660|' /etc/php-fpm.d/www.conf && \
    sed -i 's|^listen = 127.0.0.1:9000|listen = /run/php-fpm/www.sock|' /etc/php-fpm.d/www.conf

# Change ownership to apache user and set proper permissions
RUN chown -R apache:apache /var/www/mediawiki && \
    chmod -R 755 /var/www/mediawiki && \
    chown apache:apache /run/php-fpm && \
    chown -R apache:apache /var/log/httpd && \
    chown -R apache:apache /var/log/php-fpm && \
    mkdir -p /run/httpd && chown -R apache:apache /run/httpd

# Switch to apache user
USER apache

# Start PHP-FPM and Apache on container start
CMD /usr/sbin/php-fpm --nodaemonize & /usr/sbin/httpd -DFOREGROUND
