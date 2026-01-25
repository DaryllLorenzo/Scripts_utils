#!/bin/bash

# Script to completely remove snapd and migrate to flatpak
# Compatible with Ubuntu, Xubuntu, Lubuntu, Kubuntu

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Use: sudo $0"
    exit 1
fi

# Variables
LOG_FILE="/tmp/remove-snap-$(date +%Y%m%d-%H%M%S).log"
DEBIAN_FRONTEND=noninteractive

# Functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

confirm() {
    read -p "$1 (y/n): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Start script
echo "================================================"
echo "  SNAP REMOVAL AND MIGRATION TO FLATPAK"
echo "================================================"
log "Starting snap removal process..."

# Step 1: List installed snaps
log "Listing installed snaps..."
snap list 2>/dev/null || log "No snaps found"

if ! confirm "Do you want to continue with snap removal?"; then
    log "Operation cancelled by the user"
    exit 0
fi

# Step 2: Remove each snap individually
log "Removing installed snaps..."
for snap in $(snap list 2>/dev/null | awk 'NR>1 {print $1}'); do
    log "Removing snap: $snap"
    snap remove --purge "$snap" 2>/dev/null
done

# Step 3: Uninstall snapd
log "Uninstalling snapd..."
apt-get remove --purge -y snapd 2>/dev/null || error_exit "Failed to uninstall snapd"

# Step 4: Block snapd
log "Blocking snapd from reinstalling..."
apt-mark hold snapd 2>/dev/null || log "Warning: Could not block snapd"

# Step 5: Find and remove residual snap directories
log "Searching for residual snap directories..."
for dir in $(find / -type d -name "snap" 2>/dev/null | grep -E "(/home/|/root/)"); do
    log "Removing directory: $dir"
    rm -rf "$dir" 2>/dev/null
done

# Step 6: Clean up unused dependencies
log "Cleaning up unused dependencies..."
apt-get autoremove -y 2>/dev/null
apt-get clean 2>/dev/null

# Step 7: Install flatpak if not present
if ! command -v flatpak &> /dev/null; then
    log "Installing flatpak..."
    
    # Update repositories first
    apt-get update 2>/dev/null
    
    # Install flatpak
    apt-get install -y flatpak 2>/dev/null || error_exit "Failed to install flatpak"
    
    # Install plugin for software manager based on the Ubuntu variant
    if [ -x "$(command -v gnome-software)" ]; then
        apt-get install -y gnome-software-plugin-flatpak 2>/dev/null
    elif [ -x "$(command -v plasma-discover)" ]; then
        apt-get install -y plasma-discover-backend-flatpak 2>/dev/null
    fi
fi

# Step 8: Configure Flathub repository
log "Configuring Flathub repository..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null

# Step 9: Ask about alternative browser
if ! dpkg -l | grep -q "firefox\|chromium" && ! command -v firefox &> /dev/null; then
    if confirm "No Firefox/Chromium installation detected. Would you like to install a web browser?"; then
        echo "Available options:"
        echo "1) Firefox (flatpak)"
        echo "2) Chromium (flatpak)"
        echo "3) Firefox (deb)"
        echo "4) Chromium (deb)"
        read -p "Select option (1-4): " browser_choice
        
        case $browser_choice in
            1)
                flatpak install -y flathub org.mozilla.firefox 2>/dev/null
                ;;
            2)
                flatpak install -y flathub org.chromium.Chromium 2>/dev/null
                ;;
            3)
                apt-get install -y firefox 2>/dev/null
                ;;
            4)
                apt-get install -y chromium-browser 2>/dev/null
                ;;
        esac
    fi
fi

# Step 10: Ask about other common installations
if confirm "Would you like to install some common applications from flatpak?"; then
    echo "Available applications:"
    echo "1) VLC (media player)"
    echo "2) GIMP (image editor)"
    echo "3) LibreOffice (office suite)"
    echo "4) All of the above"
    echo "5) None"
    
    read -p "Select option (1-5): " apps_choice
    
    case $apps_choice in
        1)
            flatpak install -y flathub org.videolan.VLC 2>/dev/null
            ;;
        2)
            flatpak install -y flathub org.gimp.GIMP 2>/dev/null
            ;;
        3)
            flatpak install -y flathub org.libreoffice.LibreOffice 2>/dev/null
            ;;
        4)
            flatpak install -y flathub org.videolan.VLC 2>/dev/null
            flatpak install -y flathub org.gimp.GIMP 2>/dev/null
            flatpak install -y flathub org.libreoffice.LibreOffice 2>/dev/null
            ;;
    esac
fi

# Final summary
echo ""
echo "================================================"
echo "  PROCESS COMPLETED"
echo "================================================"
log "Snap has been completely removed"
log "Flatpak has been configured"

# Show current status
echo ""
echo "Summary:"
echo "--------"
flatpak remotes 2>/dev/null || echo "Flatpak is not configured"

echo ""
echo "Log saved at: $LOG_FILE"
echo ""
echo "To install applications with flatpak:"
echo "  flatpak install flathub application.name"
echo "  flatpak search name"
echo ""
echo "To list installed applications:"
echo "  flatpak list"
echo ""
echo "Reboot your system to apply all changes."

exit 0
