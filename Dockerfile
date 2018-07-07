FROM alpine:3.8

# grab gosu for easy step-down from root
RUN apk add --no-cache curl \
    && curl -o /usr/local/bin/gosu -fsSL \
      "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu \
    && apk del curl

ENV GOROOT=/usr/lib/go \
    GOPATH=/go \
    PATH=$PATH:$GOROOT/bin:$GOPATH/bin

RUN apk add --no-cache bash libxml2 libxslt \
    && apk add --no-cache --virtual .build-dependencies jq curl git go ca-certificates g++ \
    # compile syncthing
    && VERSION=`curl -s https://api.github.com/repos/syncthing/syncthing/releases/latest | jq -r '.tag_name'` \
    && mkdir -p /go/src/github.com/syncthing \
    && cd /go/src/github.com/syncthing \
    && git clone https://github.com/syncthing/syncthing.git \
    && cd syncthing \
    && git checkout $VERSION \
    && go run build.go \
    && mkdir -p /go/bin \
    && mv bin/syncthing /go/bin/syncthing \
    && chown guest:users /go/bin/syncthing \
    # cleanup
    && rm -rf /go/pkg \
    && rm -rf /go/src \
    && apk del .build-dependencies

COPY data/entrypoint /entrypoint
RUN chmod 755 /entrypoint

ENV ST_CONFIG_DIR=/opt
ENV ST_DATA_DIR=/mnt
ENV ST_USER_ID=1000
ENV ST_GROUP_ID=1000
EXPOSE 8384 22000 21027/UDP

ENTRYPOINT ["/entrypoint"]
CMD ["run"]
