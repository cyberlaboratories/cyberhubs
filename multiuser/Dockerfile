FROM ubuntu:16.04

MAINTAINER Falk Herwig

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get --no-install-recommends install --yes \
    python3 python3-pip git net-tools strace \
    npm nodejs-legacy && \
    npm install -g configurable-http-proxy && \
    apt-get autoremove --yes && apt-get clean all && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./multi_pip3_requirements.txt /multi_pip3_requirements.txt
RUN pip3 install -U pip setuptools && \
    pip3 install -r multi_pip3_requirements.txt  && \
    rm -Rf jupyterhub.sqlite

EXPOSE 8000
