sudo docker run -d \
  --name jellyfin \
  --restart=unless-stopped \
  --gpus all \
  -v ./config:/config \
  -v ./cache:/cache \
  -v /media/batman/Media/:/media_ext \
  --net=host \
  jellyfin/jellyfin:latest
