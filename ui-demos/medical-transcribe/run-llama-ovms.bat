@echo off
setlocal

call conda >NUL 2>&1
if not %errorlevel% == 0  (
	echo "conda not found. Please run from a conda window."
	goto :eof
)

for /f "delims=" %%i in (.env) do (
    set "%%i"
)

call conda activate %CONDA_OVMS_ENV_NAME%

REM Read OVMS endpoint and port from .env
if "%OVMS_ENDPOINT%" == "" (
    echo "OVMS_ENDPOINT is not set."
    goto :eof
)

for /F "tokens=1-3 delims=:" %%a in ("%OVMS_ENDPOINT%") do (
    set OVMS_PORT=%%c
)
if not %errorlevel% == 0  (
	echo "OVMS_ENDPOINT is not set correctly."
	goto :eof
)
for /F "tokens=1-3 delims=/" %%a in ("%OVMS_PORT%") do (
    set OVMS_PORT=%%a
)
if not %errorlevel% == 0  (
	echo "OVMS_ENDPOINT is not set correctly."
	goto :eof
)

for /F "tokens=1-3 delims=/" %%a in ("%OVMS_ENDPOINT%") do (
    set OVMS_URL=%%a//%%b
)

echo Starting OVMS on port %OVMS_PORT%
cd ovms
call setupvars.bat
ovms.exe --rest_port %OVMS_PORT% --config_path ..\models\config.json
REM Use flag if needed: --log_level DEBUG
