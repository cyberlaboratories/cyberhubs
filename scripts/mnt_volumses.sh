# execute with sudo, then source mnt_alias.sh

mntpoint='/mnt' # silver
# mntpoint='/gpod1' # gold

create_dir() {
    if [ ! -d $1 ]
    then
	mkdir $1
	chown centos $1
	chgrp centos $1
    fi
}

printf "Made or checked dir: "
for dir in "/mnt/var" "/mnt/var/lib" "/mnt/var/lib/docker" "/mnt/tmp"  $mntpoint"/data" $mntpoint"/user"
do
    [ ! -d $dir ] && create_dir $dir
    printf $dir" "
done
echo ""
