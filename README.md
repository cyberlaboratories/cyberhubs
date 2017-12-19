### TODO 

Look for "todo" in this document to find open issues.

Remaining todos: [2]

# Cyberhubs

*Cyberhubs* is an implementation of a JupyterHub server with application specific and customizable _hubs_ instances for multiple users that sign up with github authentication. Cyberhubs consist of two parts

* a multiuser launcher that orchestrates administration of multiple users, and
* a family of application docker _hubs_ (singleuser), each of which presents a data analytics capability targeting a particular user group or application usecase. These hubs can be combined. 

Cyberhubs is based on the Docker technology. This repo contains documentation and the necessary Dockerfiles and configuration files to either
1. to pull pre-built docker images available from [Cyberhubs on Docker Hub](https://hub.docker.com/u/cyberhubs) (this is the recommended option), or to 
2.  build the corehub multiuser and singleuser (hubs) docker images from scratch, 

and then, to launch the cyberhub to create a custrom virtual research environment. 

In both cases either the corehub singleuser application (refered to in short as _hubs_) included in this repository can be launched, or any of the singleuser applications in the associated _astrohubs_ repository. 
New singleuser application hubs can be easily created, or existing ones modified. 

#### Repository summary
* cyberhubs (this repository) provides the corehub multiuser launcher and basic corehub singleuser application _corehub_, while
* astrohubs provides a family of astronomy-oriented singleuser _hub_ applications.

All astrohubs and corehub multiuser and singleuser are available as pre-built docker images from [Cyberhubs on Docker Hub](https://hub.docker.com/u/cyberhubs). All astrohubs can be launched with the corehub multiuser docker image provided in this repository. 

#### About this documentation
This documentation describes
1. The configuration of a Linux server in order to host the core cyberhub.
2. The building of the Docker images of the multiuser and singleuser components of the corehub.
3. The configuration and deployment of the docker images into a running service. 

In most cases users wishing to deploy a cyberhub should not start by building the Docker images themselves, but instead launch the service from pre-built images available on [DockerHub](http://hub.docker.com). The deployment prepraration and procedure is, however, in both cases very similar, with the only difference that the _docker build_ step would be ommitted when
launching from pre-built docker images. For that reason, both options are
covered by this documentation and this repo, and the differences in
deployment will be clearly marked (see [multiuser/README](./multiuser/README)).

 
## Configuring the host server
This section describes how the server on which the cyberhub is installed has to be configured.

In our example we will use a CentOS server running as a virtual
machine in the Compute Canada WestCloud on Arbutus located at the
University of Victoria and running OpenStack.

### Launching the VM
* CentOS 7 machine with four cores, 15GB mem and 180GB attached hard drive
* Assign key pair in Access and Security
* Assign floating IP so that we can access from outside
* Associate IP address, and try to connect to IP

### Prepare Unix OS
* Start with CentOS 7 image
* Update all packages: `sudo yum update`
* Install the following packages:
 `sudo yum install git wget sshfs`
* Install epel-repository packages: `sudo yum install epel-release`
* Install [docker-ce (community edition)](https://docs.docker.com/engine/installation/linux/docker-ce/centos/)
* Install docker-engine: `sudo yum install docker-engine` **todo: figure out how this works - if you want to lock-in the version used at the time of writing use step 2 in the docker engine build steps in the above link to choose a stable version, as of Nov. 2017, this version is: `docker-ce-17.09.0.ce-1.el7`**

Before starting the docker service prepare some disk mount points and data locations.
The docker images may not be stored in their default location because there is not enough space  in the system dir. Instead move `/var/lib/docker` to `/mnt/var/lib`.

* prepare or arrange for additional drive at mount point `/mnt` 
    - Given the layered file structure of docker images, the host can easily run out of inodes. 
It is recommended to be proactive and make an ext4 file system with large number of inodes: `mkfs -t ext4 -N 2147483648 /dev/XdY`. 
    - this is where the users containers will live and where some shared user space will be available
    - if you run out of space here you are in trouble as your docker installation may become unresponsive and difficult to resurrect
    - 100GB size is minimum for a small installation, a TB is much better, ideally fast storage, such as SSD
* checkout corehub 'git clone '*todo: insert final URL here*
* make sure `/var/lib/docker` can live on external drive `/mnt/var/lib/docker` with more space by executing `scripts/mnt_volumses.sh`, 
* in the `scripts` directory execute `sudo ./mnt_volumses.sh`
* set a link, such as `sudo ln -s  /var/lib/docker /mnt/var/lib/docker `
* Start the docker servers, and add the user to the docker group and checking that the centOS user can execute as user.
```
sudo systemctl enable docker.service
sudo systemctl start docker
sudo docker run --rm hello-world
```

The last command should output _Hello from Docker!_ to signal success.

* Add user _centos_ to docker group:
`sudo usermod -aG docker centos`, log out and in again, and check docker as user: `docker run --rm hello-world`
* install pip, [instructions](https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/)
```
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
```
* [install docker-compose](https://docs.docker.com/compose/install/), a helper to organize larger docker projects: `sudo pip install docker-compose`

This concludes the configuration of the host.

## Docker configuration

Start py cloning the [cyberhubs](https://github.com/cyberlaboratories/cyberhubs) repository. 

### Adding mount points and volumes
* Mount any external volumes you may want to add to the lab using `scripts/mnt_alias.sh`.
* This will create the `/mnt/` volumes as seen in the `config.DockerSpawner.`
**todo: PERMISSION ERRORS WHEN EXECUTING SCRIPTS ??** 
* configure environment variables in `scripts/jupyterhub-config-script.sh`:
    * Mount points: add private, shared and immutable data spaces.

### OAuth authentication and user configuration
* Register the jupyterhub application
[github registration](https://github.com/settings/applications/new) with GitHub
* configure environment variables in `scripts/jupyterhub-config-script.sh`:
    * Specify the github admin user names 
    * Possibly specify allowed users (white listing, can not changed after multiuser is up, not flexible, *todo:* to be updated in next version)
    * Enter the call-back URL, the client_id and secret into.
    * Add the name of the singleuser docker container name
* `source /scripts/jupyterhub-config-script.sh`
* Optional whitelist and blacklist usage:
    * The directory  `access` under `multiuser/`that will contain the `blist` and `wlist` files if needed, the `multiuser/access/README.md`
    * If the `wlist`, `blist` and the whitelist environment variable in `scripts/jupyterhub-config-script.sh` are empty, then all the github users are allowed to log in.
    * If the `wlist` and/or the whitelist environment variable is not empty, then only the whitelisted users will be allowed to log in. 
    * The black list wins all the time: any user from the black list is denied access no matter what.
### Important Note Regarding Whitelisting and Blacklisting
* Any time the whiltelist or blacklist users have changed, the singleuser page _must_ be reloaded _not_ by simply refreshing the page, rather by clicking on the logo of the particular _astrohub_ _singleuser_ found in the upper left corner of the screen. 
* Another method is to re-visit the native URL of the _singleuser_ host.The reason this is necessary is because the request for authentification must be re-made. When the URL of the page is simply refreshed, it does not re-submit this request, and so the whitelist and blacklist changes will not be made or seen.   

### Configure SSL keys/certificates
* A valid SSL key/certificate must be available to properly connect, see `README` in `corehub/multiuser/SSL` 

### Deploying the pre-built docker images
* Before this step, the environment variables should be properly configured as outlined in the above step. Once the environment variables have been set, the next step is to deploy the existing singleuser corehub image from DockerHub.
```
docker pull cyberhubs/corehub
```
* Once the once the singleuser image has been deployed, the multiuser image can also be run by

```
docker-compose up
```

### Building the docker images from scratch (not recommended)
* Build the _singleuser_ and the _multiuser_ docker images; go to `cyberhubs/singleuser` and build image
```
make build
```
* Before building the _multiuser_ image you _must_ change the `docker-compose.yml` file in `cyberhubs/multiuser` to be used in _build_ mode and not _pull_ mode. This difference is documented within the `docker-compose.yml` file. Regular comments are denoted with `#:` where as comments to edit are denoted with just a `#`. Specific instructions are outline in the file itself, read carefully!

* After `docker-compose.yml` is changed, build the _multiuser_ image with
```
docker-compose build
```
* Note that this does not start the _multiuser_, so follow up with
```
docker-compose up
```
* This will start your _multiuser_ docker-environment. For more commands, such as bringing down your docker environment, see the `corehub/dockerfiles/multiuser/README.md` file. 

## Maintencance
### Prune unused images
In order to keep the system clean purge unused images from time to time using `docker image prune -a`.

### Monitor and set number of processes
In a default configuration the user that is running the docker service (_centos_ in our case) may run against the processes number limit. Check number of processes with this command: `ps -efL --no-headers |wc -l`. In order to change the max number of processes add `nproc` in `/etc/security/limits.conf` to specify the new soft and hard limits.

# Pushing and pulling docker images from Docker Hub
If you have created new singleuser hubs that you would like to share in the cyberhubs framework you can add these to the cyberhubs docker hub repository.

* get account on http://hub.docker.com
* [get added to cyberhubs organisation]
* login: `docker login --username=username`
* list all images: `docker images`

# Pulling pre-built images from DockerHub.

* To pull corehub, after successfully logging in, you can get and run the images by:
```
docker pull cyberhubs/multiuser
docker pull cyberhubs/corehubsingeluser
```
* You can tag your images with whatever new name you'd like with `docker tag OLD_NAME NEW_NAME`. This is useful when building other images from cyberhubs/corehubsingleuser.

# Pushing your images to DockerHub
* tag singleuser and multiuser image the image to be uploaded: `docker tag image_ID_321 cyberhubs/corehub` (for singleuser) and 
  `docker tag image_ID_123 cyberhubs/multiuser` (get the image ID with `docker images`)
* push to repository, for example: `docker push  cyberhubs/multiuser`

# Other useful commands
```
docker rmi $(docker images -q) # removes all docker images
docker-compose down; docker kill $(docker ps -aq); docker rm $(docker ps -aq) # stops all running Docker containers
docker images # lists all active Docker images
docker rmi --force  $(docker images -q) # Forces removal of Docker images
docker exec -it fherwig/corehub:multiuser bash # Enter bash (similar to SSH) into bash environment of running image
docker pull fherwig/corehub:singleuser # Take a docker image from the DockerHub 
docker pull -a fherwig/corehub # pull all images from repo on DockerHub
```
