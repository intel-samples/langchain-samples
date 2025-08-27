@echo off
setlocal

call conda >NUL 2>&1
if not %errorlevel% == 0  (
	echo "conda not found. Please run installer from a conda window."
	goto :eof
)

for /f "delims=" %%i in (.env) do (
    set "%%i"
)

set WHISPER_DIR=whisper.cpp
call conda activate %CONDA_ENV_NAME%

call %OPENVINO_DIR%/setupvars.bat
REM "%WHISPER_DIR%\build\bin\Release\whisper-server.exe" -m %WHISPER_DIR%/models/ggml-base.en.bin -oved %WHISPER_DEVICE% --port 5910 
start "Whisper-Server" "whisper.cpp\build\bin\Release\whisper-server.exe" -m %WHISPER_DIR%/models/ggml-base.en.bin -oved %WHISPER_DEVICE% --port 5910 
