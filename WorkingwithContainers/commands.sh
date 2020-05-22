#!/bin/bash

#To get Help use below command 

docker --help
docker container --help # Get help on containers

# Create Nginx Container 
docker container run --name web01 nginx:latest
docker run --name web02 nginx:latest

# Common tasks for Docker 
docker container stop web01
docker container start web01
docker container restart web01

# List all running containers
docker container ls
docker ps

# List all containers created 
docker container ls -a
docker ps -a

# Remove container 
docker container rm web01
docker container rm $(docker container ls -aq) -f

# Inspect container (Get More details)
docker container inspect web01

# Get logs from  container
docker container logs web01 

# Connect to running container 
docker container exec -it web01 #interactive
docker container exec web01 ps
