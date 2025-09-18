# SSL Certificate Setup Guide for HireIQ on EC2

## Overview
This guide helps you set up SSL certificates for hireiq.ddns.net on your EC2 instance to enable HTTPS and Google OAuth functionality.

## Prerequisites
- EC2 instance with Docker and Docker Compose installed
- Domain name `hireiq.ddns.net` pointing to your EC2 instance
- Ports 80 and 443 open in your EC2 security group

## Step 1: Install Certbot and Obtain SSL Certificate

### Option A: Using Certbot directly on EC2
```bash
# Install Certbot
sudo apt update
sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot

# Create a symlink
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Stop any running containers that might use ports 80/443
sudo docker-compose down

# Obtain SSL certificate
sudo certbot certonly --standalone -d hireiq.ddns.net

# Certificates will be saved to:
# /etc/letsencrypt/live/hireiq.ddns.net/fullchain.pem
# /etc/letsencrypt/live/hireiq.ddns.net/privkey.pem
```

### Option B: Using Docker Certbot (Alternative)
```bash
# Create directory for certificates
mkdir -p ./ssl
mkdir -p ./letsencrypt

# Stop running containers
docker-compose down

# Run certbot in Docker
docker run -it --rm --name certbot \
  -v "${PWD}/letsencrypt:/etc/letsencrypt" \
  -v "${PWD}/ssl:/etc/ssl" \
  -p 80:80 \
  certbot/certbot certonly --standalone \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email \
  -d hireiq.ddns.net

# Copy certificates to ssl directory
sudo cp /etc/letsencrypt/live/hireiq.ddns.net/fullchain.pem ./ssl/
sudo cp /etc/letsencrypt/live/hireiq.ddns.net/privkey.pem ./ssl/
```

## Step 2: Prepare SSL Directory
```bash
# Create SSL directory in your HireIQ project
mkdir -p ./ssl

# Copy the certificates (adjust paths as needed)
sudo cp /etc/letsencrypt/live/hireiq.ddns.net/fullchain.pem ./ssl/
sudo cp /etc/letsencrypt/live/hireiq.ddns.net/privkey.pem ./ssl/

# Set proper permissions
sudo chmod 644 ./ssl/fullchain.pem
sudo chmod 600 ./ssl/privkey.pem
sudo chown $USER:$USER ./ssl/*
```

## Step 3: Configure Google OAuth
Update your Google Cloud Console OAuth settings:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services > Credentials
3. Edit your OAuth 2.0 Client ID
4. Add authorized redirect URIs:
   - `https://hireiq.ddns.net/api/auth/google/callback/`
   - `https://hireiq.ddns.net/auth/complete/google-oauth2/`
5. Add authorized JavaScript origins:
   - `https://hireiq.ddns.net`

## Step 4: Deploy with Docker Compose
```bash
# Make sure you're in the HireIQ directory
cd /path/to/HireIQ

# Build and start services
docker-compose up --build -d

# Check container status
docker-compose ps

# Check logs if needed
docker-compose logs nginx
docker-compose logs backend
```

## Step 5: Test SSL Configuration
```bash
# Test SSL certificate
openssl s_client -connect hireiq.ddns.net:443 -servername hireiq.ddns.net

# Test HTTP to HTTPS redirect
curl -I http://hireiq.ddns.net

# Test HTTPS access
curl -I https://hireiq.ddns.net
```

## Step 6: Set Up Certificate Auto-Renewal

### Create renewal script
```bash
# Create renewal script
sudo tee /usr/local/bin/renew-hireiq-ssl.sh > /dev/null << 'EOF'
#!/bin/bash

# Stop nginx container
cd /path/to/HireIQ
docker-compose stop nginx

# Renew certificate
certbot renew --quiet

# Copy renewed certificates
cp /etc/letsencrypt/live/hireiq.ddns.net/fullchain.pem ./ssl/
cp /etc/letsencrypt/live/hireiq.ddns.net/privkey.pem ./ssl/
chmod 644 ./ssl/fullchain.pem
chmod 600 ./ssl/privkey.pem
chown $USER:$USER ./ssl/*

# Restart nginx container
docker-compose start nginx
EOF

# Make script executable
sudo chmod +x /usr/local/bin/renew-hireiq-ssl.sh

# Add to crontab for automatic renewal (runs twice daily)
echo "0 0,12 * * * /usr/local/bin/renew-hireiq-ssl.sh" | sudo crontab -
```

## Troubleshooting

### Common Issues:

1. **Port 443 not accessible**
   - Check EC2 security group allows inbound traffic on port 443
   - Verify no firewall blocking the port

2. **Certificate not found**
   - Ensure certificate files are in `./ssl/` directory
   - Check file permissions (644 for fullchain.pem, 600 for privkey.pem)

3. **Google OAuth not working**
   - Verify redirect URIs are correct in Google Cloud Console
   - Check that HTTPS is working before testing OAuth

4. **Mixed content errors**
   - Ensure all API calls use relative URLs (`/api/...`) or HTTPS URLs
   - Check browser console for mixed content warnings

### Check container logs:
```bash
docker-compose logs -f nginx
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Verify configuration:
```bash
# Check nginx configuration
docker-compose exec nginx nginx -t

# Check backend health
curl https://hireiq.ddns.net/api/health/

# Check frontend
curl https://hireiq.ddns.net/
```

## Security Notes
- Always keep certificates secure and never commit them to version control
- Regularly update your system and Docker images
- Monitor certificate expiration dates
- Use strong passwords for all services
- Regularly review and update security groups

## Files Modified for SSL Support
- `.env` - Updated for HTTPS configuration
- `backend/hireiq_backend/settings_production.py` - Added SSL and proxy settings
- `nginx/conf.d/default.conf` - Already configured for SSL
- `docker-compose.yml` - Updated environment variables

The configuration is now ready for SSL deployment on your EC2 instance.