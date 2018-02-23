# execute with sudo, then source mnt_alias.sh

set -x 

docker_user=docker  # s5
#docker_user=centos  # compute canadat

mntpoint='/mnt/scratch/dockerstuff' # s5
#mntpoint='/mnt' # silver
# mntpoint='/gpod1' # gold

create_dir() {
    if [ ! -d $1 ]
    then
	mkdir $1
	chown $docker_user $1
	chgrp $docker_user $1
    fi
}

printf "Made or checked dir: "
for dir in $mntpoint"/var" $mntpoint"/var/lib" $mntpoint"/var/lib/docker" $mntpoint"/tmp"  $mntpoint"/data" $mntpoint"/user"
do
    [ ! -d $dir ] && create_dir $dir
    printf $dir" "
done
echo ""
