#!/bin/bash

activate_conda(){
	CONDA_DIR=$HOME/miniforge3
	eval "$(${CONDA_DIR}/bin/conda shell.bash hook 2> /dev/null)"
}
