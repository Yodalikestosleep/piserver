#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting setup${nocl}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y shellinabox
sudo systemctl enable shellinabox
sudo systemctl start shellinabox
echo -e "${green}Shell In A Box is installed and running on Port 4200. Open with https://<your_ip>:4200.${nocl}"

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
echo -e "${green}Docker installed.${nocl}"

docker volume create portainer_data

docker run -d \
  -p 9000:9000 -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce

echo -e "${green}Portainer Installed.${nocl}"

curl -fsSL https://get.casaos.io | bash
echo -e "${green}CasaOS Installed.${nocl}"

echo -e "${green}Please reboot the system once for setup to take effect.${nocl}"
echo -e "${green}After reboot, run setup_post.sh${nocl}"

