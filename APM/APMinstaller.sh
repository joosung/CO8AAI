#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * APMinstaller v.1 with CentOS8                                                   #
# * CentOS-8-x86_64-1911                                                            #
# * Apache 2.4.X , MariaDB 10.4.X, Multi-PHP(base php7.2) setup shell script        #
# * Created Date    : 2020/04/15                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           repositories install         #
#                                        #
########################################## 

yum -y install wget openssh-clients bind-utils git nc vim-enhanced man ntsysv \
iotop sysstat strace lsof mc lrzsz zip unzip bzip2 glibc* net-tools bind gcc dnf \
libxml2-devel libXpm-devel gmp-devel libicu-devel openssl-devel gettext-devel \
bzip2-devel libcurl-devel libjpeg-devel libpng-devel freetype-devel readline-devel \
libxslt-devel pcre-devel curl-devel ncurses-devel autoconf automake zlib-devel libuuid-devel \
net-snmp-devel libevent-devel libtool-ltdl-devel postgresql-devel bison make pkgconfig firewalld yum-utils

dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm

dnf install -y epel-release yum-utils

echo "[mariadb]" > /etc/yum.repos.d/mariadb.repo
echo "name = MariaDB" >> /etc/yum.repos.d/mariadb.repo
echo "baseurl = http://yum.mariadb.org/10.4/centos8-amd64" >> /etc/yum.repos.d/mariadb.repo
echo "module_hotfixes=1" >> /etc/yum.repos.d/mariadb.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/mariadb.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mariadb.repo 

yum -y update

systemctl start firewalld 
systemctl enable firewalld

systemctl start named.service
systemctl enable  named.service

cd /root/CO8AAI/APM

##########################################
#                                        #
#           SELINUX disabled             #
#                                        #
##########################################

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
/usr/sbin/setenforce 0

##########################################
#                                        #
#           아파치 및 HTTP2 설치            #
#                                        #
########################################## 

# Nghttp2 설치
yum --enablerepo=epel -y install libnghttp2

# /etc/mime.types 설치 
yum -y install mailcap

# httpd 설치
yum -y install c-ares

yum -y install httpd mod_ssl

yum -y install openldap-devel expat-devel

yum -y install libdb-devel perl

yum -y install httpd-devel

systemctl start httpd
systemctl enable httpd

cd /root/CO8AAI
wget https://dl.eff.org/certbot-auto
mv certbot-auto /usr/local/bin/certbot-auto
chown root /usr/local/bin/certbot-auto
chmod 0755 /usr/local/bin/certbot-auto

##########################################
#                                        #
#               firewalld                #
#                                        #
##########################################  

systemctl start firewalld
systemctl enable firewalld

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=public --add-port=3306/tcp
firewall-cmd --permanent --zone=public --add-port=9090/tcp
firewall-cmd --reload

##########################################
#                                        #
#           httpd.conf   Setup           #
#                                        #
##########################################  

sed -i '/nameserver/i\nameserver 127.0.0.1' /etc/resolv.conf
cp -av /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
sed -i 's/DirectoryIndex index.html/ DirectoryIndex index.html index.htm index.php index.php3 index.cgi index.jsp/' /etc/httpd/conf/httpd.conf
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/httpd/conf/httpd.conf
sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride none/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/' /etc/httpd/conf/httpd.conf
sed -i 's/UserDir disabled/#UserDir disabled/' /etc/httpd/conf.d/userdir.conf
sed -i 's/#UserDir public_html/UserDir public_html/' /etc/httpd/conf.d/userdir.conf
sed -i 's/Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec/Options MultiViews SymLinksIfOwnerMatch IncludesNoExec/' /etc/httpd/conf.d/userdir.conf

cp /root/CO8AAI/APM/index.html /var/www/html/
#cp -f /root/CO8AAI/APM/index.html /usr/share/httpd/noindex/

echo "<VirtualHost *:80>
  DocumentRoot /var/www/html
