# Syncthing docer container

## Usage

```bash
docker run \
  -it --rm \
  --name=syncthing \
  -v <my_config_direcotry>:/opt \
  -v <my_data_dir>:/mnt \
  -e ST_USER_ID=<uid> -e ST_GROUP_ID=<gid>  \
  -p 8384:8384 -p 22000:22000 -p 21027:21027/udp \
  skopciewski/syncthing
```

