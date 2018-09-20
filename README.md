# Basic Browser


## Running Basic Browser
Below are the instructions to run Basic Browser docker image.

## Install Docker
 - [Install Docker for Mac](https://docs.docker.com/v17.09/docker-for-mac/install/)
 - [Install Docker for Windows](https://docs.docker.com/v17.09/docker-for-windows/install/)
 - [Install Docker for Ubuntu](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/#extra-steps-for-aufs)

## How to build the Basic Browser Docker image
```sh
git clone https://github.com/TheJacksonLaboratory/basic-browser.git
cd basic-browser
docker build -t basic-browser .
cd ..
```

## How to run Basic Browser
This creates a mongodb and mysql Docker volumes, which is useful for data persistence
```sh
docker run  -d --rm --name basic-browser \
       -p 8000:8000 \
       -v mongodb:/data/db \
       -v mysql:/var/lib/mysql \
       basic-browser
```
The basic browser should be running at localhost:8000. To upload track and data into the Basic Browser, a new TTY terminal must be opened in the container.
```sh
docker exec -ti basic-browser bash
```

## Create a username and password through the terminal the first time
```sh
cd /opt/basic/
python manage.py createsuperuser
```

## About Data persistence
When you ran the above command to start Basic browser, it created two volumes mongodb and mysql. You can see the volumes using the command `docker volume ls`. For the data to persist between sessions and between containers, make sure you dont delete these volumes.

## To delete the basic browser container
```
docker rm -f $(docker ps --filter name=basic-browser -q)
```

## To restart Basic Browser
```sh
docker restart basic-browser
```

## To make sure mysql, mongod, and basic browser are running
```sh
supervisorctl status all
```
