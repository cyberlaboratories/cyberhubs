import os
import sys
import subprocess
config = get_config()

# Extend GitHub OAuth to authenticate users using 
# whitelist and blacklist files
from oauthenticator import GitHubOAuthenticator
class AstroAuthenticator(GitHubOAuthenticator):
   def check_whitelist(self, username):
        wfname='/srv/jupyterhub/access/wlist'
        bfname='/srv/jupyterhub/access/blist'
        wl=set()
        bl=set()
        if os.path.isfile(wfname):
           wl = set([line.rstrip('\n').lower() for line in open(wfname)])
        if self.whitelist:
           wl =  wl | self.whitelist

        if os.path.isfile(bfname):
           bl = set([line.rstrip('\n').lower() for line in open(bfname)])
        if not wl and not bl:
           return True
        if bl and not wl:
           self.whitelist=self.whitelist-bl
           return username not in bl
        self.whitelist=wl-bl
        return username in self.whitelist

#For gitlab:
from oauthenticator.gitlab import GitLabOAuthenticator
class GitLabAstroAuthenticator(GitLabOAuthenticator):
   def check_whitelist(self, username):
        wfname='/srv/jupyterhub/access/wlist'
        bfname='/srv/jupyterhub/access/blist'
        wl=set()
        bl=set()
        if os.path.isfile(wfname):
           wl = set([line.rstrip('\n') for line in open(wfname)])
        if self.whitelist:
           wl =  wl | self.whitelist

        if os.path.isfile(bfname):
           bl = set([line.rstrip('\n') for line in open(bfname)])
        if not wl and not bl:
           return True
        if bl and not wl:
           self.whitelist=self.whitelist-bl
           return username not in bl
        self.whitelist=wl-bl
        return username in self.whitelist


config.JupyterHub.authenticator_class = globals()[os.environ['JUPYTER_HUB_AUTH_CL']] \
                                      if os.environ['JUPYTER_HUB_AUTH_CL'] in globals() \
                                      else os.environ['JUPYTER_HUB_AUTH_CL']

config.GitHubOAuthenticator.oauth_callback_url = os.environ['JUPYTER_HUB_AUTH_UR']
config.GitHubOAuthenticator.client_id = os.environ['JUPYTER_HUB_CLNT_ID']
config.GitHubOAuthenticator.client_secret = os.environ['JUPYTER_HUB_CLNT_SE']


# set of usernames of admin users config.Authenticator.admin_users =
# set(os.environ['JUPYTER_HUB_ADMN_NM'].split(','))

# white list from scripts/jupyterhub-config-script.sh (can not be
# changed after launch, use blist file instead)
# if whitelist environment variable is blank, do not assign it to anything.
if os.environ['JUPYTER_HUB_WHT_LST']!='':
    config.Authenticator.whitelist = set(os.environ['JUPYTER_HUB_WHT_LST'].split(','))

# Spawn users in dockers
network_name = os.environ["DOCKER_NETWORK_NAME"]
hub_ip = os.environ["DOCKER_MACHINE_NAME"]

from dockerspawner import DockerSpawner                       
from traitlets import default                                 
class NBLabDockerSpawner(DockerSpawner):                      
    @default('options_form')                                  
    def _options_form(self):                                  
        default_jpynb = "notebook"                            
        default_imgSelect = os.environ['JUPYTER_SGLEUSR_IMG']                            
        return """                                            
        <label for="nbtype">Jupyter: </label>
        <select name="nbtype" size="1">                       
        <option value="labhub">Jupyter Lab</option>           
        <option value="notebook">Jupyter Notebook</option>    
        </select><br>                                             
        <label for="imgSelect">Application: </label>
        <select name="imgSelect" size="1">
        <option value="cyberhubs/mesahub">MESAHub: Run and analyse MESA/NuGrid simulations</option>
        <option value="cyberhubs/basichub">BasicHub: Common Python and Linux utilities</option>
        <option value="local/ppmstar">EtaMu</option>
        </select>
        """.format(nbtype=default_jpynb,imgSelect=default_imgSelect)                      
                                                               
    def options_from_form(self, formdata):                    
        options = {}                                          
        options['nbtype'] = formdata['nbtype']                
        default_url = ''.join(formdata['nbtype'])             
        imgval=''.join(formdata['imgSelect'])
        if imgval == "viaenv":            
           self.container_image=os.environ['JUPYTER_SGLEUSR_IMG']
        else:
           self.container_image=imgval
        self.notebook_dir = "/home/user/notebooks"            
        if default_url == "labhub":                           
            self.notebook_dir = "/home/user"            
            self.default_url = "/lab"                         
        else:                                                 
            self.default_url = "/tree"                        
           #options['nbtype']=['--SingleUserNotebookApp.default_url='+self.default_url,
           #                   '--notebook_dir='+self.notebook_dir]
           #print("Belaid: Setting options "+' '.join(options['nbtype']))
        return options                                        
    def get_args(self):
        argv = super().get_args()                             
        if self.user_options.get('nbtype'):                   
            argv.extend(self.user_options['nbtype'])          
        return argv                                           

