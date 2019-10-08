FROM golang:1.13 AS builder

WORKDIR /src
ENV CGO_ENABLED=0
ENV BUILD_HOST=syncthing.net
ENV BUILD_USER=docker

RUN apt-get update \
    && apt-get -y install jq

RUN VERSION=`curl -s https://api.github.com/repos/syncthing/syncthing/releases/latest | jq -r '.tag_name'` \
    && git clone https://github.com/syncthing/syncthing.git \
    && cd syncthing \
    && git checkout $VERSION \
    && go run build.go -no-upgrade build syncthing 

#---------------------------------------------------------------------------------------------

FROM alpine:3.10

# grab gosu for easy step-down from root
RUN apk add --no-cache curl \
    && curl -o /usr/local/bin/gosu -fsSL \
      "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu \
    && apk del curl

RUN apk add --no-cache ca-certificates bash

COPY --from=builder /src/syncthing/syncthing /bin/syncthing
COPY data/entrypoint /entrypoint
RUN chmod 755 /entrypoint

ENV ST_CONFIG_DIR=/opt
ENV ST_DATA_DIR=/mnt
ENV ST_USER_ID=1000
ENV ST_GROUP_ID=1000
EXPOSE 8384 22000 21027/UDP

ENTRYPOINT ["/entrypoint"]
CMD ["run"]
