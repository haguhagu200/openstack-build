#!/bin/bash
file="/etc/httpd/conf/httpd.conf"
sed -i.orig "96i ServerName controller" $file

config=$(cat  <<CONFIG
Listen 5000
Listen 35357

<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    ErrorLogFormat "%{cu}t %M"
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        Require all granted
    </Directory>
</VirtualHost>
CONFIG
)

echo  "$config" > /etc/httpd/conf.d/wsgi-keystone.conf
echo "Verify ... /etc/httpd/conf.d/wsgi-keystone.conf"
cat /etc/httpd/conf.d/wsgi-keystone.conf

echo "Star Apache Server..."
systemctl enable httpd.service
systemctl start httpd.service

echo "Apache status: $(systemctl is-active httpd.service)"
