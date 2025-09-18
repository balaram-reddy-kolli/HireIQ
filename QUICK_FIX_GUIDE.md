# Docker Deployment Fix - Permission-Based Solution

## Issue Fixed
The backend container was failing due to:
1. **Logging Permission Error**: Django was trying to write to `/app/logs/django.log` but lacked permissions
2. **Missing Environment Variables**: Required environment variables were not set

## What Was Fixed

### 1. File Permissions Solution
Instead of disabling file logging, we've implemented a comprehensive permission fix:

**Dockerfile Changes:**
- Added `chmod 777` for `/app/logs`, `/app/media`, and `/app/static` directories
- Ensured proper ownership with `chown -R appuser:appuser /app`

**Docker-Compose Changes:**
- Added runtime command to ensure directories exist with proper permissions
- Added `:rw` (read-write) flags to volume mounts
- Runtime permission setup: `chmod 777 /app/logs /app/media /app/static`

**Production Settings:**
- Restored both file and console logging
- Added automatic logs directory creation with proper permissions
- Full logging to both `/app/logs/django.log` and console

### 2. Environment Variables Setup
- Created `.env` file with all required variables
- Set secure defaults for MongoDB and Redis passwords
- Added your EC2 instance IP to allowed hosts

## Benefits of This Approach

✅ **Full Logging**: Both console and file logging for better debugging  
✅ **Production Ready**: Proper file permissions for production deployments  
✅ **Volume Persistence**: Logs persist across container restarts  
✅ **Security**: Uses non-root user with proper permissions  

## Next Steps

1. **Update the .env file** with your actual values:
   ```bash
   # Edit the .env file
   nano .env
   ```

2. **Rebuild and restart the containers**:
   ```bash
   # Stop current containers
   docker-compose down

   # Rebuild backend with the permission fixes
   docker-compose build backend

   # Start all services
   docker-compose up -d
   ```

3. **Check the status**:
   ```bash
   # Check if containers are running
   docker-compose ps

   # Check backend logs (both console and file)
   docker logs hireiq-backend
   
   # Check the log file directly
   cat backend/logs/django.log

   # Test the health endpoint
   curl http://localhost:8000/api/health/
   ```

## File Locations

- **Console Logs**: `docker logs hireiq-backend`
- **File Logs**: `backend/logs/django.log` (persisted on host)
- **Media Files**: `backend/media/` (persisted on host)
- **Static Files**: `backend/static/` (persisted on host)

## Important Environment Variables

### Required for Basic Functionality:
- `SECRET_KEY`: Django secret key (MUST be changed)
- `MONGO_PASSWORD`: MongoDB password
- `REDIS_PASSWORD`: Redis password

### Optional (but recommended):
- `GROQ_API_KEY`: For AI interview evaluation
- `GEMINI_API_KEY`: For AI features
- `GOOGLE_OAUTH2_KEY/SECRET`: For Google login
- `EMAIL_HOST_USER/PASSWORD`: For email notifications

The application should work without the optional variables, but some features may be limited.