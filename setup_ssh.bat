@echo off
:: Prompt for necessary information
set /p USERNAME=Enter your username on the remote server:
set /p SERVER=Enter the server hostname (e.g., ia-class.cs.georgetown.edu):
set /p KEY_NAME=Enter a name for your SSH key (e.g., id_ed25519_ia-class):
set /p HOST_ALIAS=Enter a short name for the SSH host (e.g., ia-class):

:: Navigate to the .ssh directory
cd %USERPROFILE%
if not exist .ssh (
    mkdir .ssh
    echo Created .ssh directory.
)
cd .ssh

:: Generate the SSH key
ssh-keygen -t ed25519 -f "%USERPROFILE%\.ssh\%KEY_NAME%" -N ""

:: Check if ssh-keygen succeeded
if errorlevel 1 (
    echo ssh-keygen failed. Make sure OpenSSH is installed.
    pause
    exit /b 1
)

:: Copy the public key to the server
echo Copying public key to the server...
scp "%USERPROFILE%\.ssh\%KEY_NAME%.pub" %USERNAME%@%SERVER%:

if errorlevel 1 (
    echo scp failed. Make sure OpenSSH is installed and the server is reachable.
    pause
    exit /b 1
)

:: Log into the server to set up authorized_keys
echo Setting up authorized_keys on the server...
ssh %USERNAME%@%SERVER% ^
 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat %KEY_NAME%.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && rm %KEY_NAME%.pub"

:: Create or update the SSH config file
set SSH_CONFIG=%USERPROFILE%\.ssh\config

if not exist "%SSH_CONFIG%" (
    type nul > "%SSH_CONFIG%"
)

:: Check if the host alias already exists in the config
findstr /B /C:"Host %HOST_ALIAS%" "%SSH_CONFIG%" >nul
if %ERRORLEVEL%==0 (
    echo Host alias %HOST_ALIAS% already exists in your SSH config.
) else (
    echo Adding %HOST_ALIAS% to your SSH config...
    echo.>> "%SSH_CONFIG%"
    echo Host %HOST_ALIAS%>> "%SSH_CONFIG%"
    echo     HostName %SERVER%>> "%SSH_CONFIG%"
    echo     User %USERNAME%>> "%SSH_CONFIG%"
    echo     IdentityFile %%USERPROFILE%%\.ssh\%KEY_NAME%>> "%SSH_CONFIG%"
)

echo Setup complete! You can now SSH into the server using: ssh %HOST_ALIAS%
pause