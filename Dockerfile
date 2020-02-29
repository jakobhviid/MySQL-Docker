FROM ubuntu:19.10

ENV MYSQL_HOME=/etc/mysql
ENV MYSQL_DATA_HOME=/var/lib/mysql

RUN apt update && \
    useradd --create-home --shell /bin/bash mysql && \
    apt install -y mysql-server

RUN rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Copy necessary scripts + configuration
COPY scripts /tmp/
RUN chmod +x /tmp/*.sh && \
    mv /tmp/* /usr/bin && \
    rm -rf /tmp/*

COPY ./mysqld.cnf ${MYSQL_HOME}/mysql.conf.d/mysqld.cnf

HEALTHCHECK --interval=45s --timeout=30s --start-period=60s --retries=3 CMD [ "healthcheck.sh" ]

EXPOSE 3306

VOLUME ${MYSQL_DATA_HOME}

CMD [ "start.sh" ]