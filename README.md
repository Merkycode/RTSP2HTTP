# RTSP to HTTP Stream Converter

An interactive bash script that helps you set up an RTSP camera stream and convert it to an HTTP stream accessible via web browser. This script automates the installation and configuration of all necessary components, making it easy to view your IP camera feed through any web browser.

## Features

- 🔧 Interactive setup wizard
- 🎥 RTSP to HTTP stream conversion
- 🛠️ Automatic installation of required packages
- ⚙️ Configurable video settings:
  - Frame rate
  - Resolution
  - Video quality

## Prerequisites

- A Linux-based operating system (tested on Ubuntu/Debian)
- Root/sudo privileges
- An RTSP camera stream URL
- Internet connection for package installation

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/Merkycode/RTSP2HTTP.git
   cd rtsp-to-http-stream
   ```

2. Make the script executable:
   ```bash
   chmod +x setup-rtsp-stream.sh
   ```

3. Run the script with sudo:
   ```bash
   sudo ./setup-rtsp-stream.sh
   ```

## Usage

1. Run the script and follow the interactive prompts:
   - Enter your RTSP URL (e.g., rtsp://username:password@ip:port/stream)
   - Set desired frame rate (default: 15)
   - Set desired resolution (default: 640x480)
   - Set video quality (1-31, lower is better, default: 1)

2. After installation, access your stream at:
   ```
   http://YOUR_SERVER_IP/cgi-bin/webcamstream
   ```

## Configuration

The script will automatically configure:
- Lighttpd web server
- CGI module
- FFmpeg conversion settings
- Stream parameters

All configurations can be modified later by editing:
- Stream settings: `/var/www/cgi-bin/webcamstream`
- Web server settings: `/etc/lighttpd/conf-enabled/10-cgi.conf`

## Troubleshooting

If you experience issues:

1. Check if lighttpd is running:
   ```bash
   systemctl status lighttpd
   ```

2. View error logs:
   ```bash
   tail -f /var/log/lighttpd/error.log
   ```

3. Verify RTSP URL accessibility:
   ```bash
   ffmpeg -i "YOUR_RTSP_URL" -t 1 -f null -
   ```

4. Ensure port 80 is open on your firewall:
   ```bash
   sudo ufw status
   ```

## Security Considerations

- The script by default uses unencrypted HTTP. For production use, consider setting up HTTPS.
- Be cautious with camera credentials in the RTSP URL.
- Consider implementing access control if needed.
- Regularly update your system and installed packages.

## Dependencies

The script will automatically install:
- lighttpd
- ffmpeg

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Acknowledgments

- Inspired by the need for simple RTSP to HTTP conversion
- Thanks to the FFmpeg and Lighttpd communities
- Special thanks to all contributors

## Additional Notes

- The script is tested on Ubuntu/Debian systems
- Performance depends on your server's capabilities
- Consider resource usage when setting resolution and frame rate
