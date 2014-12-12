FROM dockerfile/ubuntu

# Add TokuMX official apt source to the sources list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 505A7412
RUN echo "deb [arch=amd64] http://s3.amazonaws.com/tokumx-debs $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tokumx.list

# Install TokuMX
RUN apt-get update
RUN apt-get upgrade -yqq
RUN apt-get -yqq install tokumx psmisc
RUN apt-get -yqq clean
RUN rm -rf /var/lib/apt/lists/*

# Define mount points.
VOLUME ["/data/db", "/data/logs", "/data/meta"]

# Define working directory.
WORKDIR /data

RUN mkdir -p /data/db
RUN mkdir -p /data/meta
RUN mkdir -p /data/logs

ENV MONGODB_DATA_PATH /data/db
ENV MONGODB_METADATA_PATH /data/meta
ENV MONGODB_LOGS_PATH /data/logs
ENV MONGODB_MAIN_PORT 27017
ENV MONGODB_ROUTER_PORT 27018
ENV MONGODB_CONFIG_PORT 27019
ENV MONGOD_CONFIG_FILE /usr/local/etc/mongod.cfg
ENV MONGOD_CFG_CONFIG_FILE /usr/local/etc/mongod-cfg.cfg
ENV MONGOS_CONFIG_FILE /usr/local/etc/mongos.cfg

ADD tokumx-startup.sh /usr/local/sbin/tokumx-startup.sh
ADD mongod.cfg /usr/local/etc/mongod.cfg
ADD mongod-cfg.cfg /usr/local/etc/mongod-cfg.cfg
ADD mongos.cfg /usr/local/etc/mongos.cfg
RUN chmod 755 /usr/local/sbin/tokumx-startup.sh

CMD /usr/local/sbin/tokumx-startup.sh

EXPOSE 27017 27018 27019 28017