#!/bin/bash -l
HUBNAME=$1
sudo mkdir -p /mnt/${HUBNAME}/data
sudo mkdir -p /mnt/${HUBNAME}/user
sudo chown -R centos.centos /mnt/${HUBNAME}

if [ -d "/mnt/jupyter_config" ] 
then
    sudo mkdir /mnt/jupyter_config
    sudo chown -R centos.centos /mnt/jupyter_config
fi

sudo mkdir -p /mnt/jupyter_config/${HUBNAME}
sudo chown -R centos.centos /mnt/jupyter_config/${HUBNAME}

##
docker exec -t astro_belnginx nginx -s reload
docker exec -t astro_belnginx cat /etc/nginx/nginx.conf
