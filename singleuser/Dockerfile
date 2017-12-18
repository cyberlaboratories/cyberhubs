FROM ubuntu:16.04

MAINTAINER Falk Herwig

ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8888
 
COPY apt_packages_corehub.txt /tmp/apt_packages_corehub.txt

RUN apt-get update && apt-get --no-install-recommends install --yes $(cat /tmp/apt_packages_corehub.txt)
RUN npm install -g configurable-http-proxy
RUN apt-get autoremove --yes && apt-get clean all
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip2 install --upgrade pip && pip2 install -U pip setuptools && \
    pip3 install --upgrade pip && pip3 install -U pip setuptools

COPY jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser

ADD ./single_pip3_requirements_corehub.txt /tmp/requirements/single_pip3_requirements_corehub.txt 
ADD ./single_pip2_requirements_corehub.txt  /tmp/requirements/single_pip2_requirements_corehub.txt

RUN pip2 install -r /tmp/requirements/single_pip2_requirements_corehub.txt && \
    pip3 install -r /tmp/requirements/single_pip3_requirements_corehub.txt && \
    python2 -m bash_kernel.install && python3 -m bash_kernel.install && \
    jupyter serverextension enable --py jupyterlab --sys-prefix && \
    jupyter labextension install @jupyterlab/hub-extension@0.6.0 && \
    useradd -d /home/user -m -c "" user && mkdir /home/user/notebooks

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