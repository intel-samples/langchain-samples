@echo off
setlocal

for /f "delims=" %%i in (.env) do (
    set "%%i"
)

IF EXIST "%OPENVINO_DIR%" (
    echo "OpenVINO already installed at $OPENVINO_DIR, skipping download and extraction."
) else (
    curl --output openvino_2024.6.0.tgz -L https://storage.openvinotoolkit.org/repositories/openvino/packages/2024.6/windows/w_openvino_toolkit_windows_2024.6.0.17404.4c0f47d2335_x86_64.zip
    tar -xf openvino_2024.6.0.tgz
    rename w_openvino_toolkit_windows_2024.6.0.17404.4c0f47d2335_x86_64 %OPENVINO_DIR%
)