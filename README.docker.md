# Docker Setup

Frab can also be run inside a Docker container. Basic familiarity with docker is assumed in this guide.

In addition to a `Dockerfile` a basic `docker-compose.yml` file is also provided.


## Downloading the Docker Image

To download a pre-built docker image for frab from the [Docker Hub](https://hub.docker.com/r/frab/frab/):


```
docker pull frab/frab
```

## Building the Docker Image

You can also build the image yourself:


```
docker-compose build
```

or

```
docker build -t frab/frab .
```


## Configuration

The `Dockerfile` sets some basic default environment variables for frab to use including a sqlite3 database. However you should tune them to your own needs. This can be done by editing the `docker-compose.yml` file or passing the environment variables to the `docker run` command with the `-e` flag.

At a minimum you should change the default `SECRET_KEY_BASE` variable.

### Database Configuration

The default setup uses a sqlite3 database located in `/home/frab/data`. If you want it to persist across container restarts you should add a docker volume to that directory. Alternatively you can pass a `DATABASE_URL` environment variable to use another database like postgresql or mysql.

The example docker-compose file used another postgres container as a database.

# Running

To run frab with docker-compose just run:

```
docker-compose up
```

The initial admin username and password will be printed to stdout on first run.


To start the containers as a service run:

```
docker-compose up -d
```
