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

echo Activating %CONDA_STREAMLIT_ENV_NAME% 
call conda create -n %CONDA_STREAMLIT_ENV_NAME% python=3.12 -y
call conda activate %CONDA_STREAMLIT_ENV_NAME%
call conda install pip -y

pip install -r requirements-streamlit.txt --resume-retries 3