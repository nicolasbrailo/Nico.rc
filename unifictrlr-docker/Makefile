
run:
	sudo docker run --interactive --tty \
								  --publish 8080:8080 \
								  --publish 8443:8443 \
								  --publish 8843:8843 \
								  --publish 8880:8880 \
									unifictrlr

build:
	sudo docker build -t unifictrlr .

ls:
	sudo docker images
	sudo docker container ls -a

nuke:
	sudo docker container prune
	sudo docker images prune -a
	sudo docker images | grep -v ubuntu | tail -n+2 | awk '{print $3}' | xargs sudo docker image rm

