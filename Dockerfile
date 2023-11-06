FROM bitnami/php-fpm:7.2.34
MAINTAINER cyc <cclikecode@gmail.com>

RUN apt-get update && \
    apt-get install -y gcc && \
    apt-get install -y autoconf && \
    apt-get install -y  build-essential && \
    apt-get install -y --no-install-recommends \
    cron && \
    apt-get install -y --no-install-recommends vim && \
    apt-get install -y --no-install-recommends rsyslog && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN apt-get update && apt-get install -y libc-ares-dev && apt-get install -y libcurl4-openssl-dev && \
rm -rf /var/lib/apt/lists/* && \
apt-get clean
WORKDIR /root
ADD ./swoole-v4.8.13 ./swoole-v4.8.13
ADD ./docker-entrypoint.sh ./
ADD ./rsyslog.conf /etc/rsyslog.conf
RUN chmod +x ./docker-entrypoint.sh
RUN cd ./swoole-v4.8.13
RUN  cd ./swoole-v4.8.13 &&  /opt/bitnami/php/bin/phpize 
RUN cd ./swoole-v4.8.13 && ./configure --with-php-config=/opt/bitnami/php/bin/php-config --with-openssl-dir=/usr/lib/ssl --enable-openssl --enable-sockets --enable-mysqlnd --enable-swoole-curl --enable-cares --enable-swoole-pgsql
RUN cd ./swoole-v4.8.13 && make
RUN cd ./swoole-v4.8.13 && make install
#RUN docker-php-ext-install swoole


ENV LC_ALL C.UTF-8
ENTRYPOINT ["./docker-entrypoint.sh"]
