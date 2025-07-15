#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting uninstall process...${nocl}"


docker rm -f portainer qbittorrent jellyfin || true


docker volume rm portainer_data qbittorrent_config jellyfin_config jellyfin_cache || true


sudo rm -rf /srv/media


curl -fsSL https://get.casaos.io/uninstall.sh -o casaos_uninstall.sh
sudo bash casaos_uninstall.sh || true
rm -f casaos_uninstall.sh

sudo apt remove --purge -y shellinabox samba || true
sudo apt autoremove -y


sudo deluser smbuser || true


sudo rm -rf /var/lib/casaos || true


rm -f setup_info.txt


sudo systemctl stop docker || true
sudo apt remove --purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
sudo apt autoremove -y
sudo rm -rf /var/lib/docker /etc/docker /var/run/docker.sock || true

echo -e "${green}Uninstallation complete. System cleaned.${nocl}"

