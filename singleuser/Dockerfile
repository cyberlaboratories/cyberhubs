FROM continuumio/miniconda3

MAINTAINER Nic Annau

# Set the ENTRYPOINT to use bash
# (this is also where you’d set SHELL,
# if your version of docker supports this)
ENTRYPOINT [ “/bin/bash”, “-c” ]

EXPOSE 8888

# Conda supports delegating to pip to install dependencies
# that aren’t available in anaconda or need to be compiled
# for other reasons. In our case, we need psycopg compiled
# with SSL support. These commands install prereqs necessary
# to build psycopg.

RUN apt-get update
RUN apt-get autoremove --yes && apt-get clean all
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && apt-get install -y \
  libpq-dev \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

# Use the environment.yml to create the conda environment.

ADD environment.yml /tmp/environment.yml

WORKDIR /tmp

#RUN [ “conda”, “env”, “create” ]

#ADD . /code

# Use bash to source our new environment for setting up
# private dependencies—note that /bin/bash is called in
# exec mode directly
#WORKDIR /code/shared

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

COPY jupyterhub-singleuser /usr/local/bin/jupyterhub-singleuser

RUN chmod -R 775 /home/user/ && \
    chmod 775 /usr/local/bin/jupyterhub-singleuser && \
    chmod 775 /srv/singleuser/singleuser.sh

USER user:user
ENTRYPOINT ["fixuid"]

ENV HOME /home/user
WORKDIR /home/user

#RUN [ “/bin/bash”, “-c”, “source activate ml-environment && python setup.py develop” ]

#WORKDIR /code
#RUN [ “/bin/bash”, “-c”, “source activate ml-environment && python setup.py develop” ]

# We set ENTRYPOINT, so while we still use exec mode, we don’t
# explicitly call /bin/bash
CMD [ “source activate ml-environment” ]