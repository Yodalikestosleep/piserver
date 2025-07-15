#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo "${green}Starting post reboot setup${nocl}"

docker rm -f portainer || true
docker run -d \
	-p 9000:9000 -p 9443:9443 \
	--name=portainer \
	--restart=always \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v portainer_data:/data \
	-e TEMPLATES_URL="https://raw.githubusercontent.com/TomChantler/portainer-templates/refs/heads/v3/templates_v3.json" \
	portainer/portainer-ce
echo "${green}Changed the TEMPLATES_URL with v3 URL by TomChantler${nocl}"
echo "${green}Portainer Restarted.${nocl}"

docker volume create qbittorrent_config
docker volume create qbittorrent_downloads
docker rm -f qbittorrent || true
docker run -d \
	--name=qbittorrent \
	-e WEBUI_PORT=8181 \
	-p 8181:8181 \
	-p 6881:6881 \
	-p 6881:6881/udp \
	-v qbittorrent_config:/config \
	-v qbittorrent_downloads:/downloads \
	--restart=always \
	linuxserver/qbittorrent
echo "${green}qBittorrent installed${nocl}"

docker volume create jellyfin_config
docker volume create jellyfin_cache
docker volume create jellyfin_media
docker rm -f jellyfin || true
docker run -d \
	--name=jellyfin \
	--user $(id -u):$(id -g) \
	--restart=always \
	-p 8096:8096 \
	-v jellyfin_config:/config \
	-v jellyfin_cache:/cache \
	-v jellyfin_media:/media \
	jellyfin/jellyfin
echo "${green}Jellyfin installed${nocl}"

echo "${green}Please wait ....${nocl}"
sleep 30s

echo "${green}Adding Docker apps to CasaOS...${nocl}"
APPS_DIR="/var/lib/casaos/apps"

# Create folders and copy configs
sudo mkdir -p "$APPS_DIR/portainer"
sudo cp apps/portainer.json "$APPS_DIR/portainer/conf.json"

sudo mkdir -p "$APPS_DIR/qbittorrent"
sudo cp apps/qbittorrent.json "$APPS_DIR/qbittorrent/conf.json"

sudo mkdir -p "$APPS_DIR/jellyfin"
sudo cp apps/jellyfin.json "$APPS_DIR/jellyfin/conf.json"

# Restart CasaOS
sudo systemctl restart casaos
echo "${green}CasaOS apps added. Refresh the dashboard.${nocl}"

info_file="setup_info.txt"
cat > "$info_file" <<EOF
=======================================
       Installed Application Info
=======================================

Shell In A Box:     http://<your-ip>:4200
Portainer:          http://<your-ip>:9000
qBittorrent:        http://<your-ip>:8181
Jellyfin:           http://<your-ip>:8096
CasaOS Dashboard:   http://<your-ip>:80

Containers:
- portainer      -> ports: 9000, 9443
- qbittorrent    -> ports: 8181, 6881
- jellyfin       -> port: 8096

Volumes:
- qbittorrent_config
- qbittorrent_downloads
- jellyfin_config
- jellyfin_media
- jellyfin_cache
- portainer_data

All containers are set to restart automatically and have persistent volumes.
EOF

echo "${green}Setup complete. Please check setup_info.txt for port info.${nocl}"

