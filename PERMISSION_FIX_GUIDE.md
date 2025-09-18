# HireIQ Backend Permission Fix Guide

## Problem
The HireIQ backend container was experiencing permission issues with `/app/logs` and `/app/static` directories, causing continuous restart loops with the error:
```
chmod: changing permissions of '/app/logs': Operation not permitted
chmod: changing permissions of '/app/static': Operation not permitted
```

## Root Cause
The issue occurred because:
1. The container was running as a non-root user (`appuser`)
2. The start script was trying to run `chmod` commands that require elevated permissions
3. Volume mounts from the host had different ownership than expected

## Solution Applied
I've made the following changes to fix the permission issues:

### 1. Updated Dockerfile (`backend/Dockerfile`)
- Added `gosu` package for safe user switching
- Removed the automatic switch to `appuser` to allow initial setup as root
- Simplified directory creation and permission setup

### 2. Updated Start Script (`backend/start.sh`)
- Modified to handle permissions as root initially
- Use `gosu` to safely switch to `appuser` after setting up permissions
- Added error handling with `2>/dev/null || true` to prevent crashes

## Steps to Apply the Fix

### On Your EC2 Instance:

1. **Navigate to the project directory:**
   ```bash
   cd /opt/hireiq
   ```

2. **Stop the current containers:**
   ```bash
   docker-compose down
   ```

3. **Remove the problematic backend container and image:**
   ```bash
   docker rm hireiq-backend 2>/dev/null || true
   docker rmi hireiq-backend 2>/dev/null || true
   ```

4. **Clear any orphaned volumes (optional - only if you don't mind losing logs):**
   ```bash
   # Only run this if you want to start with fresh logs
   sudo rm -rf ./backend/logs/* 2>/dev/null || true
   ```

5. **Rebuild and start the containers:**
   ```bash
   docker-compose build --no-cache backend
   docker-compose up -d
   ```

6. **Monitor the backend logs to verify the fix:**
   ```bash
   docker logs -f hireiq-backend
   ```

You should now see the backend starting properly without permission errors.

### Expected Output After Fix:
```
Starting HireIQ Backend...
Running database migrations...
Operations to perform:
  Apply all migrations: ...
Collecting static files...
Starting Gunicorn application server...
```

## Verification Steps

1. **Check container status:**
   ```bash
   docker ps
   ```
   The `hireiq-backend` container should show as "Up" and healthy.

2. **Check application health:**
   ```bash
   curl -f http://localhost/api/health/
   ```

3. **Monitor logs for any issues:**
   ```bash
   docker-compose logs backend
   ```

## If Issues Persist

If you still encounter permission issues:

1. **Check volume ownership on host:**
   ```bash
   ls -la ./backend/logs ./backend/static ./backend/media
   ```

2. **Fix host permissions if needed:**
   ```bash
   sudo chown -R $USER:$USER ./backend/logs ./backend/static ./backend/media
   sudo chmod -R 755 ./backend/logs ./backend/static ./backend/media
   ```

3. **Restart containers:**
   ```bash
   docker-compose restart backend
   ```

## Backup Note
The original files have been modified. If you need to revert:
- The changes are focused on permission handling and user switching
- The core application logic remains unchanged
- You can review the git diff to see exact changes made