#!/bin/bash

source .env

sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install wget -y

CUR_DIR=`pwd`
cd /tmp
miniforge_script=Miniforge3-$(uname)-$(uname -m).sh
[ -e $miniforge_script ] && rm $miniforge_script
wget "https://github.com/conda-forge/miniforge/releases/latest/download/$miniforge_script"
bash $miniforge_script -b -u
activate_conda
conda init
cd $CUR_DIR

