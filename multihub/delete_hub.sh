#!/bin/bash -l
HUBNAME=$1
PORT=$2
mv multiuser_${HUBNAME} backup_multiuser_${HUBNAME}
cp ./multihub/nginx.conf ./multihub/nginx_template.conf
perl -0777 -i -pe 's@\s*location /'"$HUBNAME "'{.*?}@@igs' ./multihub/nginx_template.conf
cp ./multihub/nginx.conf ./multihub/backup_nginx.conf
cp ./multihub/nginx_template.conf ./multihub/nginx.conf
#docker exec -t astro_belnginx nginx -s reload
#docker exec -t astro_belnginx cat /etc/nginx/nginx.conf
