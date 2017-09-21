### Terraform動作環境構築用DockerFile

docker build -t cent-terraform .  
docker run -d -it --network host --name terraform cent-terraform  
docker exec -it terraform /bin/bash  
