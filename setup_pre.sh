#!/bin/bash
set -e
exec > log.txt 2>&1

green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting setup${nocl}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y shellinabox
sudo systemctl enable shellinabox
sudo systemctl start shellinabox

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

docker volume create portainer_data

docker run -d \
  -p 9000:9000 -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

curl -fsSL https://get.casaos.io | bash

echo -e "${green}Please reboot the system once for setup to take effect.${nocl}"
echo -e "${green}After reboot, run setup_post.sh${nocl}" 

