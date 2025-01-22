#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "${RED}[!] $1${NC}"
}

# Function to print prompts
print_prompt() {
    echo -e "${BLUE}[?] $1${NC}"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root"
    exit 1
fi

# Welcome message
clear
echo "================================================"
echo "   RTSP to HTTP Stream Setup Wizard"
echo "================================================"
echo

# Collect RTSP URL
while true; do
    print_prompt "Enter your RTSP URL (e.g., rtsp://username:password@ip:port/stream):"
    read RTSP_URL
    if [ -n "$RTSP_URL" ]; then
        break
    else
        print_error "RTSP URL cannot be empty. Please try again."
    fi
done

# Collect video settings
print_prompt "Enter desired framerate (press Enter for default: 15):"
read FRAMERATE
FRAMERATE=${FRAMERATE:-15}

print_prompt "Enter desired resolution (press Enter for default: 640x480):"
read RESOLUTION
RESOLUTION=${RESOLUTION:-"640x480"}

print_prompt "Enter video quality (1-31, lower is better, press Enter for default: 1):"
read QUALITY
QUALITY=${QUALITY:-1}

# Confirm settings
echo
echo "================================================"
echo "Please confirm your settings:"
echo "================================================"
echo "RTSP URL: $RTSP_URL"
echo "Framerate: $FRAMERATE fps"
echo "Resolution: $RESOLUTION"
echo "Quality: $QUALITY"
echo "================================================"
print_prompt "Are these settings correct? (y/n):"
read CONFIRM

if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    print_error "Setup cancelled. Please run the script again."
    exit 1
fi

# Begin installation
print_status "Beginning installation..."

# Update package list
print_status "Updating package list..."
apt-get update

# Install required packages
print_status "Installing required packages..."
apt-get install -y lighttpd ffmpeg

# Create CGI directory if it doesn't exist
print_status "Setting up CGI directory..."
mkdir -p /var/www/cgi-bin

# Create the streaming script
print_status "Creating streaming script..."
cat > /var/www/cgi-bin/webcamstream << EOF
#!/bin/bash

echo "Content-Type: multipart/x-mixed-replace;boundary=ffmpeg"
echo "Cache-Control: no-cache"
echo ""
ffmpeg -i "${RTSP_URL}" \\
    -c:v mjpeg \\
    -q:v ${QUALITY} \\
    -r ${FRAMERATE} \\
    -s ${RESOLUTION} \\
    -f mpjpeg \\
    -an -
EOF

# Make the streaming script executable
chmod +x /var/www/cgi-bin/webcamstream

# Enable CGI module
print_status "Enabling CGI module..."
ln -sf /etc/lighttpd/conf-available/10-cgi.conf /etc/lighttpd/conf-enabled/10-cgi.conf

# Configure lighttpd CGI settings
print_status "Configuring lighttpd..."
cat > /etc/lighttpd/conf-enabled/10-cgi.conf << 'EOF'
server.modules += ( "mod_cgi" )

$HTTP["url"] =~ "^/cgi-bin/" {
        server.stream-response-body = 2
        cgi.assign = ( "" => "" )
        alias.url += ( "/cgi-bin/" => "/var/www/cgi-bin/" )
}
EOF

# Restart lighttpd
print_status "Restarting lighttpd..."
systemctl restart lighttpd

# Get server IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Final status message
echo
echo "================================================"
print_status "Installation completed successfully!"
echo "================================================"
echo
print_status "You can access your stream at: http://${SERVER_IP}/cgi-bin/webcamstream"
print_status "To test if it's working, try: curl -I http://${SERVER_IP}/cgi-bin/webcamstream"

# Add some helpful tips
cat << EOF

Additional Information:
----------------------
1. If you need to modify the stream settings, edit /var/www/cgi-bin/webcamstream
2. To restart the service: sudo systemctl restart lighttpd
3. To check service status: sudo systemctl status lighttpd
4. Logs can be found at: /var/log/lighttpd/error.log

If you experience issues:
------------------------
1. Check if lighttpd is running: systemctl status lighttpd
2. Check error logs: tail -f /var/log/lighttpd/error.log
3. Ensure your firewall allows connections to port 80
4. Verify the RTSP URL is accessible: ffmpeg -i "${RTSP_URL}" -t 1 -f null -

Your Configuration:
------------------
RTSP URL: ${RTSP_URL}
Framerate: ${FRAMERATE} fps
Resolution: ${RESOLUTION}
Quality: ${QUALITY}

EOF
