docker volume prune -f
docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)
docker volume ls
docker images
