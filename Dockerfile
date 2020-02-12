FROM ubuntu:19.04

RUN apt update && \
    useradd --create-home --shell /bin/bash mysql && \
    apt install -y mysql-server

# Copy necessary scripts + configuration
COPY scripts /tmp/
RUN chmod +x /tmp/*.sh && \
    mv /tmp/* /usr/bin && \
    rm -rf /tmp/*

COPY ./mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

HEALTHCHECK --interval=45s --timeout=30s --start-period=60s --retries=3 CMD [ "healthcheck.sh" ]

EXPOSE 3306

VOLUME /var/lib/mysql

CMD [ "start.sh" ]