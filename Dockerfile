FROM ubuntu:18.04

ENV MYSQL_HOME=/opt/mysql

RUN apt update && \
    apt install -y mysql-server && \
    apt install -y python3 python3-pip

# Copy necessary scripts + configuration
COPY scripts /tmp/
RUN chmod +x /tmp/*.py && \
    chmod +x /tmp/*.sh && \
    mv /tmp/* /usr/bin && \
    rm -rf /tmp/*

# Install MySQL
COPY ./apache-cassandra-3.11.5-bin.tar.gz configuration.yaml /opt/
RUN cd /opt && \
    tar -xzf apache-cassandra-3.11.5-bin.tar.gz && \
    mv apache-cassandra-3.11.5 ${CASSANDRA_HOME} && \
    rm -rf /opt/apache-cassandra-3.11.5-bin.tar.gz && \
    mv /opt/configuration.yaml ${CASSANDRA_HOME}/conf/cassandra.yaml

HEALTHCHECK --interval=45s --timeout=30s --start-period=60s --retries=3 CMD [ "healthcheck.sh" ]

EXPOSE 9042 7000

VOLUME [ "${CASSANDRA_HOME}/data", "${CASSANDRA_HOME}/logs" ]

WORKDIR /opt/cassandra

CMD [ "start.sh" ]