# Unifi requires mongo 3.6, which is ancient and only runs in bionic
from ubuntu:bionic
RUN echo "Image generated $(date)" > /image.meta

# Install pre-reqs
RUN apt-get update && apt-get install -y \
        binutils wget apt-utils gnupg2 ca-certificates apt-transport-https net-tools iputils-ping

# Prepare apt
RUN wget -qO - https://www.mongodb.org/static/pgp/server-3.6.asc | apt-key add -
RUN echo "deb https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN echo 'deb [ arch=amd64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50

# Install unify
RUN apt-get update && apt-get install unifi -y

# Run settings
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880
ENTRYPOINT /bin/bash
