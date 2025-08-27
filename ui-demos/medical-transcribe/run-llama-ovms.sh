#!/bin/bash

source .env


source activate-conda.sh
activate_conda
conda activate $CONDA_OVMS_ENV_NAME

hash -r
# Read OVMS endpoint and port from .env
if [ -z "$OVMS_ENDPOINT" ]; then
    echo "OVMS_ENDPOINT is not set."
    exit 1
fi

OVMS_PORT=$(echo "$OVMS_ENDPOINT" | sed -n 's/.*:\([0-9]\+\).*/\1/p')

if [ -z "$OVMS_PORT" ]; then
    echo "Could not determine OVMS_PORT from OVMS_ENDPOINT ($OVMS_ENDPOINT)."
    exit 1
fi

OVMS_URL=$(echo "$OVMS_ENDPOINT" | sed -E 's#(https?://[^:/]+:[0-9]+).*#\1#')

# Check if OVMS is already running
if lsof -i:$OVMS_PORT | grep -q LISTEN; then
    # Kill if already running
    echo "Terminating existing OVMS process on port $OVMS_PORT."
    PID=$(lsof -t -i:$OVMS_PORT)
    if [ -n "$PID" ]; then
        kill -9 $PID
        echo "Ended OVMS process with PID: $PID"
    fi
fi

echo "Starting OVMS on port $OVMS_PORT."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PWD}/ovms/lib
export PATH=$PATH:${PWD}/ovms/bin
CONDA_PYTHON_PATH="$(python -c 'import site; print(site.getsitepackages()[0])')"
# conda python path is **explicitly** needed for OVMS to find the installed Python packages in conda, it is not visible otherwise 
# without this, OVMS doesnt find jinja2 and other packages installed in conda environment, if Jinja2 isn't found - we will get the following warning:
# --Warning: Chat templates not loaded-- while starting OVMS. This causes failures for LLAMA inference requests
export PYTHONPATH=$PYTHONPATH:${PWD}/ovms/lib/python:$CONDA_PYTHON_PATH

ovms --rest_port $OVMS_PORT --config_path ./models/config.json &
OVMS_PID=$!
echo "Started OVMS with PID: $OVMS_PID"

# Wait for OVMS to be ready
echo "Waiting for OVMS to become available..."
for i in {1..4}; do
    STATUS=$(curl -s $OVMS_URL/v1/config)
    if echo "$STATUS" | grep -q '"state": "AVAILABLE"'; then
        echo "OVMS is ready."
        break
    else
        sleep 8
    fi
    if [ $i -eq 4 ]; then
        echo "OVMS did not become ready in time. Please check the logs for errors."
        kill $OVMS_PID
        exit 1
    fi
done
