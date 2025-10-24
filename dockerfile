# Use Ubuntu as base image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update package repository and install web server (Apache) and DB server (MySQL)
RUN apt-get update && \
    apt-get install -y \
    apache2 \
    mysql-server \
    php \
    libapache2-mod-php \
    php-mysql \
    && apt-get clean

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Create a simple PHP test page
RUN echo "<?php phpinfo(); ?>" > /var/www/html/info.php
RUN echo "<h1>Web and DB Server Container</h1><p>Apache + MySQL running in Docker</p>" > /var/www/html/index.html

# Configure MySQL
RUN mkdir -p /var/run/mysqld && \
    chown mysql:mysql /var/run/mysqld

# Initialize MySQL (minimal setup for demo)
RUN mysqld_safe & \
    sleep 5 && \
    mysql -e "CREATE DATABASE webappdb;" && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Expose ports for web (80) and database (3306)
EXPOSE 80 3306

# Create startup script
RUN echo '#!/bin/bash\n\
service mysql start\n\
service apache2 start\n\
tail -f /var/log/apache2/access.log' > /start.sh

RUN chmod +x /start.sh

# Start services
CMD ["/start.sh"]