</VirtualHost> " >> /etc/httpd/conf.d/default.conf

systemctl restart httpd
systemctl restart named.service

##########################################
#                                        #
#         PHP7.2 및 라이브러리 install      #
#                                        #
########################################## 

dnf config-manager --set-enabled PowerTools -y
dnf config-manager --set-enabled remi -y

dnf module reset php
dnf module enable php:remi-7.2 -y
dnf module install php:remi-7.2 -y


dnf -y install php56 php56-php-cli php56-php-fpm \
php56-php-common php56-php-pdo php56-php-mysqlnd php56-php-mbstring php56-php-mcrypt \
php56-php-opcache php56-php-xml php56-php-pecl-imagick php56-php-gd php56-php-fileinfo \
php56-php-pecl-ssh2 php56-php-soap php56-php-devel php56-php-imap php56-php-json php56-php-mysql \
php56-php-ldap php56-php-xml php56-php-iconv php56-php-xmlrpc php56-php-snmp php56-php-pgsql \
php56-php-pecl-apcu php56-php-pecl-geoip php56-php-pecl-memcached php56-php-pecl-redis \
php56-php-pecl-mailparse php56-php-process php56-php-ioncube-loader


dnf -y install php70 php70-php-cli php70-php-fpm \
php70-php-common php70-php-pdo php70-php-mysqlnd php70-php-mbstring php70-php-mcrypt \
php70-php-opcache php70-php-xml php70-php-pecl-imagick php70-php-gd php70-php-fileinfo \
php70-php-pecl-mysql php70-php-pecl-ssh2 php70-php-soap php70-php-devel php70-php-imap \
php70-php-json php70-php-ldap php70-php-xml php70-php-iconv php70-php-xmlrpc php70-php-snmp \
php70-php-pecl-apcu php70-php-pecl-geoip php70-php-pecl-memcached php70-php-pecl-redis \
php70-php-pecl-mailparse php70-php-pgsql php70-php-process php70-php-ioncube-loader


dnf -y install php71 php71-php-cli php71-php-fpm \
php71-php-common php71-php-pdo php71-php-mysqlnd php71-php-mbstring php71-php-mcrypt \
php71-php-opcache php71-php-xml php71-php-pecl-imagick php71-php-gd php71-php-fileinfo \
php71-php-pecl-mysql php71-php-pecl-ssh2 php71-php-soap php71-php-devel php71-php-imap \
php71-php-json php71-php-ldap php71-php-xml php71-php-iconv php71-php-xmlrpc php71-php-snmp \
php71-php-pecl-apcu php71-php-pecl-geoip php71-php-pecl-memcached php71-php-pecl-redis \
php71-php-pecl-mailparse php71-php-pgsql php71-php-process php71-php-ioncube-loader


dnf -y install php72 php72-php-cli php72-php-fpm \
php72-php-common php72-php-pdo php72-php-mysqlnd php72-php-mbstring php72-php-mcrypt \
php72-php-opcache php72-php-xml php72-php-pecl-imagick php72-php-gd php72-php-fileinfo \
php72-php-pecl-mysql php72-php-pecl-ssh2 php72-php-soap php72-php-devel php72-php-imap \
php72-php-json php72-php-ldap php72-php-xml php72-php-iconv php72-php-xmlrpc php72-php-snmp \
php72-php-pecl-apcu php72-php-pecl-geoip php72-php-pecl-memcached php72-php-pecl-redis \
php72-php-pecl-mailparse php72-php-pgsql php72-php-process php72-php-ioncube-loader


