# execute with sudo;
# in this multihub version we are not creating 
# the data and user dirs; they will be created
# in mnt_volumes.sh scripts in the multiuser_HUBNAME
# dirs

mntpoint='/mnt'

create_dir() {
    if [ ! -d $1 ]
    then
	mkdir $1
	chown centos $1
	chgrp centos $1
    fi
}

printf "Made or checked dir: "
for dir in "/mnt/var" "/mnt/var/lib" "/mnt/var/lib/docker" "/mnt/tmp"  
do
    create_dir $dir
    printf $dir" "
done
echo ""
