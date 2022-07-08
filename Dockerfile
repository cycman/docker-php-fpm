FROM bitnami/php-fpm:7.4
MAINTAINER cyc <cclikecode@gmail.com>

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cron && \
    apt-get install -y --no-install-recommends vim && \
    apt-get install -y --no-install-recommends rsyslog && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
WORKDIR /root
ADD ./docker-entrypoint.sh ./
ADD ./rsyslog.conf /etc/rsyslog.conf
RUN chmod +x ./docker-entrypoint.sh

ENV LC_ALL C.UTF-8
ENTRYPOINT ["./docker-entrypoint.sh"]