dnf -y install php73 php73-php-cli php73-php-fpm \
php73-php-common php73-php-pdo php73-php-mysqlnd php73-php-mbstring php73-php-mcrypt \
php73-php-opcache php73-php-xml php73-php-pecl-imagick php73-php-gd php73-php-fileinfo \
php73-php-pecl-mysql php73-php-pecl-ssh2 php73-php-soap php73-php-devel php73-php-imap \
php73-php-json php73-php-ldap php73-php-xml php73-php-iconv php73-php-xmlrpc php73-php-snmp \
php73-php-pecl-apcu php73-php-pecl-geoip php73-php-pecl-memcached php73-php-pecl-redis \
php73-php-pecl-mailparse php73-php-pgsql php73-php-process php73-php-ioncube-loader


dnf -y install php74 php74-php-cli php74-php-fpm \
php74-php-common php74-php-pdo php74-php-mysqlnd php74-php-mbstring php74-php-mcrypt \
php74-php-opcache php74-php-xml php74-php-pecl-imagick php74-php-gd php74-php-fileinfo \
php74-php-pecl-mysql php74-php-pecl-ssh2 php74-php-soap php74-php-devel php74-php-imap \
php74-php-json php74-php-ldap php74-php-xml php74-php-iconv php74-php-xmlrpc php74-php-snmp \
php74-php-pecl-apcu php74-php-pecl-geoip php74-php-pecl-memcached php74-php-pecl-redis \
php74-php-pecl-mailparse php74-php-pgsql php74-php-process php74-php-ioncube-loader


echo 'listen = 127.0.0.1:9056
pm = ondemand' >> /etc/opt/remi/php56/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9070
pm = ondemand' >> /etc/opt/remi/php70/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9071
pm = ondemand' >> /etc/opt/remi/php71/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9072
pm = ondemand' >> /etc/opt/remi/php72/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9073
pm = ondemand' >> /etc/opt/remi/php73/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9074
pm = ondemand' >> /etc/opt/remi/php74/php-fpm.d/www.conf

systemctl start php-fpm
systemctl enable php-fpm

systemctl start php56-php-fpm
systemctl enable php56-php-fpm

systemctl start php70-php-fpm
systemctl enable php70-php-fpm

systemctl start php71-php-fpm
systemctl enable php71-php-fpm

systemctl start php72-php-fpm
systemctl enable php72-php-fpm

systemctl start php73-php-fpm
systemctl enable php73-php-fpm

systemctl start php74-php-fpm
systemctl enable php74-php-fpm

sed -i 's/php_value/#php_value/' /etc/httpd/conf.d/php.conf

echo '<Files ".user.ini">
  Require all denied
</Files>
AddType text/html .php
DirectoryIndex index.php
SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1
<FilesMatch \.php$>
  SetHandler "proxy:fcgi://127.0.0.1:9072"
</FilesMatch>' >> /etc/httpd/conf.d/php.conf


dnf install -y GeoIP GeoIP-data GeoIP-devel
echo "#geoip setup
<IfModule mod_geoip.c>
 GeoIPEnable On
 GeoIPDBFile /usr/share/GeoIP/GeoIP.dat MemoryCache
</IfModule>" > /etc/httpd/conf.d/geoip.conf

cp -av /etc/php.ini /etc/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php.ini 

cp -av /etc/opt/remi/php56/php.ini /etc/opt/remi/php56/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php56/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php56/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php56/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php56/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php56/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php56/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php56/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php56/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php56/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php56/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php56/php.ini 

cp -av /etc/opt/remi/php70/php.ini /etc/opt/remi/php70/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php70/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php70/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php70/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php70/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php70/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php70/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php70/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php70/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php70/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php70/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php70/php.ini 

cp -av /etc/opt/remi/php71/php.ini /etc/opt/remi/php71/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php71/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php71/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php71/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php71/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php71/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php71/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php71/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php71/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php71/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php71/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php71/php.ini 

cp -av /etc/opt/remi/php72/php.ini /etc/opt/remi/php72/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php72/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php72/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php72/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php72/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php72/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php72/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php72/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php72/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php72/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php72/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php72/php.ini 

cp -av /etc/opt/remi/php73/php.ini /etc/opt/remi/php73/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php73/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php73/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php73/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php73/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php73/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php73/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php73/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php73/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php73/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php73/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php73/php.ini 

