FROM gliderlabs/alpine:3.4

# grab gosu for easy step-down from root
RUN apk-install curl \
    && curl -o /usr/local/bin/gosu -fsSL \
      "https://github.com/tianon/gosu/releases/download/1.9/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu \
    && apk del curl \
    && rm -rfv /var/cache/apk/*

RUN echo "@edge_community http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN apk-install syncthing@edge_community bash

COPY data/entrypoint /entrypoint
RUN chmod 755 /entrypoint

ENV ST_CONFIG_DIR=/opt
ENV ST_DATA_DIR=/mnt
ENV ST_USER_ID=1000
ENV ST_GROUP_ID=1000
EXPOSE 8384 22000 21027/UDP

ENTRYPOINT ["/entrypoint"]
CMD ["run"]
