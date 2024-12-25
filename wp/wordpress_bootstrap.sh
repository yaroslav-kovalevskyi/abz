#!/bin/bash

# Prerequisites
## Basic vars for WP server

## Preparing to install
sudo apt update && sudo apt upgrade -y 
sudo apt install mysql-client-core-8.0 php-cli php-mysql libapache2-mod-php php php-zip -y
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Creating WP web server config

cat <<'EOF' > ~/wordpress.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/wp
    <Directory /var/www/html/wp>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /var/www/html/wp/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo cp ~/wordpress.conf /etc/apache2/sites-available/wordpress.conf

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo service apache2 reload

#
sudo chown ubuntu:ubuntu /tmp/.wp_env

# Getting server's public DNS
TOKEN=$(wget -qO- --method PUT --header "X-aws-ec2-metadata-token-ttl-seconds: 21600" http://169.254.169.254/latest/api/token)
echo 'WP_HOST="'$(wget -qO- --header "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname)'"' >> /tmp/.wp_env

# Loading envs to shell

source /tmp/.wp_env

# Download and extract WordPress
wget -qO /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
sudo tar -xzf /tmp/wordpress.tar.gz -C /tmp/
sudo mkdir -p $WP_DIR
sudo cp -r /tmp/wordpress/* "$WP_DIR"
sudo chown -R www-data:www-data "$WP_DIR"

# Configure WordPress
sudo cp "$WP_DIR"/wp-config-sample.php "$WP_DIR"/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/" "$WP_DIR"/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/" "$WP_DIR"/wp-config.php
sudo sed -i "s/username_here/$DB_USER/" "$WP_DIR"/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/" "$WP_DIR"/wp-config.php

# Set up WordPress installation
sudo -u ubuntu -i -- wp --path="$WP_DIR" core install --url="$WP_HOST" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="$WP_ADMIN_EMAIL"

# Cleanup
sudo rm -rf /tmp/wordpress.tar.gz /tmp/wordpress
