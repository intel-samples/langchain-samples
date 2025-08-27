#!/bin/bash

source .env

sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y curl

if [ ! -d "$OPENVINO_DIR" ]; then
    curl -L https://storage.openvinotoolkit.org/repositories/openvino/packages/2024.6/linux/l_openvino_toolkit_ubuntu22_2024.6.0.17404.4c0f47d2335_x86_64.tgz --output openvino_2024.6.0.tgz
    tar -xf openvino_2024.6.0.tgz
    sudo mv l_openvino_toolkit_ubuntu22_2024.6.0.17404.4c0f47d2335_x86_64 $OPENVINO_DIR
else
    echo "OpenVINO already installed at $OPENVINO_DIR, skipping download and extraction."
fi