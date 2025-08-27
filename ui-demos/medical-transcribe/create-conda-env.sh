#!/bin/bash

source .env
source activate-conda.sh
activate_conda
echo "Creating conda environment $CONDA_ENV_NAME."
conda create -n $CONDA_ENV_NAME python=3.11 -y
echo 'y' | conda install pip
