FROM ubuntu

MAINTAINER Falk Herwig

ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8888
 
COPY apt_packages_corehub.txt /tmp/apt_packages_corehub.txt

RUN apt-get update && apt-get --no-install-recommends install --yes $(cat /tmp/apt_packages_corehub.txt)
RUN npm install -g configurable-http-proxy
RUN apt-get autoremove --yes && apt-get clean all
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip2 install --upgrade pip 
RUN pip2 install -U pip setuptools
RUN pip3 install --upgrade pip
RUN pip3 install -U pip setuptools
#RUN sudo apt-get purge nodejs npm
#RUN curl -sL https://deb.nodesource.com/setup_$6.x | sudo -E bash - 

COPY jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser

ADD ./single_pip3_requirements_corehub.txt /tmp/requirements/single_pip3_requirements_corehub.txt 
ADD ./single_pip2_requirements_corehub.txt  /tmp/requirements/single_pip2_requirements_corehub.txt

RUN pip2 install -r /tmp/requirements/single_pip2_requirements_corehub.txt
RUN pip3 install -r /tmp/requirements/single_pip3_requirements_corehub.txt
RUN npm install --save-dev webpack
#RUN jupyter lab build
RUN jupyter serverextension enable --py jupyterlab --sys-prefix 
RUN jupyter labextension install @jupyterlab/hub-extension
RUN python2 -m bash_kernel.install 
RUN python3 -m bash_kernel.install 
RUN useradd -d /home/user -m -c "" user && mkdir /home/user/notebooks

# the following line may not be needed anymore with future versions of jupyterlab
# it fixes a bug in which themes where not packaged automatically
RUN jupyter-lab --generate-config

COPY singleuser.sh /srv/singleuser/singleuser.sh

RUN chown -R user:user /home/user && \
    chmod -R 775 /home/user/ && \
    chmod 775 /usr/local/bin/jupyterhub-singleuser && \
    chmod 775 /srv/singleuser/singleuser.sh 

USER user

ENV HOME /home/user
RUN echo Hi
WORKDIR /home/user

CMD ["/bin/bash", "/srv/singleuser/singleuser.sh"]