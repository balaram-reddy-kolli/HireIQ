#!/bin/bash
set -e

echo "Starting HireIQ Backend..."

# If running as appuser, skip permission setup
if [ "$1" = "start.sh-as-appuser" ]; then
    shift
    echo "Running database migrations..."
    python manage.py migrate

    echo "Collecting static files..."
    python manage.py collectstatic --noinput --clear

    if [ "$USE_GUNICORN" = "true" ]; then
        echo "Starting Gunicorn application server..."
        # Bind on 0.0.0.0:8000 with 3 workers and async workers suitable for API
        exec gunicorn hireiq_backend.wsgi:application \
            --bind 0.0.0.0:8000 \
            --workers ${GUNICORN_WORKERS:-3} \
            --worker-class ${GUNICORN_WORKER_CLASS:-gthread} \
            --threads ${GUNICORN_THREADS:-4} \
            --timeout ${GUNICORN_TIMEOUT:-180} \
            --access-logfile '-' \
            --error-logfile '-'
    else
        echo "Starting Django development server..."
        python manage.py runserver 0.0.0.0:8000
    fi
    exit 0
fi

# Wait a moment for dependencies to be ready
sleep 5

# Create necessary directories if they don't exist and set proper permissions
mkdir -p /app/logs /app/media /app/static

# Ensure the appuser can write to mounted volumes
chown -R appuser:appuser /app/logs /app/media /app/static 2>/dev/null || true
chmod -R 755 /app/logs /app/media /app/static 2>/dev/null || true

# Switch to appuser for running the application
exec gosu appuser "$0" "start.sh-as-appuser" "$@"