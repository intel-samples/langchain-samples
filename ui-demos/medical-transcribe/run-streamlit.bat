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

call conda activate %CONDA_STREAMLIT_ENV_NAME%

streamlit run streamlit-ovms.py --server.port=8080