cp -av /etc/opt/remi/php74/php.ini /etc/opt/remi/php74/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php74/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php74/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php74/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php74/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php74/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php74/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php74/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php74/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php74/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php74/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php74/php.ini 


mkdir /etc/skel/public_html

chmod 707 /etc/skel/public_html

chmod 700 /root/CO8AAI/adduser.sh

chmod 700 /root/CO8AAI/deluser.sh

chmod 700 /root/CO8AAI/restart.sh

cp /root/CO8AAI/APM/skel/index.html /etc/skel/public_html/

rm -rf /etc/httpd/conf.d/php56-php.conf
rm -rf /etc/httpd/conf.d/php70-php.conf
rm -rf /etc/httpd/conf.d/php71-php.conf
rm -rf /etc/httpd/conf.d/php72-php.conf
rm -rf /etc/httpd/conf.d/php73-php.conf
rm -rf /etc/httpd/conf.d/php74-php.conf

systemctl restart httpd


curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php56/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php70/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php71/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php72/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php73/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php74/php.ini

systemctl restart httpd

echo '<?php
phpinfo();
?>' >> /var/www/html/phpinfo.php

##########################################
#                                        #
#          MARIADB 10.4.X install        #
#                                        #
########################################## 

# MariaDB 10.4.x 설치
dnf install -y boost-program-options
dnf install -y MariaDB-server

systemctl enable --now mariadb

systemctl start mariadb

# S.M.A.R.T. 디스크 모니터링을 설치
dnf -y install smartmontools

systemctl enable smartd

systemctl start smartd

##########################################
#                                        #
#            mysql root 설정              #
#                                        #
##########################################

/usr/bin/mysql_secure_installation

##########################################
#                                        #
#        운영 및 보안 관련 추가 설정           #
#                                        #
##########################################

cd /root/CO8AAI/

yum -y install glibc-static

#chkrootkit 설치
wget ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz 

tar xvfz chkrootkit.tar.gz

mv chkrootkit-* chkrootkit

cd chkrootkit

make sense

rm -rf /root/CO8AAI/chkrootkit.tar.gz

#mod_security fail2ban.noarch arpwatch 설치
dnf -y install  mod_security mod_security_crs fail2ban arpwatch

sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/httpd/conf.d/mod_security.conf

#fail2ban 설치
service fail2ban start
chkconfig --level 2345 fail2ban on

sed -i 's,\(#filter = sshd-aggressive\),\1\nenabled = true,g;' /etc/fail2ban/jail.conf 

#clamav 설치
yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

cp /usr/share/doc/clamd/clamd.conf /etc/clamd.conf

sed -i '/^Example/d' /etc/clamd.conf
sed -i 's/User <USER>/User clamscan/' /etc/clamd.conf
sed -i 's/#LocalSocket /LocalSocket /' /etc/clamd.conf
sed -i 's/clamd.<SERVICE>/clamd.scan/' /etc/clamd.conf

chmod 755 /var/run/clamd.scan

sed 's/710/755/' /usr/lib/tmpfiles.d/clamd.scan.conf > /etc/tmpfiles.d/clamd.scan.conf
cp /etc/freshclam.conf /etc/freshclam.conf.bak
sed -i '/^Example/d' /etc/freshclam.conf

echo "# Run the freshclam as daemon
[Unit]
Description = freshclam scanner
After = network.target
[Service]
Type = forking
ExecStart = /usr/bin/freshclam -d -c 4
Restart = on-failure
PrivateTmp = true
[Install]
WantedBy=multi-user.target" >> /usr/lib/systemd/system/clam-freshclam.service

systemctl enable clam-freshclam.service
systemctl start clam-freshclam.service
mv /usr/lib/systemd/system/clamd\@.service /usr/lib/systemd/system/clamd.service
rm -rf /usr/lib/systemd/system/clamd.service

