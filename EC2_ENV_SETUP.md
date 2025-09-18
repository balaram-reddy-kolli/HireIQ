# EC2 Deployment Environment Setup Guide

## Current Setup Issue

Your deployment has a **environment file mismatch**:

- ✅ **Root `.env`**: Used by `docker-compose.yml` ← **This is what we need**
- ❌ **Backend `.env`**: Created by `deploy.sh` but not used by Docker Compose
- ❌ **Frontend `.env`**: Created by `deploy.sh` but not used by Docker Compose

## ✅ **Solution: Use Root `.env` File**

The `docker-compose.yml` reads environment variables from the **root `.env` file**, not from individual backend/frontend `.env` files.

### **Step 1: Prepare Your Root `.env` File**

When running `deploy.sh` on EC2, make sure you have a `.env` file in the **root directory** (same level as `docker-compose.yml`):

```bash
# On your EC2 instance
cd /opt/hireiq

# Copy the .env file from your local setup or create it
nano .env
```

### **Step 2: Essential Environment Variables**

Make sure your root `.env` file contains these **minimum required** variables:

```bash
# Required for basic functionality
SECRET_KEY=your-actual-secret-key-here
MONGO_PASSWORD=your-secure-mongo-password  
REDIS_PASSWORD=your-secure-redis-password
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_EC2_PUBLIC_IP
```

### **Step 3: EC2-Specific Configuration**

Replace `172.31.40.233` with your **actual EC2 public IP**:

```bash
# Get your EC2 public IP
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Update these in .env
ALLOWED_HOSTS=localhost,127.0.0.1,YOUR_ACTUAL_PUBLIC_IP
FRONTEND_API_URL=http://YOUR_ACTUAL_PUBLIC_IP:8000/api
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://YOUR_ACTUAL_PUBLIC_IP:3000,http://YOUR_ACTUAL_PUBLIC_IP
```

## **Deployment Workflow**

```bash
# 1. Upload your project to EC2 (including root .env file)
scp -r your-project/ ubuntu@your-ec2-ip:/opt/hireiq/

# 2. SSH into EC2
ssh ubuntu@your-ec2-ip

# 3. Navigate to project directory
cd /opt/hireiq

# 4. Edit the root .env file with your actual values
nano .env

# 5. Run the deployment script
sudo bash deploy.sh
```

## **Why This Approach Works**

✅ **Docker Compose Integration**: `docker-compose.yml` automatically reads from root `.env`  
✅ **Simple Management**: One environment file to manage  
✅ **EC2 Compatible**: Works perfectly with your existing `deploy.sh`  
✅ **Production Ready**: Proper security and configuration  

## **Files Priority**

1. **Root `.env`** ← Used by Docker Compose ✅
2. **Backend `.env`** ← Ignored by Docker Compose (can delete)
3. **Frontend `.env`** ← Ignored by Docker Compose (can delete)

## **Quick Verification**

After deployment, verify environment variables are loaded:

```bash
# Check if containers see the environment variables
docker-compose exec backend printenv | grep SECRET_KEY
docker-compose exec backend printenv | grep MONGO_PASSWORD
```

The root `.env` file approach is the **standard Docker Compose pattern** and will work perfectly with your EC2 deployment!