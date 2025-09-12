@echo off
REM HireIQ Deployment Upload Script for Windows
REM This script creates a clean deployment package excluding unnecessary files

echo ==========================================
echo    HireIQ Deployment Package Creator
echo ==========================================
echo.

REM Check if we're in the right directory
if not exist "backend\manage.py" (
    echo Error: Please run this script from the HireIQ project root directory
    echo Looking for backend\manage.py...
    pause
    exit /b 1
)

REM Get EC2 details from user
set /p EC2_IP="Enter your EC2 IP address: "
set /p KEY_FILE="Enter path to your .pem key file: "

REM Create deployment directory
echo Creating deployment package...
if exist deploy_package rmdir /s /q deploy_package
mkdir deploy_package

REM Copy essential backend files
echo Copying backend files...
mkdir deploy_package\backend
xcopy backend deploy_package\backend /E /I /Q /EXCLUDE:deployment\exclude_list.txt

REM Copy essential frontend files (source only, not node_modules or build)
echo Copying frontend source files...
mkdir deploy_package\frontend
xcopy frontend\src deploy_package\frontend\src /E /I /Q
xcopy frontend\public deploy_package\frontend\public /E /I /Q
copy frontend\package.json deploy_package\frontend\ >nul
copy frontend\tsconfig.json deploy_package\frontend\ >nul
if exist frontend\tailwind.config.js copy frontend\tailwind.config.js deploy_package\frontend\ >nul
if exist frontend\postcss.config.js copy frontend\postcss.config.js deploy_package\frontend\ >nul
if exist frontend\nginx.conf copy frontend\nginx.conf deploy_package\frontend\ >nul

REM Copy deployment scripts
echo Copying deployment scripts...
xcopy deployment deploy_package\deployment /E /I /Q

REM Copy Docker and config files
echo Copying configuration files...
if exist docker-compose.yml copy docker-compose.yml deploy_package\ >nul
if exist docker-compose.prod.yml copy docker-compose.prod.yml deploy_package\ >nul
if exist README.md copy README.md deploy_package\ >nul

REM Create environment file reminders
echo Creating environment file templates...
copy deployment\.env.backend.template deploy_package\.env.template >nul
copy deployment\.env.frontend.template deploy_package\frontend\.env.template >nul

echo.
echo Package created successfully in 'deploy_package' folder
echo.
echo Contents:
dir deploy_package /B
echo.

REM Ask if user wants to upload now
set /p UPLOAD="Do you want to upload to EC2 now? (y/n): "
if /i "%UPLOAD%"=="y" (
    echo.
    echo Uploading to EC2...
    echo Command: scp -r -i "%KEY_FILE%" deploy_package/* ubuntu@%EC2_IP%:/opt/hireiq/
    echo.
    echo Please run this command manually in PowerShell or use your preferred SCP client:
    echo scp -r -i "%KEY_FILE%" deploy_package/* ubuntu@%EC2_IP%:/opt/hireiq/
    echo.
    echo Then SSH to your server and run:
    echo ssh -i "%KEY_FILE%" ubuntu@%EC2_IP%
    echo cd /opt/hireiq
    echo chmod +x deployment/deploy.sh
    echo ./deployment/deploy.sh
) else (
    echo.
    echo Package ready for upload. To upload manually:
    echo scp -r -i "your-key.pem" deploy_package/* ubuntu@%EC2_IP%:/opt/hireiq/
)

echo.
echo IMPORTANT: Don't forget to create .env files on the server before deployment!
echo Use the templates: .env.template and frontend/.env.template
echo.
pause