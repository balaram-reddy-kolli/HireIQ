#!/bin/bash

# HireIQ Redeploy Script - Use this after configuration changes

echo "🔄 Redeploying HireIQ with updated configuration..."

# Stop all containers
echo "⏹️ Stopping containers..."
docker-compose down

# Remove old images to force rebuild
echo "🗑️ Removing old images..."
docker-compose build --no-cache

# Start services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for health checks
echo "⏳ Waiting for services to be healthy..."
sleep 30

# Check status
echo "📊 Service Status:"
docker-compose ps

echo "✅ Redeploy complete!"
echo "🌐 Frontend: https://hireiq.ddns.net"
echo "📡 API: https://hireiq.ddns.net/api"

# Show logs
echo "📋 Recent logs:"
docker-compose logs --tail=20