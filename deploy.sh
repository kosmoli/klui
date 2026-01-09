#!/bin/bash
# One-click build and deploy script for klui
# Author: Kosmo
# Last Updated: 2026-01-09

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/root/work/klui"
BUILD_DIR="$PROJECT_DIR/build/web"
HTTP_PORT="8080"
API_BASE_URL="${API_BASE_URL:-http://38.175.200.93:8283}"

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Klui Build & Deploy Script${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Step 1: Build
echo -e "${YELLOW}[1/3] Building Flutter app...${NC}"
cd "$PROJECT_DIR"
export PATH="$PATH:/opt/flutter/bin"

flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful!${NC}"
    ls -lah "$BUILD_DIR/main.dart.js" | head -1
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi

echo ""

# Step 2: Stop existing server
echo -e "${YELLOW}[2/3] Stopping existing HTTP server...${NC}"
pkill -f "python3.*$HTTP_PORT" 2>/dev/null || echo "No existing server found"
sleep 1

# Step 3: Start server
echo -e "${YELLOW}[3/3] Starting HTTP server...${NC}"
cd "$BUILD_DIR"
python3 -m http.server $HTTP_PORT > /dev/null 2>&1 &

sleep 2

# Verify server is running
if ps aux | grep -q "python3.*$HTTP_PORT"; then
    echo -e "${GREEN}✓ Server started successfully!${NC}"
    PID=$(ps aux | grep "python3.*$HTTP_PORT" | grep -v grep | awk '{print $2}')
    echo "  PID: $PID"
    echo "  Port: $HTTP_PORT"
    echo "  Directory: $BUILD_DIR"
else
    echo -e "${RED}✗ Failed to start server!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Deploy complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "Access the app at:"
echo "  Local:  http://localhost:$HTTP_PORT"
echo "  Remote: http://38.175.200.93:$HTTP_PORT"
echo ""
echo -e "${YELLOW}Remember: Hard refresh browser (Ctrl+Shift+R)${NC}"
echo ""
