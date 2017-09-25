### Terraform動作環境構築用DockerFile

docker build -t terraform_img .  
docker run -d -it --rm --network host --name cent-terraform terraform_img 
docker exec -it cent-terraform /bin/bash  
