#!/usr/bin/env bash

#####################################################################################
#                                                                                   #
# * APMinstaller v.1 with CentOS8                                                   #
# * CentOS-8-x86_64-1911                                                            #
# * Apache 2.4.X , MariaDB 10.4.X, Multi-PHP(base php7.2) setup shell script        #
# * Created Date    : 2020/04/15                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

echo "
 =======================================================

               < CO8AAI 설치 하기>

 =======================================================
"
echo "설치 하시겠습니까? 'Y' or 'N'"
read YN
YN=`echo $YN | tr "a-z" "A-Z"`
 
if [ "$YN" != "Y" ]
then
    echo "설치 중단."
    exit
fi

echo""
echo "설치를 시작 합니다."

#yum install -y glibc-langpack-en

cd /root/CO8AAI/APM

chmod 700 APMinstaller.sh

chmod 700 /root/CO8AAI/adduser.sh

chmod 700 /root/CO8AAI/deluser.sh

chmod 700 /root/CO8AAI/restart.sh

sh APMinstaller.sh

cd /root/CO8AAI

echo ""
echo ""
echo "CO8AAI 설치 완료!"
echo ""
echo ""
echo ""

echo "
 =======================================================

               < phpMyAdmin 설치 하기>

 =======================================================
"
echo "phpMyAdmin 설치 하시겠습니까? 'Y' or 'N'"
read YN
YN=`echo $YN | tr "a-z" "A-Z"`
 
if [ "$YN" != "Y" ]
then
    echo "설치 중단."
    exit
fi

echo""
echo "phpMyAdmin 설치를 시작 합니다."
cd /root/CO8AAI/APM

chmod 700 phpMyAdmin.sh

sh phpMyAdmin.sh

echo ""
echo ""
echo "phpMyAdmin 설치 완료!"
echo ""
echo ""
echo ""

#설치 파일 삭제
rm -rf /root/CO8AAI/APM
echo ""
rm -rf /root/CO8AAI/install.sh
echo ""
exit;

esac

