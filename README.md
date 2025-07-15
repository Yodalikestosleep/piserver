Raspberry PI docker media server setup script

This script automates the installation of basic self-hosted media and management server on raspberry-pi.

+Applications installed by it :

-Docker
-Portainer
-Jellyfin
-qBittorrent
-CasaOS as Dashboard
-Shell In A Box

🟥 **This script is intended for clean systems.**  
Running this on an existing setup **will remove Docker containers** if they share names.

1.Clone the repository to your local directory.

```shell


 ```bash
chmod +x setup_pre.sh setup_post.sh
./setup_pre.sh

** make sure to reboot the system after running setup_pre.sh

./setup_post.sh

You can edit the docker images/volumes according to yourself. This is a simple script to help out automation.
