### TODO 

Look for "todo" in this document to find open issues.

Remaining todos: [1]

# Cyberhubs

*Cyberhubs* is an implementation of a JupyterHub server with application specific and customizable _application hubs_ for multiple users that sign up with github authentication. Cyberhubs consist of two parts

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
2. The (optional) building of the Docker images of the multiuser and singleuser components of the corehub.
3. The configuration and deployment of the docker images into a running service. 

In most cases users wishing to deploy a cyberhub should not start by
building the Docker images themselves, but instead launch the service
from pre-built images available from the [Cyberhubs Docker
repository](https://hub.docker.com/u/cyberhubs/). The deployment prepraration and
procedure is, however, in both cases almost the same, with the only
difference that the _docker build_ step would be ommitted when
launching from pre-built docker images. For that reason, both options
are covered by this documentation and this repo, and the differences
in deployment will be clearly marked (see
[multiuser/README](./multiuser/README)).

 
## Configuring the host server
This section describes how the server on which the cyberhub is installed has to be configured.

In our example we will use a CentOS server running as a virtual
machine in the Compute Canada WestCloud on Arbutus located at the
University of Victoria and running OpenStack. We will also go over 
- generally - how to implement _cyberhubs_ on Amazon Web Services 
(AWS) EC2 free tier machine running Amazon Linux. Read here for 
more information on Amazon's Free Tier [here](https://aws.amazon.com/free/). 
The process is very similar for both implementations, where the 
AWS version is mainly meant as a test-ground for the technology 
rather than robust computationally heavy calculations or software development. 

### Launching the VM Compute Canada
* CentOS 7 machine with four cores, 15GB mem and 180GB attached hard drive
* Assign key pair in Access and Security
* Assign floating IP so that we can access from outside
* Associate IP address, and try to connect to IP

### Launching the VM on AWS
* Login to your account on AWS, and ensure you are elligible for the free tier.
* Launch a virtual machine: ![AWS Home](https://images.zenhubusercontent.com/5bc02597fcc72f27390ed1f9/857982d2-9f1d-4fc5-9102-db1a9e252043)
* Choose a virtual machine you'd like to launch. In this case we will be launching the _Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type_ be sure that it there is a Free Tier Eligible Banner available if you'd like to stay within the free tier. You can alternatively filter results by its free tier eligibility.
![AWS VM Choice](https://images.zenhubusercontent.com/5bc02597fcc72f27390ed1f9/d8069a6d-17dc-4660-b67e-82104c9eb386). 
* Next you can select the instance type - again look for the free tier banner. In this case we will be using the _t2.micro_ instance. ![InstanceType.PNG](https://images.zenhubusercontent.com/5bc02597fcc72f27390ed1f9/33f539b7-fb44-4a3c-b9e1-91e8255b7b5c)
* When ready, hit _Review and Launch_. 
* You can configure the storage and the tags for your new instance. In this case we will leave them as default. Note the default storage size is a 50GiB SSD.
* Next, select the _Configure Security Group_ tab from top bar. 
* The SSH port 22 is open by default, however, in order to access the JupyterHub page, HTTP (80) and HTTPS (443) should also be open. To open a new port click _Add Rule_ and add the ports for both HTTP and HTTPS.
![securityGroup.PNG](https://images.zenhubusercontent.com/5bc02597fcc72f27390ed1f9/d36a2e88-c485-4012-ae30-3f0e89ced5d4)
* When ready, hit _Review and Launch_.

### Key pairs
* After configuring the VM, you should be taken to a key pair page in which you can create and download an SSH key pair, or choose an existing one.
* To create a new pair, follow the on-screen prompts, download the `.pem` file and place it in your default SSH directory. On linux, this is usually in `~/.ssh`. 
![keypair.PNG](https://images.zenhubusercontent.com/5bc02597fcc72f27390ed1f9/bbdcae58-e5a9-4c40-a910-669773bb70b3)

### SSH into new instance
* Now that the instance is running, go to Amazon's Console to view running instances which should look like this:
![console.PNG](https://images.zenhubusercontent.com/5bc02597fcc72f27390ed1f9/6b63f3ea-f68b-4050-ae85-154e122b748b)
* SSH normally into your instance using the public IP address, or the 'IPv4 Public IP'.
* To use the SSH keys, use `ssh -i ~/.ssh/downloaded_key.pem ec2-user@XX.XXX.XXX.XXX`

### Prepare OS
* It is recommended to operate this service as a dedicated user, such as the default   `centos`, `amazon`, or `docker` user.
* Start with CentOS 7 or Amazon Linux AMI image
* Update all packages: `sudo yum update`
* Install the following packages:
 `sudo yum install git wget sshfs`
* Install epel-repository packages: `sudo yum install epel-release`
* Install [docker-ce (community edition)](https://docs.docker.com/engine/installation/linux/docker-ce/centos/)
	- `sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo`
	- `sudo yum install docker-ce-17.09.0.ce`
* choose a stable version, currently (Nov. 2017 - present) we use: `docker-ce-17.09.0.ce-1.el7'

### Get cyberhubs repo and configure disk volumes and mount points

Checkout `cyberlaboratories/cyberhubs` repository: 
```
git clone https://github.com/cyberlaboratories/cyberhubs
```

Before starting the docker service prepare some disk mount points and data locations. The docker images may not be stored in their default location `/var/lib/docker` because there may not be enough space in the system dir. Instead, prepare or arrange for additional drive at mount point `/mnt`. Then  move `/var/lib/docker` to `/mnt/var/lib`, and then set a symbolic link (see below).

- Given the layered file structure of docker images, the host can easily run out of inodes. It is recommended to be proactive and make an ext4 file system to host the system docker directory with large number of inodes: `mkfs -t ext4 -N 2147483648 /dev/XdY`. 
- This is also where the users containers will live and where some shared user space will be available.
- If you run out of space here you are in trouble as your docker installation may become unresponsive and difficult to resurrect.
- 100GiB (50GiB if using AWS) size is minimum for a small installation, a TB is much better, ideally fast storage, such as SSD.

Setup the `/mnt` volume correctly: 
* In the `scripts` directory of the `cyberhubs` repo review and execute `sudo ./mnt_volumses.sh`.
* This script will, among other things, set a link from  /mnt/var/lib/docker back to /var/lib/docker (where docker expects this system directory to be).
* Start the docker service, and add the user to the docker group and checking that the centOS user can execute as user.
```
sudo systemctl enable docker.service
sudo systemctl start docker
sudo docker run --rm hello-world
```

The last command should output _Hello from Docker!_ to signal success.

* Add dedicated user (e.g. `centos` or `docker`, see above) to docker group:
`sudo usermod -aG docker centos`, log out and in again, and check docker as user: `docker run --rm hello-world`
* install pip, [instructions](https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/)
```
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
```
* [install docker-compose](https://docs.docker.com/compose/install/), a helper to organize larger docker projects: `sudo pip install docker-compose`

This concludes the configuration of the host.

## Docker configuration

Start by cloning the [cyberhubs](https://github.com/cyberlaboratories/cyberhubs) repository. 

### Adding mount points and volumes
* Mount any external volumes you may want to add to the lab using `scripts/mnt_alias.sh`.
* This will create the `/mnt/` volumes as seen in the `config.DockerSpawner.`
* it appears the `/dev/fuse` device may not have the right permissions, this should fix it: `sudo chmod a+rw /dev/fuse` (may need more testings) 
* configure environment variables in `scripts/jupyterhub-config-script.sh`:
    * define `JUPYTER_HUB_AUTH_UR`, `JUPYTER_HUB_CLNT_ID`, `JUPYTER_HUB_CLNT_SE` (see next section)
    * define mount points of external storage: add private, shared and immutable data spaces.
    * define server admins: `JUPYTER_HUB_ADMN_NM`

### OAuth authentication and user configuration
* Register the jupyterhub application
[github registration](https://github.com/settings/applications/new) with GitHub. You need to enter
	- URL of the server (Homepage URL) - use `https`! For an Amazon instance, the public URL of your instance is located in the console page and is titled `Public DNS (IPv4)`.
	- server URL and add `/hub/oauth_callback`
* configure environment variables in `scripts/jupyterhub-config-script.sh`:
    * Specify the github admin user names 
    * Possibly specify allowed users (white listing, can not changed after multiuser is up) *todo:* there are some reports of white listing not always working as advertised, needs to be looked into    
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
**Note: There are a seperate steps for configuring SSL on AWS**
* A valid SSL key/certificate must be available to properly connect, see `README` in `corehub/multiuser/SSL` 

### Configure the spawner menu

This multiuser image allows specification and menu-based user
selection among several application hubs. The default is to offer
`corehub` and the application hub defined in the variable
```
export JUPYTER_SGLEUSR_IMG='cyberhubs/corehub:latest' 
```
in `scripts/jupyterhub-config-script.sh`. The spawner menu can easily be configured to
offer more option. This is specified in
`multiuser/jupyterhub_config.py`, look for lines such as
```
        <option value="cyberhubs/corehub">corehub</option>
```
in the function `def _options_form(self):`. Just add lines with available applicationhubs, such as
```
<option value="cyberhubs/wendihub">Wendi</option>
```
with locally available application hub docker images (`docker images`).

### Pulling the docker images and starting the service
* Pull an application hub(singleuser) image, such as `docker pull cyberhubs/corehub`, or one of the application images available from the [cyberhubs docker hub repp](https://hub.docker.com/u/cyberhubs/) (using `docker pull`), or build images from the source (e.g. if you need to modify or add software packages) available from the [cyberlaboratories/astrophubs GitHub](https://github.com/cyberlaboratories/astrohubs) repository.
* In case you want to build and modify the corehub image available in this [cyberlaboratories/cyberhubs](https://github.com/cyberlaboratories/cyberhubs) repository go to `corehub/singleuser` and build image: `make build`. In this case the image name will be `local/corehub` as specified in the `makefile`.
* Go to `multiuser` and consult the `README` file for options to build the multiuser image. In most cases you would use the [prebuilt multiuser docker image](https://hub.docker.com/r/cyberhubs/multiuser). You do not need to pull this image manually, it will by default be pulled during the next step.
* Launch the service: `docker-compose up` (add the option  `-d` to the end of the command to suppress the output). This will start your multiuser docker-environment. 
* For more commands, such as bringing down your docker environment, see the `corehub/dockerfiles/multiuser/README`, or at the bottom here.  

## Maintencance
### Prune unused images
In order to keep the system clean purge unused images from time to time using `docker image prune -a`.fnote

### Monitor and set number of processes
In a default configuration the user that is running the docker service (_centos_ in our case) may run against the processes number limit. Check number of processes with this command: `ps -efL --no-headers |wc -l`. In order to change the max number of processes add `nproc` in `/etc/security/limits.conf` to specify the new soft and hard limits.

## Basic docker
### Docker Hub repository
If you have created new singleuser hubs that you would like to share in the cyberhubs framework you can add these to the cyberhubs docker hub repository.

* get account on http://hub.docker.com
* [get added to cyberhubs organisation]
* login: `docker login --username=username`
* list all images: `docker images`

#### Pulling pre-built images from DockerHub.

* To pull corehub, after successfully logging in, you can get and run the images by:
```
docker pull cyberhubs/multisuer
docker pull cyberhubs/corehubsingeluser
```
* You can tag your images with whatever new name you'd like with `docker tag OLD_NAME NEW_NAME`. This is useful when building other images from cyberhubs/corehubsingleuser.

#### Pushing your images to DockerHub
* tag singleuser and multiuser image the image to be uploaded: `docker tag image_ID_321 cyberhubs/corehub` (for singleuser) and 
  `docker tag image_ID_123 cyberhubs/multiuser` (get the image ID with `docker images`)
* push to repository, for example: `docker push  cyberhubs/multiuser`

### Other useful commands
```
docker rmi $(docker images -q) # removes all docker images
docker-compose down; docker kill $(docker ps -aq); docker rm $(docker ps -aq) # stops all running Docker containers
docker images # lists all active Docker images
docker rmi --force  $(docker images -q) # Forces removal of Docker images
docker exec -it fherwig/corehub:multiuser bash # Enter bash (similar to SSH) into bash environment of running image
docker pull fherwig/corehub:singleuser # Take a docker image from the DockerHub 
docker pull -a fherwig/corehub # pull all images from repo on DockerHub
```

## Roadmap
The following improvements are planned to be implemented:
1. automatically renew certificats when needed (`certbot reniew --dry-run`, cronjob)
2. time-out open access followed by wlisting
3. add [jupyterlab Gitlab extension](https://github.com/jupyterlab/jupyterlab-github)
