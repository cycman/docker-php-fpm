#!/bin/bash
set -x

# 保存环境变量，开启crontab服务
env >> /etc/default/locale
/etc/init.d/rsyslog start

ln -sfT /dev/stdout "/var/log/cron"
#ln -sfT /dev/stdout "/var/log/cron"
#ln -sfT /dev/stderr "/var/log/cron"

/etc/init.d/cron start
php-fpm -F --pid /opt/bitnami/php/tmp/php-fpm.pid -y /opt/bitnami/php/etc/php-fpm.conf
