#!/bin/bash

# HireIQ Production Deployment Script for EC2
# Make sure to run this script as root or with sudo privileges

set -euo pipefail

echo "🚀 Starting HireIQ deployment on EC2..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install required system packages
echo "📦 Installing required packages..."
sudo apt-get install -y curl wget git htop vim unzip

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
fi

# Install Docker Compose plugin (V2) if not already installed
if ! docker compose version >/dev/null 2>&1; then
        echo "🐳 Installing Docker Compose v2 plugin..."
        DOCKER_COMPOSE_VERSION="v2.29.7"
        sudo mkdir -p /usr/lib/docker/cli-plugins
        sudo curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/lib/docker/cli-plugins/docker-compose
        sudo chmod +x /usr/lib/docker/cli-plugins/docker-compose
fi

# Create application directory
APP_DIR="/opt/hireiq"
echo "📁 Setting up application directory: $APP_DIR"
sudo mkdir -p $APP_DIR
cd $APP_DIR

# Clone or copy project files (if not already present)
if [ ! -f docker-compose.yml ]; then
    echo "❗ Please ensure your project files are in $APP_DIR"
    echo "You can use git clone or scp to copy your project here"
    exit 1
fi

# Set up environment files
echo "⚙️  Setting up environment configuration..."

# Set up root .env for compose
if [ ! -f .env ]; then
    echo "Creating root .env (docker compose) ..."
        cat > .env << 'EOL'
# Compose-level env
ALLOWED_HOSTS=localhost,127.0.0.1
FRONTEND_API_URL=/api
EOL
    echo "✅ Created .env (edit ALLOWED_HOSTS, SERVER_NAME, FRONTEND_API_URL as needed)"
fi

# Set up backend environment file
echo "Setting up backend environment..."
if [ ! -f backend/.env ]; then
    if [ -f backend/.env.example ]; then
        cp backend/.env.example backend/.env
        echo "✅ Created backend/.env from backend/.env.example"
    else
        echo "Creating backend/.env file..."
        cat > backend/.env << 'EOL'
# Django Settings
DEBUG=False
SECRET_KEY=your-super-secret-key-here
ALLOWED_HOSTS=*

# Database
MONGO_USERNAME=admin
MONGO_PASSWORD=your-mongo-password
MONGO_DATABASE=hireiq_db

# Redis
REDIS_PASSWORD=your-redis-password

# API Keys
GROQ_API_KEY=your-groq-api-key
GEMINI_API_KEY=your-gemini-api-key

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Email Configuration
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-email-password
EOL
    fi
    echo "❗ Please edit the backend/.env file with your production values!"
    echo "Run: nano backend/.env"
else
    echo "✅ Backend .env file already exists"
fi

# Set up frontend environment file
echo "Setting up frontend environment..."
if [ ! -f frontend/.env ]; then
    echo "Creating frontend/.env file..."
    cat > frontend/.env << 'EOL'
# Frontend Configuration
REACT_APP_API_URL=http://your-ec2-public-ip:8000/api
REACT_APP_GOOGLE_CLIENT_ID=your-google-client-id
EOL
    echo "✅ Created frontend/.env"
    echo "❗ Please edit the frontend/.env file with your production values!"
    echo "Run: nano frontend/.env"
else
    echo "✅ Frontend .env file already exists"
fi

# Check if environment files need to be configured
if grep -q "your-" backend/.env || grep -q "your-" frontend/.env || grep -q "your-" .env; then
    echo ""
    echo "⚠️  WARNING: Environment files contain placeholder values!"
    echo "Please update the following files with your production values:"
    echo "  - backend/.env"
    echo "  - frontend/.env"
    echo "  - .env"
    echo ""
    echo "Press any key to continue after editing environment files..."
    read -n 1
fi

# Set proper permissions
sudo chown -R $USER:$USER $APP_DIR
chmod +x deploy.sh

# Start services
echo "🏃 Starting HireIQ services..."
docker compose down
docker compose build --no-cache
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo "✅ Checking service status..."
docker compose ps

# Show logs
echo "📊 Recent logs:"
docker compose logs --tail=50

echo "🎉 HireIQ deployment completed!"
echo ""
echo "📋 Service URLs:"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "<EC2_PUBLIC_IP>")
echo "  Frontend: http://$PUBLIC_IP"
echo "  API: http://$PUBLIC_IP/api"
echo "  Admin: http://$PUBLIC_IP/admin"
echo ""
echo "⚠️  Important reminders:"
echo "  1. Update your EC2 Security Group to allow ports 80, 443, 8000"
echo "  2. Configure your domain DNS to point to this EC2 instance"
echo "  3. Set up SSL certificates for HTTPS"
echo "  4. Configure backup strategy for MongoDB data"
echo ""
echo "📖 To view logs: docker compose logs -f"
echo "🔄 To restart: docker compose restart"
echo "🛑 To stop: docker compose down"
