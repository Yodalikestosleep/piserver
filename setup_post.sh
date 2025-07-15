#!/bin/bash
set -e
green='\033[0;32m'
nocl='\033[0m'

echo -e "${green}Starting post reboot setup...${nocl}"

docker rm -f portainer || true
docker run -d \
  -p 9000:9000 -p 9443:9443 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  -e TEMPLATES_URL="https://raw.githubusercontent.com/TomChantler/portainer-templates/refs/heads/v3/templates_v3.json" \
  portainer/portainer-ce

echo -e "${green}Portainer restarted with custom templates.${nocl}"

sudo mkdir -p /srv/media
sudo chown -R $USER:$USER /srv/media

docker volume create qbittorrent_config
docker rm -f qbittorrent || true
docker run -d \
  --name=qbittorrent \
  -e WEBUI_PORT=8181 \
  -p 8181:8181 \
  -p 6881:6881 \
  -p 6881:6881/udp \
  -v qbittorrent_config:/config \
  -v /srv/media:/downloads \
  --restart=always \
  linuxserver/qbittorrent

echo -e "${green}qBittorrent installed.${nocl}"

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

echo -e "${green}Jellyfin installed.${nocl}"
echo -e "${green}Installing samba with username : smbuser, Enter the password when prompted.${nocl}"

sudo apt install -y samba

sudo adduser --disabled-password --gecos "" smbuser
sudo smbpasswd -a smbuser

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

echo -e "${green}Samba installed. Share available at /<your-ip>/media (user: smbuser)${nocl}"

info_file="setup_info.txt"
cat > "$info_file" <<EOF
=======================================
       Application ports and info
=======================================

Shell In A Box:     http://<your-ip>:4200
Portainer:          http://<your-ip>:9000
qBittorrent:        http://<your-ip>:8181
Jellyfin:           http://<your-ip>:8096
CasaOS Dashboard:   http://<your-ip>:80
Samba Share:        /<your-ip>/media (user: smbuser)

Containers:
- portainer      -> ports: 9000, 9443
- qbittorrent    -> ports: 8181, 6881
- jellyfin       -> port: 8096

Shared Media Directory:
- /srv/media (used by jellyfin & qbittorrent)
- Network Share: <your-ip>/media

Volumes:
- portainer_data
- qbittorrent_config
- jellyfin_config
- jellyfin_cache
- srv/media (shared by jellyfina and qbittorrent)

EOF

echo -e "${green}Setup complete. Check setup_info.txt for access info.${nocl}"
echo -e "${green}Samba is using the same folder as qbittorrent and jellyfin.${nocl}"
