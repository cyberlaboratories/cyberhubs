export JUPYTER_HUB_AUTH_CL='AstroAuthenticator'
export JUPYTER_HUB_AUTH_UR='https://server.name.org/hub/oauth_callback' # update!
export JUPYTER_HUB_CLNT_ID='github_oauth_clntID'     # update!
export JUPYTER_HUB_CLNT_SE='github_oauth_clntSecret' # update!
export JUPYTER_HUB_ADMN_NM='admin_github_user_name'                        # update!
# white listing through this method can not be changed after multiuser has
# gone up, that's why we do not use it by default
export JUPYTER_HUB_WHT_LST='' 
export JUPYTER_HUB_RO_PATH='/mnt/data:/data'          # read-only data store
export JUPYTER_HUB_VL_PATH='/mnt/user:/user'          # read-write user scratch space
export JUPYTER_SGLEUSR_IMG='cyberhubs/corehub:latest' # update if needed, by default not used
# use command id to determine UID and GID for host user and enter here, e.g.
# if id returns uid=41601(docker) gid=416(docker) groups=416(docker),10(wheel)
# then enter:
export JUPYTER_USERGROUPID='user=1000:1000'   
