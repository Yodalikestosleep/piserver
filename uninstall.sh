#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting uninstall process...${nocl}"

docker rm -f portainer qbittorrent jellyfin || true
docker volume rm portainer_data qbittorrent_config jellyfin_config jellyfin_cache || true
sudo rm -rf /srv/media
bash <(curl -fsSL https://get.casaos.io/uninstall.sh)
sudo apt remove --purge -y shellinabox samba
sudo apt autoremove -y
sudo deluser smbuser || true
rm -f setup_info.txt

echo -e "${green}Uninstallation complete. System cleaned.${nocl}"

