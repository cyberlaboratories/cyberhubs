# this script needs to be "sourced": 
# $ source ./mnt_alias.sh
# before doing this create all needed dirs with this command:
# `sudo ./mnt_volumses.sh`
# then use the mnt.xxx aliase to mount volumes

mntpoint='/mnt' 

# mounting a read-only data store
[ ! -d $mntpoint"/data/xyz" ] && mkdir $mntpoint"/data/xyz"
alias mnt.xyz="sshfs -o ro username@server.myhost.edu:/datastore1/xyz $mntpoint/data/xyz"
echo made mount alias mnt.xyz

# mounting a read-write data store
[ ! -d $mntpoint"/user/zyx" ] && mkdir $mntpoint"/user/zyx"
alias mnt.zyx="sshfs -o rw user@abc.phys.server.ca:/Volumes/zyx $mntpoint/user/zyx"
echo made mount alias mnt.zyx

# mount CADC VOspace
alias mnt.cadc="mountvofs --log=/mnt/tmp/logfile --cache_nodes --cache_dir=/mnt/tmp --mountpoint=$mntpoint/data/nugrid_vos --vospace=vos:nugrid"
echo made mount alias mnt.cadc

echo Now execute the mount aliases
