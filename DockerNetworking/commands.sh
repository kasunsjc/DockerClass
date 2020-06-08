#!/bin/bash

# Create Bridge Network
docker network create \
  --driver bridge \
  --attachable \
  --scope local \
  --subnet 10.0.42.0/24 \
  --ip-range 10.0.42.128/25 \
  user-network

# Run container using network created
docker container run -it \
  --network user-network \
  --name network-explorer \
  alpine:3.8 \
    sh

# Run IP command to view the network interfaces
ip -f inet -4 -o addr

# Create Second network
docker network create \
  --driver bridge \
  --attachable \
  --scope local \
  --subnet 10.0.43.0/24 \
  --ip-range 10.0.43.128/25 \
  user-network2

# connect the container to second container 
docker network connect \
  user-network2 \
  network-explorer

# Reattach the terminal to second network container
docker attach network-explorer
ip -f inet -4 -o addr

# Install nmap to view traffic
apk update && apk add nmap

# Use nmap to verify the conectivity 
nmap -sn 10.0.42.* -sn 10.0.43.* -oG /dev/stdout | grep Status

# Run another container in user-network2 to see the communication
docker run -d \
  --name lighthouse \
  --network user-network2 \
  alpine:3.8 \
    sleep 1d

# Reattach to the network explore
docker attach network-explorer

# Run nmap
nmap -sn 10.0.42.* -sn 10.0.43.* -oG /dev/stdout | grep Status

