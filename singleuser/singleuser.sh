#!/bin/bash
#set -e
#set -x
#echo "Arguments are: $@"

notebook_arg=""
if [ -n "${NOTEBOOK_DIR:+x}" ]
then
    notebook_arg="--notebook-dir=${NOTEBOOK_DIR}"
fi

# jupyterlab and jupyter notebook
cmd=jupyterhub-singleuser
args=${@:1:${#}-1}
if [ "x${@:$#}" == "xlabhub" ]
then
  cmd=jupyter-labhub
fi
chmod 600 -R $HOME/.secret/*
exec env SHELL=/bin/bash $cmd \
    --port=8888 \
    --ip=0.0.0.0 \
    --user=$JUPYTERHUB_USER \
    --base-url=$JUPYTERHUB_SERVICE_PREFIX \
    --hub-prefix=${JUPYTERHUB_BASE_URL}hub \
    --hub-api-url=$JUPYTERHUB_API_URL \
    --config=/etc/ipython/ipython_config.py \
    ${notebook_arg}  \
    ${args}
