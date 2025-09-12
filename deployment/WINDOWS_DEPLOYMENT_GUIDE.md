# HireIQ EC2 Deployment Guide - Windows Edition

## Prerequisites Setup

Before deploying to EC2, you need to set up several external services:

### 1. MongoDB Atlas (Database)
1. Go to https://www.mongodb.com/cloud/atlas
2. Create a free account and cluster
3. Create a database user with read/write permissions
4. Whitelist your EC2 IP address (or use 0.0.0.0/0 for all IPs)
5. Get the connection string (looks like: `mongodb+srv://username:password@cluster.mongodb.net/hireiq_production`)

### 2. Google OAuth (Authentication)
1. Go to https://console.cloud.google.com/
2. Create a new project or select existing
3. Enable Google+ API
4. Go to Credentials → Create OAuth 2.0 Client ID
5. Add authorized domains: your-domain.com (or your EC2 IP)
6. Add redirect URIs: 
   - `https://your-domain.com/complete/google-oauth2/`
   - `https://your-domain.com/api/auth/google/`
7. Save the Client ID and Client Secret

### 3. Gmail App Password (Email)
1. Enable 2-factor authentication on your Gmail
2. Go to Google Account → Security → 2-Step Verification → App passwords
3. Generate an app password for "Mail"
4. Use this 16-character password (not your regular Gmail password)

### 4. Groq API Key (AI Features)
1. Go to https://groq.com/
2. Sign up for a free account
3. Get your API key from the dashboard

## Environment Configuration

### Step 1: Create Backend Environment File

Create a file named `.env` in your project root with this content:

```bash
# HireIQ Backend Production Environment Configuration

# Django Configuration (generate a new secret key)
SECRET_KEY=your-super-secret-django-key-here-generate-a-new-one
DEBUG=False
DJANGO_SETTINGS_MODULE=hireiq_backend.settings_production

# Domain and Host Configuration (replace with your actual domain/IP)
DOMAIN_NAME=your-domain.com
EC2_PUBLIC_IP=your-ec2-public-ip
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,your-ec2-public-ip,localhost,127.0.0.1

# Database Configuration - MongoDB Atlas
MONGODB_NAME=hireiq_production
MONGODB_URL=mongodb+srv://username:password@cluster.mongodb.net/hireiq_production?retryWrites=true&w=majority

# Security Settings (set to True when using SSL/domain)
SECURE_SSL_REDIRECT=False
SESSION_COOKIE_SECURE=False
CSRF_COOKIE_SECURE=False

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Email Configuration (Gmail SMTP)
EMAIL_BACKEND=smtp
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-specific-password
DEFAULT_FROM_EMAIL=your-email@gmail.com

# AI/ML API Keys
GROQ_API_KEY=your-groq-api-key-here
PERPLEXITY_API_KEY=

# Logging
LOG_LEVEL=INFO

# File Upload Settings
MAX_UPLOAD_SIZE=10485760

# Session Configuration
SESSION_COOKIE_AGE=86400
```

### Step 2: Create Frontend Environment File

Create a file named `.env` in your `frontend/` folder:

```bash
# HireIQ Frontend Production Environment Configuration

# API Configuration (use your domain or EC2 IP)
REACT_APP_API_URL=https://your-domain.com/api
# For IP-only deployment:
# REACT_APP_API_URL=http://your-ec2-public-ip/api

# Google OAuth Configuration (same as backend)
REACT_APP_GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com

# Environment
NODE_ENV=production

# Build Configuration
GENERATE_SOURCEMAP=false
INLINE_RUNTIME_CHUNK=false
```

## EC2 Deployment Steps

### Step 1: Launch EC2 Instance
1. **Instance:** Ubuntu 22.04 LTS
2. **Type:** t3.medium or larger
3. **Storage:** 20-30 GB
4. **Security Group:**
   - SSH (22): Your IP
   - HTTP (80): 0.0.0.0/0
   - HTTPS (443): 0.0.0.0/0

### Step 2: Upload Project to Server

Using PowerShell or Command Prompt:

```powershell
# Upload your entire project to EC2
scp -r -i "your-keypair.pem" . ubuntu@YOUR_EC2_IP:/opt/hireiq/
```

### Step 3: Connect and Deploy

```bash
# Connect to your EC2 instance
ssh -i "your-keypair.pem" ubuntu@YOUR_EC2_IP

# Navigate to project directory
cd /opt/hireiq

# Make deployment script executable
chmod +x deployment/deploy.sh

# Run automated deployment
./deployment/deploy.sh
```

### Step 4: Set Up SSL (If Using Domain)

```bash
# Set up SSL certificate with Let's Encrypt
sudo /opt/hireiq/deployment/setup_ssl.sh your-domain.com
```

## Post-Deployment

### Check Service Status
```bash
sudo systemctl status hireiq nginx
```

### View Logs
```bash
sudo journalctl -u hireiq -f
sudo tail -f /var/log/hireiq/gunicorn_error.log
```

### Restart Services
```bash
sudo systemctl restart hireiq
sudo systemctl restart nginx
```

### Test Application
- Visit: `http://your-ec2-ip` or `https://your-domain.com`
- Check health: `http://your-ec2-ip/api/health/`

## Troubleshooting

### Common Issues:

1. **Environment file not found:** Make sure `.env` files are in correct locations
2. **MongoDB connection failed:** Check connection string and IP whitelist
3. **Google OAuth not working:** Verify client ID and authorized domains
4. **Static files not loading:** Run `python manage.py collectstatic`

### Useful Commands:
```bash
# Check running processes
ps aux | grep gunicorn

# Check disk space
df -h

# Check memory
free -h

# Test nginx config
sudo nginx -t
```

## Security Recommendations

1. **Restrict SSH access** to your IP only
2. **Use strong passwords** for all services
3. **Enable UFW firewall:**
   ```bash
   sudo ufw enable
   sudo ufw allow ssh
   sudo ufw allow 'Nginx Full'
   ```
4. **Regular updates:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

Your HireIQ application should now be running on EC2! 🚀