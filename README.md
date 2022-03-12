monero-java-docker
------------------
A docker image for building the [monero-java](https://github.com/monero-ecosystem/monero-java) library natives for linux.

## Building
```
$ git clone <this>
$ cd monero-java-docker
$ docker build -t drew6017/monero-java-docker
```
Do somethin else, this is gonna take a while.

## Running
```
$ docker run --rm -it drew6017/monero-java-docker /bin/bash
```

You can also just `FROM drew6017/monero-java-docker:latest` in your Dockerfile.
