THIS_PATH:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
USER_ID:=$(shell id -u)
UNIFI_IMG_NAME=unifictrl_img_24feb

ctrlrcfg:
	mkdir -p "$(THIS_PATH)/$@"
ctrlrlogs:
	mkdir -p "$(THIS_PATH)/$@"

.PHONY: coldstart start stop sh rmcontainer build ls clean nuke installsystemdeps

# This mode will start the container sharing the host's network (no isolation)
# It should be more portable (no need to override Unifi settings) but has no isolation
coldstart: ctrlrcfg ctrlrlogs rmcontainer
	sudo docker run --detach --interactive --tty \
	                --env PUID=$(USER_ID) \
	                --env PGID=$(USER_ID) \
	                --name unifictrl \
	                --mount type=bind,source="$(THIS_PATH)/ctrlrcfg",target=/var/lib/unifi \
	                --mount type=bind,source="$(THIS_PATH)/ctrlrlogs",target=/var/log/unifi \
	                --network host \
	                --restart always \
	                $(UNIFI_IMG_NAME)

# This start mode will isolate the container's network, but requires overriding
# the 'inform address' (the address unifi devices connect to when adopting)
# More info: https://hub.docker.com/r/linuxserver/unifi-controller (Application setup)
coldstart_netisolation: ctrlrcfg ctrlrlogs rmcontainer
	sudo docker run --detach --interactive --tty \
	                --env PUID=$(USER_ID) \
	                --env PGID=$(USER_ID) \
	                --name unifictrl \
	                --mount type=bind,source="$(THIS_PATH)/ctrlrcfg",target=/var/lib/unifi \
	                --mount type=bind,source="$(THIS_PATH)/ctrlrlogs",target=/var/log/unifi \
	                --publish 8443:8443 \
	                --publish 3478:3478/udp \
	                --publish 10001:10001/udp \
	                --publish 8080:8080 \
	                --publish 8843:8843 \
	                --publish 8880:8880 \
	                --restart always \
	                $(UNIFI_IMG_NAME)

start:
	sudo docker start unifictrl

stop:
	sudo docker stop unifictrl || true

sh:
	sudo docker exec --interactive --tty unifictrl /bin/bash

rmcontainer: stop
	sudo docker container rm unifictrl || true

build:
	sudo docker build --tag $(UNIFI_IMG_NAME) .

build_update_img:
	sudo docker build --no-cache --tag $(UNIFI_IMG_NAME) .

ls:
	sudo docker images
	sudo docker container ls -a
	sudo docker ps

clean:
	sudo docker container prune
	sudo docker images prune -a

nuke: stop clean
	sudo docker images | grep -v ubuntu | tail -n+2 | awk '{print $3}' | xargs sudo docker image rm

installsystemdeps:
	sudo apt-get install docker.io

