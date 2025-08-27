#!/bin/bash
set -euo pipefail

source .env

source activate-conda.sh
activate_conda
echo "Creating conda environment $CONDA_ENV_NAME."
conda create -n $CONDA_ENV_NAME python=3.11 -y
echo 'y' | conda install pip
conda activate $CONDA_ENV_NAME

dpkg -s sudo &> /dev/null
if [ $? != 0 ]
then
	DEBIAN_FRONTEND=noninteractive apt update
	DEBIAN_FRONTEND=noninteractive apt install sudo -y
fi

# Install venv and cmake
sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y git build-essential cmake

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
WHISPER_DIR="$SCRIPT_DIR/whisper.cpp"

if [ ! -d "$WHISPER_DIR" ]; then
    echo "Cloning whisper.cpp..."
    git clone https://github.com/ggml-org/whisper.cpp.git "$WHISPER_DIR" --depth 1
else
    echo "whisper.cpp already exists, skipping clone."
fi

pip install -r requirements.txt
cd $SCRIPT_DIR/whisper.cpp/models
./download-ggml-model.sh base.en
python convert-whisper-to-openvino.py --model base.en

# Compile whisper.cpp binaries
cd ..
pwd

# Below python version is managed by intall-conda.sh
bash -c "source `pwd`/../openvino_2024/setupvars.sh; \
cmake -B build -DWHISPER_OPENVINO=1; \
cmake --build build -j --config Release; "
