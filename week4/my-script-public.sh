#!/bin/bash

sudo su
yum -y update
yum -y install httpd
service httpd start
chkconfig httpd on
cd /var/www/html
echo "<html><h1>This is WebServer from public subnet</h1></html>" > index.html