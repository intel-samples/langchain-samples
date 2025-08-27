#!/bin/bash
set -euo pipefail

source .env

source activate-conda.sh
activate_conda
conda create -n $CONDA_STREAMLIT_ENV_NAME python=3.12 -y
conda activate $CONDA_STREAMLIT_ENV_NAME
conda install pip -y
pip install -r requirements-streamlit.txt --resume-retries 3
