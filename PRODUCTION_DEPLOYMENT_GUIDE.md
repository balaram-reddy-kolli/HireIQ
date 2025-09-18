# 🚀 Complete EC2 Deployment Guide with Environment Setup

## 📁 Environment Files Structure

Your HireIQ project now has **three `.env` files** that work together:

```
/opt/hireiq/
├── .env                    # ← Main file used by docker-compose.yml ✅
├── backend/.env           # ← For compatibility with deploy.sh
├── frontend/.env          # ← For compatibility with deploy.sh
└── docker-compose.yml     # ← Reads from root .env
```

## 🎯 How It Works

### **Root `.env` (Main Configuration)**
- **Used by**: `docker-compose.yml` 
- **Contains**: All backend AND frontend environment variables
- **Purpose**: Single source of truth for Docker deployment

### **Backend `.env` & Frontend `.env`**
- **Used by**: `deploy.sh` script (for validation/compatibility)
- **Contains**: Duplicated values from root `.env`
- **Purpose**: Ensure deploy.sh doesn't fail when checking for environment files

## 🔧 EC2 Deployment Steps

### **Step 1: Upload Project to EC2**

```bash
# From your local machine
scp -r /path/to/HireIQ ubuntu@43.205.116.56:/opt/hireiq
```

### **Step 2: SSH into EC2**

```bash
ssh ubuntu@43.205.116.56
cd /opt/hireiq
```

### **Step 3: Verify Environment Files**

```bash
# Check that all environment files exist
ls -la .env backend/.env frontend/.env

# Verify the root .env has your production values
head -20 .env
```

### **Step 4: Run Deployment**

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
sudo bash deploy.sh
```

## ✅ Key Environment Variables Set

### **🔐 Security & Authentication**
- ✅ SECRET_KEY: Production Django secret
- ✅ Google OAuth: Complete client ID and secret
- ✅ HTTPS: SSL redirect and security headers enabled

### **🗄️ Database & Cache**
- ✅ MongoDB Atlas: Connected to your cluster
- ✅ Redis: Secure password set
- ✅ Local MongoDB: Fallback configuration

### **🤖 AI Features**
- ✅ GROQ API: For AI interview evaluation
- ✅ Gemini API: For AI features
- ✅ Perplexity API: Additional AI capabilities

### **📧 Email System**
- ✅ Gmail SMTP: Configured with app password
- ✅ Email user: 22501a4428@pvpsit.ac.in

### **🌐 Domain & CORS**
- ✅ Domain: hireiq.ddns.net
- ✅ IP: 43.205.116.56
- ✅ HTTPS: Enabled for production
- ✅ CORS: Properly configured for your domain

## 🔍 Verification Commands

After deployment, verify everything is working:

```bash
# Check container status
docker-compose ps

# Check backend logs
docker logs hireiq-backend

# Check if environment variables are loaded
docker-compose exec backend printenv | grep SECRET_KEY
docker-compose exec backend printenv | grep MONGODB_URL

# Test health endpoint
curl -k https://hireiq.ddns.net:8000/api/health/

# Test frontend
curl -k https://hireiq.ddns.net/
```

## 🛠️ Troubleshooting

### **If containers fail to start:**
```bash
# Check detailed logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild if needed
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### **If environment variables aren't working:**
```bash
# Verify root .env file exists and has correct values
cat .env | grep SECRET_KEY
cat .env | grep MONGODB_URL

# Restart containers to reload environment
docker-compose restart
```

### **If HTTPS/SSL issues:**
```bash
# Check if ports 80, 443, 8000 are open in EC2 Security Group
# Verify your No-IP domain (hireiq.ddns.net) points to 43.205.116.56
```

## 🎉 Expected Results

Once deployed successfully, you should have:

- ✅ **Frontend**: Available at `https://hireiq.ddns.net`
- ✅ **Backend API**: Available at `https://hireiq.ddns.net:8000/api`
- ✅ **Admin Panel**: Available at `https://hireiq.ddns.net:8000/admin`
- ✅ **Google OAuth**: Working login system
- ✅ **AI Features**: Functional interview evaluation
- ✅ **Email**: Notification system working
- ✅ **File Uploads**: Resume uploads working
- ✅ **Database**: Connected to MongoDB Atlas

## 📝 Notes

1. **SSL Certificates**: You may need to set up proper SSL certificates for production HTTPS
2. **Security Groups**: Ensure EC2 security group allows ports 80, 443, 8000
3. **Domain DNS**: Verify hireiq.ddns.net points to your EC2 IP (43.205.116.56)
4. **MongoDB Atlas**: Ensure your IP is whitelisted in MongoDB Atlas network access
5. **Backup Strategy**: Consider setting up automated backups for your MongoDB data

Your production environment is now fully configured with all necessary API keys, security settings, and domain configuration! 🚀