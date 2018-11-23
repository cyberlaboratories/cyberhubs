FROM ubuntu:18.04

MAINTAINER Falk Herwig
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8888
 
COPY apt_packages_corehub.txt /tmp/apt_packages_corehub.txt

RUN apt-get update && apt-get --no-install-recommends install --yes $(cat /tmp/apt_packages_corehub.txt) && \ 
    npm install -g configurable-http-proxy && \ 
    apt-get autoremove --yes && apt-get clean all && \ 
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip2 install --upgrade pip && \ 
    pip3 install --upgrade pip 
RUN pip2 install -U pip setuptools && \
    pip3 install -U pip setuptools

COPY jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser

ADD ./single_pip3_requirements_corehub.txt /tmp/requirements/single_pip3_requirements_corehub.txt 
ADD ./single_pip2_requirements_corehub.txt  /tmp/requirements/single_pip2_requirements_corehub.txt

RUN pip2 install -r /tmp/requirements/single_pip2_requirements_corehub.txt && \ 
    pip3 install -r /tmp/requirements/single_pip3_requirements_corehub.txt && \ 
    python2 -m bash_kernel.install && \ 
    python3 -m bash_kernel.install && \ 
    npm install --save-dev webpack

RUN jupyter serverextension enable --py jupyterlab --sys-prefix && \ 
    jupyter labextension install @jupyterlab/hub-extension && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager &&\
    jupyter labextension install jupyter-matplotlib &&\
    jupyter labextension install @mflevine/jupyterlab_html 

RUN useradd -d /home/user -m -c "" user && mkdir /home/user/notebooks

COPY singleuser.sh /srv/singleuser/singleuser.sh

RUN USER=user && \
    GROUP=user && \
    wget https://github.com/boxboat/fixuid/releases/download/v0.3/fixuid-0.3-linux-amd64.tar.gz &&\
    tar -C /usr/local/bin -xzf fixuid-0.3-linux-amd64.tar.gz && \
    rm -f  fixuid-0.3-linux-amd64.tar.gz &&\ 
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

RUN chown -R user:user /home/user && \
    chmod -R 775 /home/user/ && \
    chmod 775 /usr/local/bin/jupyterhub-singleuser && \
    chmod 775 /srv/singleuser/singleuser.sh 

USER user:user
ENTRYPOINT ["fixuid"]

ENV HOME /home/user
WORKDIR /home/user

COPY ipython_config.py /etc/ipython/ipython_config.py
CMD ["/bin/bash", "/srv/singleuser/singleuser.sh"]
