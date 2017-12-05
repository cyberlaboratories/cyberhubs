export JUPYTER_HUB_AUTH_CL='oauthenticator.GitHubOAuthenticator'
export JUPYTER_HUB_AUTH_UR='https://your.server.com/hub/oauth_callback' # update!
export JUPYTER_HUB_CLNT_ID='your_client_ID from github application'     # update!
export JUPYTER_HUB_CLNT_SE='your_client_secret from github application' # update!
export JUPYTER_HUB_ADMN_NM='admin1,admin2'                        # update!
# white listing through this method can not be changed after multiuser has
# gone up, that's why we do not use it by default
# export JUPYTER_HUB_WHT_LST='allowed_user1,allowed_user2,allowed_user3' 
export JUPYTER_HUB_RO_PATH='/mnt/data:/data'      # read-only data store
export JUPYTER_HUB_VL_PATH='/mnt/user:/user'  # read-write user scratch space
export JUPYTER_SGLEUSR_IMG='cyberhubs/corehub:latest'   # update this if needed
