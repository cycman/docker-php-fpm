FROM  registry.cn-hangzhou.aliyuncs.com/cyc_dev/php-fpm:php-fpm-8.4
MAINTAINER cyc <cclikecode@gmail.com>

RUN tdnf update -y && \
    tdnf install -y \
    gcc autoconf make automake \  # 编译工具（替代 build-essential）
    cronie \                      # 定时任务（替代 cron）
    vim rsyslog \                 # 文本编辑和日志工具
    c-ares-devel \                # c-ares 开发库（替代 libc-ares-dev）
    curl-devel \                  # curl 开发库（替代 libcurl4-openssl-dev）
    zlib-devel \                  # zlib 开发库（替代 zlib1g-dev）
    openssl-devel && \            # openssl 开发库（编译 swoole 需用）
    tdnf clean all  # 清理缓存，减小镜像体积

WORKDIR /root

# 安装 libsodium
ADD ./libsodium-1.0.20 ./libsodium-1.0.20
RUN cd ./libsodium-1.0.20 && ./configure && make && make install

# 安装 libsodium-php 扩展
ADD ./libsodium-php-2.0.22 ./libsodium-php-2.0.22
RUN cd ./libsodium-php-2.0.22 && \
    /opt/bitnami/php/bin/phpize && \
    ./configure --with-php-config=/opt/bitnami/php/bin/php-config && \
    make && make install

# 安装 swoole 扩展（合并目录切换命令，确保在同一 shell 中执行）
ADD ./swoole-v4.8.13 ./swoole-v4.8.13
ADD ./docker-entrypoint.sh ./
ADD ./rsyslog.conf /etc/rsyslog.conf
RUN chmod +x ./docker-entrypoint.sh

# 编译 swoole（合并为一个 RUN 指令，避免目录切换失效）
RUN cd ./swoole-v4.8.13 && \
    /opt/bitnami/php/bin/phpize && \
    ./configure \
    --with-php-config=/opt/bitnami/php/bin/php-config \
    --with-openssl-dir=/usr/lib/ssl \
    --enable-openssl \
    --enable-sockets \
    --enable-mysqlnd \
    --enable-swoole-curl \
    --enable-cares \
    --enable-swoole-pgsql && \
    make && make install

# 设置字符集（可选，根据需要保留）
#ENV LC_ALL C.UTF-8

ENTRYPOINT ["./docker-entrypoint.sh"]
