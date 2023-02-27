# Owncloud
This guide helps you to install Owncloud. The OS used in this tutorial is `Ubuntu 20.04` and the installation was done through a session using `AWS Session Manager`

# Installation
## Install requisites packages
The following package will be required by Owncloud
- Apache Web Server
- PHP 7.4 (8.0 is not compatible yet)
- Database (DB Client in case of remote DB)

Update the Linux repositories
```
sudo apt-get update
```

Install required packages for Owncloud
```
sudo apt-get install \
apache2 libapache2-mod-php \
mysql-client openssl redis-server wget php-imagick \
php-common php-curl php-gd php-gmp php-bcmath php-imap \
php-intl php-json php-mbstring php-mysql php-ssh2 php-xml \
  php-zip php-apcu php-redis php-ldap php-phpseclib
```

## Install Owncloud
In your home directory, downcloud Owncloud using the command below
```
sudo wget https://download.owncloud.com/server/stable/owncloud-complete-latest.tar.bz2
```

Extract the Owncloud tar file
```
sudo tar -xjf owncloud-complete-latest.tar.bz2
```

Copy the extracted Owncloud directory to `/var/www/`
```
sudo cp -r owncloud /var/www/
```

Set the owner of the Owncloud directory to `www-data`
```
sudo chown -R www-data. /var/www/owncloud
```

# Owncloud deb through repository
```
echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/server:/10/Ubuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/isv:ownCloud:server:10.list
curl -fsSL https://download.opensuse.org/repositories/isv:ownCloud:server:10/Ubuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/isv_ownCloud_server_10.gpg > /dev/null
sudo apt update
sudo apt install owncloud-complete-files
```

## (Optional) Install smblient php module
Follow the instruction below if you have a need to connect to external storage via SMB

First install the required package
```
sudo apt-get install -y libsmbclient-dev php-dev php-pear
```

To install smbclient php module use the commands following
```
pecl channel-update pecl.php.net
mkdir -p /tmp/pear/cache
pecl install smbclient-stable
echo "extension=smbclient.so" > /etc/php/7.4/mods-available/smbclient.ini
phpenmod smbclient
sudo systemctl restart apache2
```

# Confirguration

## Apache
**Create a virtual host configuration**

Create a file named `owncloud.conf` under `/etc/apache2/sites-available/`:
```
sudo touch /etc/apache2/sites-available/owncloud.conf
```

Edit the content of the `owncloud.conf` like the following
```
<VirtualHost *:80>
# uncommment the line below if variable was set
#ServerName $my_domain
DirectoryIndex index.php index.html
DocumentRoot /var/www/owncloud
<Directory /var/www/owncloud>
  Options +FollowSymlinks -Indexes
  AllowOverride All
  Require all granted

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
</VirtualHost>
```

**Enable the virtual host configuration**
```
sudo a2dissite 000-default
sudo a2ensite owncloud.conf
```