echo "[Unit]
Description = clamd scanner daemon
After = syslog.target nss-lookup.target network.target

[Service]
Type = simple
ExecStart = /usr/sbin/clamd -c /etc/clamd.conf --foreground=yes
Restart = on-failure
PrivateTmp = true

[Install]
WantedBy=multi-user.target" >> /usr/lib/systemd/system/clamd.service

sed -i '/^Example$/d' /etc/clamd.d/scan.conf
sed -i -e 's/#LocalSocket \/var\/run\/clamd.scan\/clamd.sock/LocalSocket \/var\/run\/clamd.scan\/clamd.sock/g' /etc/clamd.d/scan.conf

systemctl enable clamd.service

systemctl start clamd.service

systemctl stop clamd.service


mkdir /virus
mkdir /backup
mkdir /root/CO8AAI/php

#memcache 설치
dnf install -y memcached libmemcached php-pecl-memcache
systemctl enable memcached --now
sed -i 's/OPTIONS=""/OPTIONS="-l 127.0.0.1"/' /etc/sysconfig/memcached
systemctl restart memcached


echo "#mod_expires configuration" > /tmp/httpd.conf_tempfile
echo "<IfModule mod_expires.c>"   >> /tmp/httpd.conf_tempfile
echo "    ExpiresActive On"    >> /tmp/httpd.conf_tempfile
echo "    ExpiresDefault \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/css \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/javascript \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/x-javascript \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/x-javascript \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/javascript \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/jpeg \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/gif \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/png \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/bmp \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/cgm \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/tiff \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/basic \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/midi \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/mpeg \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-aiff \"access plus 1 days\""  >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-mpegurl \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "	  ExpiresByType audio/x-pn-realaudio \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-wav \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/x-shockwave-flash \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "</IfModule>"   >> /tmp/httpd.conf_tempfile
cat /tmp/httpd.conf_tempfile >> /etc/httpd/conf.d/mod_expires.conf
rm -f /tmp/httpd.conf_tempfile

##########################################
#                                        #
#            Local SSL 설정              #
#                                        #
##########################################

mv /root/CO8AAI/APM/etc/cron.daily/backup /etc/cron.daily/
mv /root/CO8AAI/APM/etc/cron.daily/check_chkrootkit /etc/cron.daily/

chmod 700 /etc/cron.daily/backup
chmod 700 /etc/cron.daily/check_chkrootkit


echo "00 20 * * * /root/check_chkrootkit" >> /etc/crontab
echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew" | sudo tee -a /etc/crontab > /dev/null
echo "01 01 * * 7 /root/CO8AAI/clamav.sh" >> /etc/crontab

#openssl 로 디피-헬만 파라미터(dhparam) 키 만들기 둘중 하나 선택
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#중요 폴더 및 파일 링크
ln -s /etc/httpd/conf.d /root/CO8AAI/conf.d
ln -s /etc/my.cnf /root/CO8AAI/my.cnf
ln -s /etc/php.ini /root/CO8AAI/php.ini
ln -s /etc/opt/remi/php56/php.ini /root/CO8AAI/php/php56.ini
ln -s /etc/opt/remi/php70/php.ini /root/CO8AAI/php/php70.ini
ln -s /etc/opt/remi/php71/php.ini /root/CO8AAI/php/php71.ini
ln -s /etc/opt/remi/php72/php.ini /root/CO8AAI/php/php72.ini
ln -s /etc/opt/remi/php73/php.ini /root/CO8AAI/php/php73.ini
ln -s /etc/opt/remi/php74/php.ini /root/CO8AAI/php/php74.ini

service httpd restart

cd /root/CO8AAI

##########################################
#                                        #
#             Cockpit install            #
#                                        #
########################################## 

dnf install -y cockpit

systemctl enable --now cockpit.socket

sh restart.sh

echo ""
echo ""
echo "축하 드립니다. APMinstaller 모든 작업이 끝났습니다."

exit 0

