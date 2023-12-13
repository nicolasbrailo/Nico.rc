# Implemented from https://help.ui.com/hc/en-us/articles/220066768-Updating-and-Installing-Self-Hosted-UniFi-Network-Servers-Linux-
# More inspiration here https://github.com/linuxserver/docker-unifi-network-application

# Unifi requires mongo 3.6, which is ancient and only runs in bionic
from ubuntu:bionic
RUN echo "Image generated $(date)" > /image.meta

# debconf gets confused if stdin isn't available
ARG DEBIAN_FRONTEND="noninteractive"

# Install pre-reqs
RUN apt-get update && \
        apt-get install -y apt-utils && \
        apt-get install -y wget binutils gnupg2 ca-certificates apt-transport-https net-tools iputils-ping

# Prepare apt
RUN wget -qO - https://www.mongodb.org/static/pgp/server-3.4.asc | apt-key add -
RUN wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add -
RUN echo "deb [trusted=yes] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN echo 'deb [arch=amd64 trusted=yes] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list
# Keys are expired, yay unifi and ancient mongo
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50

# Install unify
RUN apt-get --allow-unauthenticated update && apt-get --allow-unauthenticated install unifi -y

# Run settings
WORKDIR /usr/lib/unifi
EXPOSE 8080 8443 8843 8880
ENTRYPOINT /bin/bash -c echo "Starting..." && \
            chown -R unifi:unifi /var/lib/unifi && \
            chown -R unifi:unifi /var/log/unifi && \
            service unifi start && \
            while true; do sleep 1800; echo "Unifi controller in docker container: still alive!"; done

