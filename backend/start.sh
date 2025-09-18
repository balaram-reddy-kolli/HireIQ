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