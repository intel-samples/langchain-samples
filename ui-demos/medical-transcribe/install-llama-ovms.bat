@echo off
setlocal


call conda >NUL 2>&1
if not %errorlevel% == 0  (
	echo "conda not found. Please run installer from a conda window."
	goto :eof
)

curl --help >NUL 2>&1
if not %errorlevel% == 0  (
	echo "curl is not installed. Please install curl."
	goto :eof
)

for /f "delims=" %%i in (.env) do (
    set "%%i"
)

if "%HUGGINGFACE_TOKEN%" == "" (
    echo Please set the HUGGINGFACE_TOKEN variable in the .env file
    goto :eof
)

call conda create -n %CONDA_OVMS_ENV_NAME% python=3.12 -y
call conda activate %CONDA_OVMS_ENV_NAME%
call conda env list
call conda install pip -y

echo Install OVMS Export requirements
curl --output requirements-ovms.txt -L https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/tags/v2025.2.1/demos/common/export_models/requirements.txt
pip install -r requirements-ovms.txt --resume-retries 3

curl --output ovms_windows.zip -L https://github.com/openvinotoolkit/model_server/releases/download/v2025.2.1/ovms_windows_python_on.zip
tar -xf ovms_windows.zip

echo Creating OpenVINO optimized model files 	
curl --output export_model.py -L https://raw.githubusercontent.com/openvinotoolkit/model_server/refs/tags/v2025.2.1/demos/common/export_models/export_model.py 
if not exist "models" (
    mkdir models
) else (
    echo Skipping: "models" folder exists
)

call huggingface-cli login --token %HUGGINGFACE_TOKEN%
if not %errorlevel% == 0  (
	echo "huggingface-cli login failed. Make sure your token has been set in the .env file."
	goto :eof
)

echo Creating OpenVINO optimized model files for %LLAMA_MODEL% on device: %OVMS_DEVICE%
if "%OVMS_DEVICE%" == "CPU" (
    python export_model.py text_generation --source_model %LLAMA_MODEL% --config_file_path models\config.json --model_repository_path models --target_device %OVMS_DEVICE% --weight-format fp16 --kv_cache_precision u8 --pipeline_type LM --overwrite_models
    goto :eof
) 
if "%OVMS_DEVICE%" == "GPU" (
    python export_model.py text_generation --source_model %LLAMA_MODEL% --weight-format int4 --config_file_path models\config.json --model_repository_path models --target_device %OVMS_DEVICE% --cache 2 --pipeline_type LM --overwrite_models
    goto :eof
)
    
if "%OVMS_DEVICE%" == "NPU" (
    python export_model.py text_generation --source_model %LLAMA_MODEL% --weight-format int4 --config_file_path models\config.json --model_repository_path models --target_device %OVMS_DEVICE% --max_prompt_len 1500 --pipeline_type LM --overwrite_models
    goto :eof
) 

echo "Invalid OVMS_DEVICE value. Please set it to GPU, CPU or NPU in .env file."