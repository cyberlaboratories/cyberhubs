#!/bin/bash -l
HUBNAME=$1
PORT=$2

cp -r multiuser_HUBNAME multiuser_${HUBNAME}
cd multiuser_${HUBNAME}
sed -i "s@\!\!HUBNAME\!\!@${HUBNAME}@g" ./scripts/jupyterhub-config-script.sh
sed -i "s@\!\!HUBNAME\!\!@${HUBNAME}@g" .env
sed -i "s@\!\!HUBNAME\!\!@${HUBNAME}@g" ./jupyterhub_config.py

sudo mkdir -p /mnt/${HUBNAME}/data
sudo mkdir -p /mnt/${HUBNAME}/user
sudo chown -R centos.centos /mnt/${HUBNAME}
y
if [ -d "/mnt/jupyter_config" ] 
then
    sudo mkdir /mnt/jupyter_config
    sudo chown -R centos.centos /mnt/jupyter_config
fi

sudo mkdir -p /mnt/jupyter_config/${HUBNAME}
sudo chown -R centos.centos /mnt/jupyter_config/${HUBNAME}

echo "You will need to generate the OAuth ID and Secret key for https://your.domain.name/${HUBNAME}/hub/oauth_callback"

sed -i "s@\!\!PORT\!\!@${PORT}@g" docker-compose.yml

echo "Adding the ${HUBNAME} to nignx.conf file under multihub, and reloading the configuration ..."
nginx_str='
    location /HUBNAME {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:PORT;

        # websocket headers
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
    }
    #LOCATION#
'
newlocation=`echo "$nginx_str" |sed -e "s@HUBNAME@$HUBNAME@g" |sed -e "s@PORT@$PORT@g"` # 2>&1 |tee nignx_${HUBNAME}.conf
cp ../multihub/nginx.conf ../multihub/nginx_template.conf
perl -i -pe 's@#LOCATION#@'"${newlocation}"'@g' ../multihub/nginx_template.conf
cp ../multihub/nginx_template.conf ../multihub/nginx.conf
##
docker exec -t astro_belnginx nginx -s reload
docker exec -t astro_belnginx cat /etc/nginx/nginx.conf
