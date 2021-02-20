The multihub implementation is located in ~/cyberhubs

Configure multihub:
-------------------

0. In create_hub.sh and in multiuser_HUBNAME/jupyterhub_config.py fix
   references to user/group of operator of multihub user according to
   output of command "id".
   - in create_hub.sh in lines such as "sudo chown -R centos.centos ..."
   - in multiuser_HUBNAME scripts/jupyterhub-config-script.sh (export
     JUPYTER_USERGROUPID='user=1000:1000')

1. In the multihub folder generate ssl keys in the SSL folder as you
   used to do for multiuser

Q: how is multihub/SSL/dhparam.pem  made?
A: That’s just to increase the security. You can just keep using that
   one. If you want to generate a new one, just use: 
   openssl dhparam -out ./SSL/dhparam.pem 4096

2. change “206-12-97-9.cloud.computecanada.ca” in 
   - nginx.conf to the server name you decide on; it should have the
   form “your.domain.name” – this is the domain used when generating
   the ssl keys; and in
   - multiuser_HUBNAME/scripts/jupyterhub-config-script.sh in the
     JUPYTER_HUB_AUTH_UR variable

TODO: 
   - create_hub.sh needs to update !!HUBNAME!! in
     multiuser_HUBNAME/scripts/mnt_alias.sh
   - and in multiuser_HUBNAME/jupyterhub_config.py in
     "'/mnt/jupyter_config/!!hubname!!':'/jupyterhub_config'}" -
     although this should be a scripts/jupyterhub-config-script.sh
     variable and changed there.

3. Setup volumes and mount points needed to start multihub ("/mnt/var"
   "/mnt/var/lib" "/mnt/var/lib/docker" "/mnt/tmp") with
   "multihub/mnt_volumes.sh"

4. Run docker-compose build and docker-compose up to launch the
   multihub service

5a Create a new hub with the command ./create_hub.sh hubname n443
   (replace hubname and n in n443 with actual values) launched from
   the ~/cyberhubs dir; the directory multiuser_HUBNAME is the
   multiuser template dir; use port numbers with trailing digits n443,
   such as 4443, 5443 etc; check if port is free, e.g. `netstat -anp
   |grep :3443` should return nothing

5b Alternatively, if the hub dir already exists (e.g. after transfer
   to another server) don instead ./make_hub_dirs_and_start.sh HUBNAME

6. If needed delete a multiuser with the delete_hub.sh script.

Configure the newly created multiuser:
--------------------------------------

7. Generate the OAuth app ID and Secret on GitHub (or GitLab) by using
   https://your.domain.name/astro for the application URL and
   https://your.domain.name/astro/hub/oauth_callback

8. COnfigure the newly created multiuser:
   - adjust the OAuth variables in ./scripts/jupyterhub-config-script.sh
   - setup mnt_alias.sh and mount points for user and data, make sure
     /mnt/hubname exisits (see TODO below)

TODO: 
* create_hub.sh sets mountpoints for user and data for each new
  multiuser according to template in multiuser_ppmstar/mnt_volumses.sh.
* create_hub.sh will take mntpoint from multihub/mnt_volumes.sh 
* create_hub.sh sets JUPYTER_HUB_RO_PATH and JUPYTER_HUB_VL_PATH to
  include the multiusername into the user and data mount maps

Info: 
* the latest version of cyberhubs/multiuser now mounts a read-only
  jupyter_config dir that is located in the home directory, see
  https://github.com/cyberlaboratories/cyberhubs/blob/bf4a22b5e3d19d65d60ae0140d70ae77282a3f64/multiuser/jupyterhub_config.py#L120
  - the purpose is to post to be updated README_multiuser.ipynb file
  there that allow the operator to update READMEs for a multiuser
  instance without having to restart anythying. 
  - this will go into /mnt/jupyter_config and will be made in create_hub.sh


Note: All user_config dirs will be created in /mnt/jupyterhub_users to
      be identical accross all multiusers for each user.

TODO: 
* in jupyterhub_config.py put in environment variable for
  config.DockerSpawner.volumes variable (this needs to be done first
  in regular cyberhubs/multiuser)

9. Configure the tylenol.md and tylenol_db.py files that check if the
   mount points are still there and try to reestablish, if not; start
   or restart tylenol_dp.py (presently in
   csa-astrohubs-configs/tylenol repo)

10. Start multiuser:
     * "source scripts/jupyterhub-config-script.sh"
     * Then run “docker-compose up”.
     * The new multiuser is at https://your.domain.name/hubname

