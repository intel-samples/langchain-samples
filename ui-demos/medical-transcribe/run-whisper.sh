#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WHISPER_DIR="$SCRIPT_DIR/whisper.cpp"
#OPENVINO_DIR="/opt/intel/openvino_2024"

source .env
source activate-conda.sh
activate_conda
conda activate $CONDA_ENV_NAME

source $OPENVINO_DIR/setupvars.sh
$WHISPER_DIR/build/bin/whisper-server -m $WHISPER_DIR/models/ggml-base.en.bin -oved $WHISPER_DEVICE --port 5910 
