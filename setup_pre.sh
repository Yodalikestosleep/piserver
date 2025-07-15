#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo "${green}Starting setup${nocl}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y shellinabox
systemctl enable shellinabox
systemctl start shellinabox
echo "${green}Shell In A Box is installed and running on Port 4200. Open with https://<your_ip>:4200.${nocl}"

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
echo "${green}Docker installed.${nocl}"

docker volume create portainer_data

docker run -d \
	-p 9000:9000 -p 9443:9443 \
	--name=portainer \
	--restart=always \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v portainer_data:/data \
	portainer/portainer-ce

echo "${green}Portainer Installed.${nocl}"

curl -fsSl https://get.casaos.io | bash
echo "${green}CasaOS Installed.${nocl}"

echo "${green}Please reboot the system once for setup to take effect.${nocl}"
echo "${green}After reboot, run setup_post.sh${nocl}"

