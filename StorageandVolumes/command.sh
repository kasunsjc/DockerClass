#!/bin/bash

# Get Storage Driver 
docker info | grep "Storage"

# Local Storage area
docker info | grep "Docker Root"

####################### Working with Bind Mounts ###################################

# Create Nginx Config file
touch ~/example.log
cat > ~/example.conf <<EOF
server {
  listen 80;
  server_name localhost;
  access_log /var/log/nginx/custom.host.access.log main;
  location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
  }
}
EOF

# Specify the Env veriables
CONF_SRC=~/example.conf; \
CONF_DST=/etc/nginx/conf.d/default.conf; \

LOG_SRC=~/example.log; \
LOG_DST=/var/log/nginx/custom.host.access.log; \

# Bind the file from host when running container
docker container run -d --name diaweb \
  --mount type=bind,src=${CONF_SRC},dst=${CONF_DST} \
  --mount type=bind,src=${LOG_SRC},dst=${LOG_DST} \
  -p 80:80 \
  nginx:latest

####################### Working with In Memory Storage ###################################

docker container run --rm \
    --mount type=tmpfs,dst=/tmp \
    --entrypoint mount \
    alpine:latest -v

####################### Working with Volumes ###################################

docker volume create \
    --driver local \
    --label example=location \
    location-example

docker volume inspect \
    --format "{{json .Mountpoint}}" \
    location-example

# Demo Use of Docker volume for NOSQL

# Create a volume for cassandra DB
docker volume create \
    --driver local \
    --label example=cassandra \
    cass-shared
# Run cassandra container
docker container run -d \
    --volume cass-shared:/var/lib/cassandra/data \
    --name cass1 \
    cassandra:2.2

# Exec to cassandra DB with linking from different container
docker container run -it --rm \
    --link cass1:cass \
    cassandra:2.2 cqlsh cass

# cassendra query to see key space names docker_hello_world 
# Null result
select *
from system.schema_keyspaces
where keyspace_name = 'docker_hello_world';

# Create cassendra key store
create keyspace docker_hello_world
with replication = {
    'class' : 'SimpleStrategy',
    'replication_factor': 1
};

# Rerun the command in line 71

# Stop and remove th container
docker container stop cass1
docker container rm -vf cass1

# Verify data is persistent
docker container run -d \
    --volume cass-shared:/var/lib/cassandra/data \
    --name cass2 \
    cassandra:2.2

docker container run -it --rm \
    --link cass2:cass \
    cassandra:2.2 \
    cqlsh cass

# Run cassandra query 
select *
from system.schema_keyspaces
where keyspace_name = 'docker_hello_world';
