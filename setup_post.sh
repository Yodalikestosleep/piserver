#!/bin/bash
set -e


green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting post reboot setup...${nocl}"
echo -e "${green}Installing Portainer${nocl}"

docker rm -f portainer || true
docker run -d \
  -p 9000:9000 -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  -e TEMPLATES_URL="https://raw.githubusercontent.com/TomChantler/portainer-templates/refs/heads/v3/templates_v3.json" \
  portainer/portainer-ce

sudo mkdir -p /srv/media/downloads /srv/media/movies
sudo chown -R $USER:$USER /srv/media
echo -e "${green}Installing qbittorrent${nocl}"

docker volume create qbittorrent_config
docker rm -f qbittorrent || true
docker run -d \
  --name=qbittorrent \
  -e QBT_WEBUI_PORT=8181 \
  -e QBT_TORRENT_PORT=6881 \
  -p 8181:8181 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -p 6881:6881/tcp \
  -v qbittorrent_config:/config \
  -v /srv/media/downloads:/downloads \
  --restart=always \
  qbittorrentofficial/qbittorrent-nox


  
echo -e "${green}Installing jellyfin${nocl}"

docker volume create jellyfin_config
docker volume create jellyfin_cache
docker rm -f jellyfin || true
docker run -d \
  --name=jellyfin \
  --user $(id -u):$(id -g) \
  --restart=always \
  -p 8096:8096 \
  -v jellyfin_config:/config \
  -v jellyfin_cache:/cache \
  -v /srv/media:/media \
  jellyfin/jellyfin

echo -e "${green}Installing samba with username: smbuser. Enter password when prompted.${nocl}"

sudo apt install -y samba

sudo adduser --disabled-password --gecos "" smbuser </dev/tty >&2
sudo smbpasswd -a smbuser </dev/tty >&2

sudo tee -a /etc/samba/smb.conf > /dev/null <<EOF
[media]
   path = /srv/media
   browseable = yes
   writable = yes
   valid users = smbuser
   create mask = 0770
   directory mask = 0770
   public = no
EOF

sudo chown -R smbuser:smbuser /srv/media
sudo systemctl restart smbd

echo -e "${green}Samba installed. Share available at //<your-ip>/media (user: smbuser)${nocl}" 

mkdir -p /var/lib/casaos/apps/installed
mv apps/*.json /var/lib/casaos/apps/installed 2>/dev/null || mv apps/*.json /opt/casaos/apps 2>/dev/null

mkdir -p /srv/media/logs
echo -e "${green}Moving files...${nocl}" 
find /srv/media/downloads -type f -name "*.mkv" -exec mv {} /srv/media/movies/ \;

cat > setup_info.txt <<EOF
=======================================
       Application ports and info
=======================================

Shell In A Box:     http://<your-ip>:4200
Portainer:          http://<your-ip>:9000
qBittorrent:        http://<your-ip>:8181
Jellyfin:           http://<your-ip>:8096
CasaOS Dashboard:   http://<your-ip>:80
Samba Share:        //<your-ip>/media (user: smbuser)

Containers:
- portainer
- qbittorrent
- jellyfin

Volumes:
- portainer_data
- qbittorrent_config
- jellyfin_config
- jellyfin_cache

Media Folder:
- /srv/media (shared and used by apps)
EOF

echo -e "${green}Setup complete. Check setup_info.txt for access info.${nocl}" 
echo -e "${green}NOTE: qbittorrent and jellyfin are using the shared folder /srv/media/.${nocl}" 