# create persistent work dir of users
def create_workdir (spawner):
    username = spawner.user.name
    volume_path = os.path.join('/jupyterhub_users', username)
    if not os.path.exists(volume_path):
        os.mkdir(volume_path, 0o755)
        #Adjust the permissions if necessary – to match that of the container
        # 1000 is the uid under which singleuser container is running...
        os.system('chown -R 1000.1000 '+volume_path)  # !! this needs updating
config.Spawner.pre_spawn_hook = create_workdir

# locations of mounted volumes
# TODO: variables for /home/centos/jupyter_config and /mnt/jupyterhub_users/{username}
config.DockerSpawner.read_only_volumes = \
   {os.environ['JUPYTER_HUB_RO_PATH'].split(':')[0]:os.environ['JUPYTER_HUB_RO_PATH'].split(':')[1], \
    '/mnt/jupyter_config/!!hubname!!':'/jupyterhub_config'} 
config.DockerSpawner.volumes = \
   {'/mnt/jupyterhub_users/{username}': '/home/user/{username}_config', \
    os.environ['JUPYTER_HUB_VL_PATH'].split(':')[0]:os.environ['JUPYTER_HUB_VL_PATH'].split(':')[1] }
 
# spawn from our spawner:
config.JupyterHub.spawner_class = NBLabDockerSpawner              
# spawn from system spawner:
#config.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'

#config.DockerSpawner.container_image = os.environ['JUPYTER_SGLEUSR_IMG']
config.DockerSpawner.use_internal_ip = True
config.DockerSpawner.network_name = network_name
config.DockerSpawner.extra_create_kwargs = \
     {os.environ['JUPYTER_USERGROUPID'].split('=')[0]:os.environ['JUPYTER_USERGROUPID'].split('=')[1]}
config.DockerSpawner.extra_host_config = {"network_mode":network_name}
config.DockerSpawner.remove_containers = True
config.DockerSpawner.hub_ip_connect = hub_ip
config.DockerSpawner.name_template=hub_ip+"_{prefix}-{username}"

# this is now set in NBLabDockerSpawner class
#config.DockerSpawner.notebook_dir = "/home/user/notebooks"
#config.DockerSpawner.notebook_dir = "/home/user"

# Enable Admin to access any user server.
# This option should be set to False or undefined unless testing.
#config.JupyterHub.admin_access = True

# create system users that don't exist yet
config.LocalAuthenticator.create_system_users = True

# the docker instances need to access the HUB                                             
config.JupyterHub.hub_ip = hub_ip
config.JupyterHub.hub_port = 8000

# ssl is handled by nginx so set to 1443
#config.JupyterHub.ip='172.20.0.1'
config.JupyterHub.port = 1443
###Belaid: please read this from the outside - mount a volume from the host.
#config.JupyterHub.ssl_cert = '/srv/jupyterhub/SSL/ssl.crt'
#config.JupyterHub.ssl_key = '/srv/jupyterhub/SSL/ssl.key'
config.JupyterHub.base_url = '/!!HUBNAME!!/'

# make cookie secret and auth token
cookie = subprocess.Popen(["openssl", "rand", "2049"], stdout=subprocess.PIPE)
token = subprocess.Popen(["openssl", "rand", "-hex", "129"], stdout=subprocess.PIPE)
config.JupyterHub.cookie_secret = cookie.communicate()[0][:-1]
config.JupyterHub.proxy_auth_token = token.communicate()[0][:-1]
config.JupyterHub.log_level = 'DEBUG'
config.JupyterHub.debug_proxy=True
#Logo:                                                                                                                  
config.JupyterHub.logo_file = '/srv/jupyterhub/logo/logo.png'

# Enable debug-logging of the single-user server
#config.Spawner.debug = True

# Enable debug-logging of the single-user server
config.LocalProcessSpawner.debug = True
config.Application.log_level = 'DEBUG'
config.JupyterHub.debug_db = True
config.DockerSpawner.debug = True