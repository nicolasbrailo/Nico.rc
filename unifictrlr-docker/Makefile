THIS_PATH:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
USER_ID:=$(shell id -u)

ctrlrcfg:
	mkdir -p "$(THIS_PATH)/$@"
ctrlrlogs:
	mkdir -p "$(THIS_PATH)/$@"

.PHONY: coldstart start stop sh rmcontainer build ls clean nuke

coldstart: ctrlrcfg ctrlrlogs rmcontainer
	sudo docker run --detach --interactive --tty \
	                --env PUID=$(USER_ID) \
	                --env PGID=$(USER_ID) \
	                --name unifictrl \
	                --mount type=bind,source="$(THIS_PATH)/ctrlrcfg",target=/var/lib/unifi \
	                --mount type=bind,source="$(THIS_PATH)/ctrlrlogs",target=/var/log/unifi \
	                --publish 8080:8080 \
	                --publish 8443:8443 \
	                --publish 8843:8843 \
	                --publish 8880:8880 \
	                unifictrl_img

start:
	sudo docker start unifictrl

stop:
	sudo docker stop unifictrl || true

sh:
	sudo docker exec --interactive --tty unifictrl /bin/bash

rmcontainer: stop
	sudo docker container rm unifictrl || true

build:
	sudo docker build --tag unifictrl_img .

ls:
	sudo docker images
	sudo docker container ls -a
	sudo docker ps

clean:
	sudo docker container prune
	sudo docker images prune -a

nuke: clean
	sudo docker images | grep -v ubuntu | tail -n+2 | awk '{print $3}' | xargs sudo docker image rm

