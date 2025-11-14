FROM bitnami/php-fpm:8.3
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

WORKDIR /root

ADD ./libsodium-1.0.20 ./libsodium-1.0.20
RUN cd ./libsodium-1.0.20 && ./configure && make && make install

WORKDIR /root
ADD ./libsodium-php-2.0.22 ./libsodium-php-2.0.22
RUN ls -la ./libsodium-php-2.0.22
RUN cd ./libsodium-php-2.0.22 && pwd
RUN cd ./libsodium-php-2.0.22 && chmod +r config.m4
RUN cd ./libsodium-php-2.0.22 && /opt/bitnami/php/bin/phpize 
RUN cd ./libsodium-php-2.0.22 && ./configure --with-php-config=/opt/bitnami/php/bin/php-config
RUN cd ./libsodium-php-2.0.22 && make && make install

RUN apt-get update && apt-get install -y libc-ares-dev && apt-get install -y libcurl4-openssl-dev && apt-get install -y zlib1g-dev && \
rm -rf /var/lib/apt/lists/* && \
apt-get clean
WORKDIR /root
ADD ./swoole-v4.8.13 ./swoole-v4.8.13
ADD ./docker-entrypoint.sh ./
ADD ./rsyslog.conf /etc/rsyslog.conf
RUN chmod +x ./docker-entrypoint.sh
RUN cd ./swoole-v4.8.13
#RUN  cd ./swoole-v4.8.13 &&  make clean 
RUN  cd ./swoole-v4.8.13 &&  /opt/bitnami/php/bin/phpize 
RUN cd ./swoole-v4.8.13 && ./configure --with-php-config=/opt/bitnami/php/bin/php-config --with-openssl-dir=/usr/lib/ssl --enable-openssl --enable-sockets --enable-mysqlnd --enable-swoole-curl --enable-cares --enable-swoole-pgsql
RUN cd ./swoole-v4.8.13 && make
RUN cd ./swoole-v4.8.13 && make install
#RUN docker-php-ext-install swoole


ENV LC_ALL C.UTF-8
ENTRYPOINT ["./docker-entrypoint.sh"]
