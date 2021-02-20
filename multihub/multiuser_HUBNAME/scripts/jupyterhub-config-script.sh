export JUPYTER_HUB_AUTH_CL='AstroAuthenticator'
export JUPYTER_HUB_AUTH_UR='' # update
export JUPYTER_HUB_CLNT_ID=''   # update!
export JUPYTER_HUB_CLNT_SE=''   # update!
export JUPYTER_HUB_ADMN_NM=''  # update!
# white listing through this method can not be changed after multiuser has
# gone up, that's why we do not use it by default
# export JUPYTER_HUB_WHT_LST='allowed_user1,allowed_user2,allowed_user3' 
export JUPYTER_HUB_RO_PATH='/mnt/!!HUBNAME!!/data:/data'      # read-only data store
export JUPYTER_HUB_VL_PATH='/mnt/!!HUBNAME!!/user:/user'  # read-write user scratch space
#export JUPYTER_SGLEUSR_IMG='cyberhubs/corehub:latest'   # update this if needed
# use command id to determine UID and GID for host user and enter here, e.g.
# if id returns uid=41601(docker) gid=416(docker) groups=416(docker),10(wheel)
# then enter:
export JUPYTER_USERGROUPID='user=1000:1000'   # check that this is correct 

