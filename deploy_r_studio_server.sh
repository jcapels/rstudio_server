VOLUME_RSTUDIO_ENV=~/rstudio_server/dockspace/.Renviron
VOLUME_LIBRARY=~/rstudio_server/dockspace/R/library
VOLUME_CONFIGS=~/rstudio_server/dockspace/rstudio-prefs.json
WORKSPACE=~/rstudio_server/workspace/
PASSWORD=$(cat config/password.txt)
HOST_PORT=$(cat config/port.txt)

podman pull rocker/rstudio:latest
podman pod create -p $HOST_PORT:8787 --hostname rstudio_pod --name rstudio_pod --replace 
podman build . -t r_studio_server_image
podman run --rm \
           -d \
	   -e USER=$USER \
           --name r_studio_server \
           -v $VOLUME_RSTUDIO_ENV:/home/${USER}/.Renviron:Z,U \
           -v $VOLUME_LIBRARY:/home/${USER}/R/hostlibrary:Z,U \
           -v $VOLUME_CONFIGS:/etc/rstudio/rstudio-prefs.json:Z,U \
           -v $WORKSPACE:/home/${USER}/workspace:Z,U \
	   -e PASSWORD=$PASSWORD \
	   --pod rstudio_pod \
	   --expose 8787 \
	   -t rocker/rstudio:latest bin/bash
podman exec --user root r_studio_server /init
podman exec --user $USER r_studio_server chmod 777 /home/${USER}/workspace

