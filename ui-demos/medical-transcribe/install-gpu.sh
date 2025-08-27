#!/bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt update
sudo DEBIAN_FRONTEND=noninteractive apt install wget -y

mkdir neo
cd neo
wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.16.0/intel-igc-core-2_2.16.0+19683_amd64.deb
wget https://github.com/intel/intel-graphics-compiler/releases/download/v2.16.0/intel-igc-opencl-2_2.16.0+19683_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/intel-ocloc-dbgsym_25.31.34666.3-0_amd64.ddeb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/intel-ocloc_25.31.34666.3-0_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/intel-opencl-icd-dbgsym_25.31.34666.3-0_amd64.ddeb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/intel-opencl-icd_25.31.34666.3-0_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/libigdgmm12_22.8.1_amd64.deb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/libze-intel-gpu1-dbgsym_25.31.34666.3-0_amd64.ddeb
wget https://github.com/intel/compute-runtime/releases/download/25.31.34666.3/libze-intel-gpu1_25.31.34666.3-0_amd64.deb
sudo dpkg -i *.deb
# sudo apt install ocl-icd-libopencl1
cd ..
rm -R neo
