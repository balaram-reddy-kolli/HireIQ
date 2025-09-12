# HireIQ File Upload Guide for EC2 Deployment

## ❌ What NOT to Upload

**These files/folders should NEVER be uploaded to EC2:**

### Backend Files to Exclude:
- `__pycache__/` - Python cache files
- `venv/` or `.venv/` - Virtual environment (will be created on server)
- `*.pyc` - Compiled Python files
- `db.sqlite3` - Local development database
- `/media` - Local uploaded files
- `/static` - Static files (collected on server)
- `*.log` - Log files

### Frontend Files to Exclude:
- `node_modules/` - Dependencies (installed on server)
- `/build` or `/dist` - Built files (created on server)
- `npm-debug.log*` - Debug logs
- `.cache` - Build cache

### General Files to Exclude:
- `.env` - Local environment (create new on server)
- `.vscode/` - IDE settings
- `*.pem` - SSH keys
- `*.log` - Log files
- `.DS_Store` - macOS system files

## ✅ What TO Upload

**Only these files should be uploaded:**

### Essential Source Code:
```
├── backend/
│   ├── manage.py
│   ├── requirements.txt
│   ├── hireiq_backend/
│   ├── authentication/
│   ├── candidates/
│   └── (all .py source files)
├── frontend/
│   ├── package.json
│   ├── src/
│   ├── public/
│   ├── tsconfig.json
│   ├── tailwind.config.js
│   └── postcss.config.js
├── deployment/
│   └── (all deployment scripts)
├── docker-compose.yml
├── docker-compose.prod.yml
└── README.md
```

## 🚀 Recommended Upload Methods

### Method 1: Using Git (Best Practice)
```bash
# On your local machine, commit and push to GitHub
git add .
git commit -m "Prepare for deployment"
git push origin main

# On EC2 server, clone the repository
git clone https://github.com/balaram-reddy-kolli/HireIQ.git /opt/hireiq
```

### Method 2: Selective SCP Upload
```powershell
# Create a temporary deployment folder
mkdir deploy_temp
copy backend deploy_temp\backend /E /EXCLUDE:deployment\exclude_list.txt
copy frontend\src deploy_temp\frontend\src /E
copy frontend\public deploy_temp\frontend\public /E
copy frontend\package.json deploy_temp\frontend\
copy frontend\tsconfig.json deploy_temp\frontend\
copy frontend\tailwind.config.js deploy_temp\frontend\
copy frontend\postcss.config.js deploy_temp\frontend\
copy deployment deploy_temp\deployment /E
copy *.yml deploy_temp\
copy README.md deploy_temp\

# Upload only the deployment folder
scp -r -i "keypair.pem" deploy_temp/* ubuntu@EC2_IP:/opt/hireiq/
```

### Method 3: Using rsync (Linux/WSL)
```bash
# Exclude unnecessary files automatically
rsync -avz --exclude-from='.gitignore' \
  --exclude='node_modules' \
  --exclude='venv' \
  --exclude='.env' \
  --exclude='__pycache__' \
  --exclude='*.log' \
  -e "ssh -i keypair.pem" \
  . ubuntu@EC2_IP:/opt/hireiq/
```

## 📋 Pre-Upload Checklist

Let me create an exclude list and upload script for you: