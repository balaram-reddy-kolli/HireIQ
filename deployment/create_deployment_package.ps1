# HireIQ Deployment Upload Script for PowerShell
# This script creates a clean deployment package excluding unnecessary files

Write-Host "==========================================" -ForegroundColor Blue
Write-Host "   HireIQ Deployment Package Creator" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "backend\manage.py")) {
    Write-Host "Error: Please run this script from the HireIQ project root directory" -ForegroundColor Red
    Write-Host "Looking for backend\manage.py..." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Get deployment details
$EC2_IP = Read-Host "Enter your EC2 IP address"
$KEY_FILE = Read-Host "Enter path to your .pem key file"

# Create deployment directory
Write-Host "Creating deployment package..." -ForegroundColor Green
if (Test-Path "deploy_package") {
    Remove-Item "deploy_package" -Recurse -Force
}
New-Item -ItemType Directory -Name "deploy_package" | Out-Null

# Copy essential backend files (excluding unnecessary ones)
Write-Host "Copying backend files..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "deploy_package\backend" | Out-Null

# Copy backend files selectively
$backendItems = @(
    "manage.py", "requirements.txt", "Dockerfile", 
    "hireiq_backend", "authentication", "candidates"
)

foreach ($item in $backendItems) {
    if (Test-Path "backend\$item") {
        if (Test-Path "backend\$item" -PathType Container) {
            Copy-Item "backend\$item" -Destination "deploy_package\backend\" -Recurse -Force
        } else {
            Copy-Item "backend\$item" -Destination "deploy_package\backend\" -Force
        }
    }
}

# Copy frontend source files only
Write-Host "Copying frontend source files..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "deploy_package\frontend" | Out-Null

$frontendItems = @("src", "public")
foreach ($item in $frontendItems) {
    if (Test-Path "frontend\$item") {
        Copy-Item "frontend\$item" -Destination "deploy_package\frontend\" -Recurse -Force
    }
}

# Copy essential frontend config files
$frontendFiles = @(
    "package.json", "tsconfig.json", "tailwind.config.js", 
    "postcss.config.js", "nginx.conf", "Dockerfile"
)

foreach ($file in $frontendFiles) {
    if (Test-Path "frontend\$file") {
        Copy-Item "frontend\$file" -Destination "deploy_package\frontend\" -Force
    }
}

# Copy deployment scripts
Write-Host "Copying deployment scripts..." -ForegroundColor Yellow
Copy-Item "deployment" -Destination "deploy_package\" -Recurse -Force

# Copy Docker and config files
Write-Host "Copying configuration files..." -ForegroundColor Yellow
$configFiles = @("docker-compose.yml", "docker-compose.prod.yml", "README.md")
foreach ($file in $configFiles) {
    if (Test-Path $file) {
        Copy-Item $file -Destination "deploy_package\" -Force
    }
}

# Create environment file templates
Write-Host "Creating environment file templates..." -ForegroundColor Yellow
Copy-Item "deployment\.env.backend.template" -Destination "deploy_package\.env.template" -Force
Copy-Item "deployment\.env.frontend.template" -Destination "deploy_package\frontend\.env.template" -Force

Write-Host ""
Write-Host "Package created successfully in 'deploy_package' folder" -ForegroundColor Green
Write-Host ""

# Show package size
$packageSize = (Get-ChildItem "deploy_package" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Package size: $([math]::Round($packageSize, 2)) MB" -ForegroundColor Cyan

Write-Host ""
Write-Host "Contents:" -ForegroundColor Cyan
Get-ChildItem "deploy_package" | Format-Table Name, Length, LastWriteTime

Write-Host ""
$upload = Read-Host "Do you want to see the upload commands? (y/n)"

if ($upload -eq "y" -or $upload -eq "Y") {
    Write-Host ""
    Write-Host "=== UPLOAD COMMANDS ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Upload files to EC2:" -ForegroundColor Yellow
    Write-Host "   scp -r -i `"$KEY_FILE`" deploy_package/* ubuntu@$EC2_IP`:/opt/hireiq/" -ForegroundColor White
    Write-Host ""
    Write-Host "2. SSH to server:" -ForegroundColor Yellow
    Write-Host "   ssh -i `"$KEY_FILE`" ubuntu@$EC2_IP" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Create environment files on server:" -ForegroundColor Yellow
    Write-Host "   cp /opt/hireiq/.env.template /opt/hireiq/.env" -ForegroundColor White
    Write-Host "   cp /opt/hireiq/frontend/.env.template /opt/hireiq/frontend/.env" -ForegroundColor White
    Write-Host "   # Edit these files with your actual values" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Run deployment:" -ForegroundColor Yellow
    Write-Host "   cd /opt/hireiq" -ForegroundColor White
    Write-Host "   chmod +x deployment/deploy.sh" -ForegroundColor White
    Write-Host "   ./deployment/deploy.sh" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "IMPORTANT REMINDERS:" -ForegroundColor Red
Write-Host "• Create .env files on server using the templates" -ForegroundColor Yellow
Write-Host "• Set up MongoDB Atlas, Google OAuth, Gmail, and Groq API" -ForegroundColor Yellow
Write-Host "• Ensure EC2 security group allows HTTP/HTTPS traffic" -ForegroundColor Yellow
Write-Host ""

Write-Host "Deployment package ready! 🚀" -ForegroundColor Green
Read-Host "Press Enter to exit"