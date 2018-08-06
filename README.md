# basic-browser

## How to build the Basic Browser Docker image

```sh
git clone https://github.com/TheJacksonLaboratory/basic-browser.git 
docker build -t basic-browser .
```

## How to run Basic Browser 

```sh
docker run --name basic-browser \
    -p 8000:8000 \
    -v mongodb:/data/db \
    -v mysql:/var/lib/mysql basic-browser
```

## Enter in a Docker container already running with a new TTY

```sh
docker exec -ti basic-browser bash
```

