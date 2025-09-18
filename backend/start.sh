#!/bin/bash
set -e

echo "Starting HireIQ Backend..."

# Wait a moment for dependencies to be ready
sleep 5

# Create necessary directories
mkdir -p /app/logs /app/media /app/static
chmod 777 /app/logs /app/media /app/static

echo "Running database migrations..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput --clear

echo "Starting Django development server..."
python manage.py runserver 0.0.0.0:8000