@echo off
setlocal

for /f "delims=" %%i in (.env) do (
    set "%%i"
)

call conda >NUL 2>&1
if not %errorlevel% == 0  (
	echo "conda not found. Please run installer from a conda window."
	goto :eof
)

cmake >NUL 2>&1
if not %errorlevel% == 0  (
	echo "CMAKE is not installed. Please install CMAKE from https://cmake.org/download/."
	goto :eof
)

git --help >NUL 2>&1
if not %errorlevel% == 0  (
	echo "git is not installed. Please install GIT."
	goto :eof
)

echo "Creating conda environment %CONDA_ENV_NAME%."
call conda create -n %CONDA_ENV_NAME% python=3.11 -y
echo 'y' | conda install pip
echo Activating %CONDA_ENV_NAME% 
call conda activate %CONDA_ENV_NAME%

set WHISPER_DIR="whisper.cpp"

rmdir /S /Q 
echo Cloning whisper.cpp...
git clone https://github.com/ggml-org/whisper.cpp.git "%WHISPER_DIR%" --depth 1


pip install -r requirements.txt --resume-retries 3
cd whisper.cpp/models
call download-ggml-model.cmd base.en
python convert-whisper-to-openvino.py --model base.en

echo Compile whisper.cpp binaries
cd ..
REM Below python version is managed by intall-conda.sh
call ../%OPENVINO_DIR%/setupvars.bat
cmake -B build -DWHISPER_OPENVINO=1
cmake --build build -j --config Release