## NGINX
Create a file named `owncloud.conf` under `/etc/nginx/sites-available/`:
```
server {
    listen 80;
    listen [::]:80;
#    server_name cloud.example.com;

#    ssl_certificate /etc/ssl/nginx/cloud.example.com.crt;
#    ssl_certificate_key /etc/ssl/nginx/cloud.example.com.key;

    # Example SSL/TLS configuration. Please read into the manual of Nginx before applying these.
#    ssl_session_timeout 5m;
#    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
#    ssl_ciphers "-ALL:EECDH+AES256:EDH+AES256:AES256-SHA:EECDH+AES:EDH+AES:!ADH:!NULL:!aNULL:!eNULL:!EXPORT:!LOW:!MD5:!3DES:!PSK:!SRP:!DSS:!AESGCM:!RC4";
#    ssl_dhparam /etc/nginx/dh4096.pem;
#    ssl_prefer_server_ciphers on;
#    keepalive_timeout    70;
#    ssl_stapling on;
#    ssl_stapling_verify on;

    # Add headers to serve security related headers
    # The always parameter ensures that the header is set for all responses, including internally generated error responses.
    # Before enabling Strict-Transport-Security headers please read into this topic first.
    # https://www.nginx.com/blog/http-strict-transport-security-hsts-and-nginx/

    #add_header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Robots-Tag "none" always;
    add_header X-Download-Options "noopen" always;
    add_header X-Permitted-Cross-Domain-Policies "none" always;

    # Path to the root of your installation
    root /var/www/owncloud/;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    location = /.well-known/carddav {
        return 301 $scheme://$host:$server_port/remote.php/dav;
    }
    location = /.well-known/caldav {
        return 301 $scheme://$host:$server_port/remote.php/dav;
    }

    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 8 4K;                     # Please see note 1
    fastcgi_ignore_headers X-Accel-Buffering; # Please see note 2

    # Disable gzip to avoid the removal of the ETag header
    # Enabling gzip would also make your server vulnerable to BREACH
    # if no additional measures are done. See https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=773332
    gzip off;

    # Uncomment if your server is build with the ngx_pagespeed module
    # This module is currently not supported.
    #pagespeed off;

    error_page 403 /core/templates/403.php;
    error_page 404 /core/templates/404.php;

    location / {
        rewrite ^ /index.php$uri;
    }

    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|changelog|data)/ {
        return 404;
    }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console|core/skeleton/) {
        return 404;
    }
    location ~ ^/core/signature\.json {
        return 404;
    }

    location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|oc[sm]-provider/.+|core/templates/40[34])\.php(?:$|/) {
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param SCRIPT_NAME $fastcgi_script_name; # necessary for ownCloud to detect the contextroot https://github.com/owncloud/core/blob/v10.0.0/lib/private/AppFramework/Http/Request.php#L603
        fastcgi_param PATH_INFO $fastcgi_path_info;
#        fastcgi_param HTTPS on;
        fastcgi_param modHeadersAvailable true; #Avoid sending the security headers twice
        fastcgi_param front_controller_active true;
        fastcgi_read_timeout 180; # increase default timeout e.g. for long running carddav/caldav syncswith 1000+ entries
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_intercept_errors on;
        fastcgi_request_buffering off; #Available since Nginx 1.7.11
    }

    location ~ ^/(?:updater|oc[sm]-provider)(?:$|/) {
        try_files $uri $uri/ =404;
        index index.php;
    }

    # Adding the cache control header for js and css files
    # Make sure it is BELOW the PHP block
    location ~ \.(?:css|js)$ {
        try_files $uri /index.php$uri$is_args$args;
        add_header Cache-Control "max-age=15778463" always;

        # Add headers to serve security related headers (It is intended to have those duplicated to theones above)
        # The always parameter ensures that the header is set for all responses, including internally generated error responses.
        # Before enabling Strict-Transport-Security headers please read into this topic first.
        # https://www.nginx.com/blog/http-strict-transport-security-hsts-and-nginx/

        #add_header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Robots-Tag "none" always;
        add_header X-Download-Options "noopen" always;
        add_header X-Permitted-Cross-Domain-Policies "none" always;
        # Optional: Don't log access to assets
        access_log off;
    }

    location ~ \.(?:svg|gif|png|html|ttf|woff|ico|jpg|jpeg|map|json)$ {
        add_header Cache-Control "public, max-age=7200" always;
        try_files $uri /index.php$uri$is_args$args;
        # Optional: Don't log access to other assets
        access_log off;
    }
}
```

**Enable Owncloud server block and modules**
```
sudo ln -s /etc/nginx/sites-available/owncloud.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx.service
```


## Database
The configuration for the database wiil be applicable for `MySQL/MariaDB` engine

Log in the database using your privileged account (root/admin)
```
mysql -h <db_host> -u <privileged user> -p
```

Create databased named `ownclouddb` if that is not created yet
```
CREATE DATABASE IF NOT EXISTS ownclouddb;
```

Set an environment variable for the database's password
```
sec_db_pwd=<database_password>
```

And follow by the SQL query below
```
GRANT ALL PRIVILEGES ON ownclouddb.* \
  TO owncloud@localhost \
  IDENTIFIED BY '${sec_db_pwd}';
```

## Owncloud
**(Optinal )occ helper Script**
Create a new script for `occ`
```
sudo touch /usr/local/bin/occ
```

Add the content below to the file
```
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "$@"
```

Make the helper occ script executable
```
sudo chmod +x /usr/local/bin/occ
```

**Setup Owncloud using occ**
Change directory to `/var/www/owncloud`

To install Owncloud with the configuration above, run this command
```
occ maintenance:install \
    --database "mysql" \
    --database-host <DB_remote_host> \
    --database-name "ownclouddb" \
    --database-user "owncloud" \
    --database-pass ${sec_db_pwd} \
    --data-dir "/var/www/owncloud/data" \
    --admin-user "admin" \
    --admin-pass <admin_password>
```

## Enable the recommended Apache Modules
```
sudo a2enmod dir env headers mime rewrite setenvif
sudo systemctl restart apache2
```

## Trusted domain
If you use your own domain or a load balancer you'll need to add them as Owncloud trusted domains
```
occ config:system:set trusted_domains 1 --value="<ip_or_domain>"
```

## Cron jobs
Set your background job mode to cron
```
occ background:cron
```

Configure the execution of the cron job to every 15 min and the cleanup of chunks every night at 2 am:
```
sudo echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data
```
```
sudo echo "0  2  *  *  * /var/www/owncloud/occ dav:cleanup-chunks" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data
```

## Caching and File Locking
```
occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'
```

```
occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'
```

```
occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json
```

## Log Rotation
Create a owncloud file under `/etc/logrotate.d/`
```
sudo touch /etc/logrotate.d/owncloud
```

Add these lines below to the content of the file
```
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
```


## Owncloud Azure LZ
coming soon

## Owncloud AWS LZ
coming soon