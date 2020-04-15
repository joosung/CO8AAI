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
#           phpMyAdmin install           #
#                                        #
########################################## 
cd /root/CO8AAI/APM

wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz

tar -zxvf phpMyAdmin-5.0.2-all-languages.tar.gz

mv phpMyAdmin-5.0.2-all-languages /usr/share/phpMyAdmin

cp -pr /usr/share/phpMyAdmin/config.sample.inc.php /usr/share/phpMyAdmin/config.inc.php

BLOWFISH_SECRET=$(< /dev/urandom tr -dc 'A-Za-z0-9!@#' | head -c 32)
sed -i "s/\$cfg\['blowfish_secret'\] = '[^']*'/\$cfg\['blowfish_secret'\] = '${BLOWFISH_SECRET}'/g" /usr/share/phpMyAdmin/config.inc.php
sed -i 's/cookie/http/' /usr/share/phpMyAdmin/config.inc.php

mv phpMyAdmin.conf /etc/httpd/conf.d/

mkdir /usr/share/phpMyAdmin/tmp
chmod 777 /usr/share/phpMyAdmin/tmp

sh /root/CO8AAI/restart.sh

cd /root/CO8AAI/

echo ""
echo ""
echo "축하 드립니다. phpMyAdmin 설치 작업이 끝났습니다."

exit 0
