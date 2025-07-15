#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting uninstall process...${nocl}"

# Stop and remove containers
docker rm -f portainer qbittorrent jellyfin || true

# Remove Docker volumes
docker volume rm portainer_data qbittorrent_config jellyfin_config jellyfin_cache || true

# Remove media directory
sudo rm -rf /srv/media

# Remove CasaOS
bash <(curl -fsSL https://get.casaos.io/uninstall.sh)

# Remove ShellInABox and Samba
sudo apt remove --purge -y shellinabox samba || true
sudo apt autoremove -y

# Remove Samba user
sudo deluser smbuser || true

# Remove CasaOS App JSONs if left behind
sudo rm -rf /var/lib/casaos || true

# Remove setup info file
rm -f setup_info.txt

# Remove Docker completely
sudo systemctl stop docker || true
sudo apt remove --purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
sudo apt autoremove -y
sudo rm -rf /var/lib/docker /etc/docker /var/run/docker.sock || true

echo -e "${green}Uninstallation complete. System cleaned.${nocl}"

