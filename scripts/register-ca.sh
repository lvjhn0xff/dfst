#!/bin/bash

# CA Certificate Browser Installer - Extended Edition
# Detects top 50+ browsers and installs a CA certificate
# Usage: ./install_ca.sh /path/to/ca-certificate.crt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Validate CA file
if [ -z "$CA_FILE_PATH" ]; then
    log_error "CA_FILE_PATH not provided"
    echo "Usage: $0 /path/to/ca-certificate.crt"
    exit 1
fi

if [ ! -f "$CA_FILE_PATH" ]; then
    log_error "CA file not found: $CA_FILE_PATH"
    exit 1
fi

log_info "Using CA certificate: $CA_FILE_PATH"

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

log_info "Detected OS: $OS"

# Arrays to track browsers
declare -A browsers_found
declare -A nss_browsers
declare -A firefox_based
declare -a installed_browsers

# Define browser detection patterns for each OS
# Format: "Browser Name|command/path|type"

LINUX_BROWSERS=(
    # Chromium-based browsers
    "Google Chrome|google-chrome|nss"
    "Google Chrome|google-chrome-stable|nss"
    "Chromium|chromium|nss"
    "Chromium|chromium-browser|nss"
    "Microsoft Edge|microsoft-edge|nss"
    "Microsoft Edge|microsoft-edge-stable|nss"
    "Brave|brave-browser|nss"
    "Brave|brave|nss"
    "Opera|opera|nss"
    "Vivaldi|vivaldi|nss"
    "Yandex Browser|yandex-browser|nss"
    "Slimjet|slimjet|nss"
    "Iridium|iridium|nss"
    "Ungoogled Chromium|ungoogled-chromium|nss"
    "Epic Privacy Browser|epic|nss"
    "SRWare Iron|iron|nss"
    "Dissenter|dissenter-browser|nss"
    "Thorium|thorium-browser|nss"
    "Cent Browser|centbrowser|nss"
    "Comodo Dragon|dragon|nss"
    "Torch Browser|torch|nss"
    "Maxthon|maxthon|nss"
    "Avast Secure Browser|avast-secure-browser|nss"
    "AVG Secure Browser|avg-secure-browser|nss"
    "Colibri|colibri|nss"
    "Min Browser|min|nss"
    "Falkon|falkon|nss"
    "qutebrowser|qutebrowser|nss"
    "Nyxt|nyxt|nss"
    "Konqueror|konqueror|nss"
    
    # Firefox-based browsers
    "Firefox|firefox|firefox"
    "Firefox ESR|firefox-esr|firefox"
    "Waterfox|waterfox|firefox"
    "LibreWolf|librewolf|firefox"
    "Pale Moon|palemoon|firefox"
    "Basilisk|basilisk|firefox"
    "IceCat|icecat|firefox"
    "GNU IceCat|gnuzilla|firefox"
    "Floorp|floorp|firefox"
    "Zen Browser|zen-browser|firefox"
    "Mullvad Browser|mullvad-browser|firefox"
    "Tor Browser|tor-browser|firefox"
    "Seamonkey|seamonkey|firefox"
    "K-Meleon|k-meleon|firefox"
    
    # WebKit/Other browsers
    "Midori|midori|nss"
    "GNOME Web (Epiphany)|epiphany|system"
    "Dillo|dillo|none"
    "NetSurf|netsurf|none"
    "Lynx|lynx|none"
    "w3m|w3m|none"
    "Links|links|none"
    "ELinks|elinks|none"
)

MACOS_APPS=(
    "Safari|/Applications/Safari.app|system"
    "Google Chrome|/Applications/Google Chrome.app|system"
    "Firefox|/Applications/Firefox.app|system"
    "Microsoft Edge|/Applications/Microsoft Edge.app|system"
    "Brave Browser|/Applications/Brave Browser.app|system"
    "Opera|/Applications/Opera.app|system"
    "Vivaldi|/Applications/Vivaldi.app|system"
    "Arc|/Applications/Arc.app|system"
    "Orion|/Applications/Orion.app|system"
    "DuckDuckGo|/Applications/DuckDuckGo.app|system"
    "Tor Browser|/Applications/Tor Browser.app|system"
    "Waterfox|/Applications/Waterfox.app|system"
    "LibreWolf|/Applications/LibreWolf.app|system"
    "Min|/Applications/Min.app|system"
    "SigmaOS|/Applications/SigmaOS.app|system"
    "Sizzy|/Applications/Sizzy.app|system"
    "Responsively|/Applications/ResponsivelyApp.app|system"
    "Polypane|/Applications/Polypane.app|system"
    "Chrome Canary|/Applications/Google Chrome Canary.app|system"
    "Firefox Developer Edition|/Applications/Firefox Developer Edition.app|system"
    "Firefox Nightly|/Applications/Firefox Nightly.app|system"
    "Chromium|/Applications/Chromium.app|system"
    "Yandex Browser|/Applications/Yandex.app|system"
    "Avast Secure Browser|/Applications/Avast Secure Browser.app|system"
    "AVG Secure Browser|/Applications/AVG Secure Browser.app|system"
    "Epic Privacy Browser|/Applications/Epic.app|system"
    "Maxthon|/Applications/Maxthon.app|system"
    "Pale Moon|/Applications/Pale Moon.app|system"
    "Basilisk|/Applications/Basilisk.app|system"
    "Seamonkey|/Applications/SeaMonkey.app|system"
    "Iridium|/Applications/Iridium.app|system"
)

WINDOWS_PATHS=(
    "Google Chrome|C:/Program Files/Google/Chrome/Application/chrome.exe|system"
    "Google Chrome|C:/Program Files (x86)/Google/Chrome/Application/chrome.exe|system"
    "Firefox|C:/Program Files/Mozilla Firefox/firefox.exe|system"
    "Firefox|C:/Program Files (x86)/Mozilla Firefox/firefox.exe|system"
    "Microsoft Edge|C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe|system"
    "Brave|C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe|system"
    "Opera|C:/Program Files/Opera/opera.exe|system"
    "Vivaldi|C:/Program Files/Vivaldi/Application/vivaldi.exe|system"
    "Yandex Browser|C:/Program Files/Yandex/YandexBrowser/browser.exe|system"
    "Waterfox|C:/Program Files/Waterfox/waterfox.exe|system"
    "LibreWolf|C:/Program Files/LibreWolf/librewolf.exe|system"
    "Pale Moon|C:/Program Files/Pale Moon/palemoon.exe|system"
    "Basilisk|C:/Program Files/Basilisk/basilisk.exe|system"
    "Seamonkey|C:/Program Files/SeaMonkey/seamonkey.exe|system"
    "Tor Browser|C:/Program Files/Tor Browser/Browser/firefox.exe|system"
    "Epic Privacy Browser|C:/Program Files/Epic Privacy Browser/epic.exe|system"
    "Slimjet|C:/Program Files/Slimjet/slimjet.exe|system"
    "Comodo Dragon|C:/Program Files/Comodo/Dragon/dragon.exe|system"
    "Torch Browser|C:/Program Files/TorchBrowser/Browser/torch.exe|system"
    "Maxthon|C:/Program Files/Maxthon/Bin/Maxthon.exe|system"
    "Maxthon|C:/Program Files (x86)/Maxthon/Bin/Maxthon.exe|system"
    "Avast Secure Browser|C:/Program Files/Avast Software/Browser/Application/AvastBrowser.exe|system"
    "AVG Secure Browser|C:/Program Files/AVG/Browser/Application/AVGBrowser.exe|system"
    "UC Browser|C:/Program Files/UCBrowser/Application/UCBrowser.exe|system"
    "360 Secure Browser|C:/Program Files/360/360se6/360se.exe|system"
    "Cent Browser|C:/Program Files/CentBrowser/Application/chrome.exe|system"
    "SRWare Iron|C:/Program Files/SRWare Iron/iron.exe|system"
    "Iridium|C:/Program Files/Iridium/iridium.exe|system"
    "Ungoogled Chromium|C:/Program Files/Chromium/chrome.exe|system"
    "Min|C:/Program Files/Min/Min.exe|system"
    "Falkon|C:/Program Files/Falkon/falkon.exe|system"
    "K-Meleon|C:/Program Files/K-Meleon/k-meleon.exe|system"
    "Midori|C:/Program Files/Midori/midori.exe|system"
    "qutebrowser|C:/Program Files/qutebrowser/qutebrowser.exe|system"
)

# Function to install for NSS-based browsers on Linux
install_nss_linux() {
    local cert_dir="$HOME/.pki/nssdb"
    
    if [ ! -d "$cert_dir" ]; then
        log_debug "Creating NSS database at $cert_dir"
        mkdir -p "$cert_dir"
        certutil -N -d sql:"$cert_dir" --empty-password 2>/dev/null || true
    fi
    
    if command -v certutil &> /dev/null; then
        # Remove old certificate if exists
        certutil -D -n "Custom CA" -d sql:"$cert_dir" 2>/dev/null || true
        # Add new certificate
        certutil -A -n "Custom CA" -t "C,," -i "$CA_FILE_PATH" -d sql:"$cert_dir" 2>/dev/null
        log_info "NSS Database: CA certificate installed (affects Chromium-based browsers)"
        return 0
    else
        log_warn "certutil not found. Install libnss3-tools package for NSS-based browsers"
        return 1
    fi
}

# Function to install for Firefox-based browsers on Linux
install_firefox_linux() {
    if ! command -v certutil &> /dev/null; then
        log_warn "Firefox: certutil not found. Install libnss3-tools package"
        return 1
    fi
    
    local installed=0
    local firefox_dirs=(
        "$HOME/.mozilla/firefox"
        "$HOME/.waterfox"
        "$HOME/.librewolf"
        "$HOME/.moonchild productions/pale moon"
        "$HOME/.moonchild productions/basilisk"
        "$HOME/.floorp"
        "$HOME/.zen"
        "$HOME/.mullvad"
        "$HOME/.tor-browser"
    )
    
    for ff_dir in "${firefox_dirs[@]}"; do
        if [ -d "$ff_dir" ]; then
            for profile in "$ff_dir"/*.default* "$ff_dir"/*.dev-edition-default* "$ff_dir"/*/; do
                if [ -d "$profile" ] && [ -f "$profile/cert9.db" -o -f "$profile/cert8.db" ]; then
                    certutil -D -n "Custom CA" -d sql:"$profile" 2>/dev/null || true
                    certutil -A -n "Custom CA" -t "C,," -i "$CA_FILE_PATH" -d sql:"$profile" 2>/dev/null && {
                        log_info "Firefox profile: CA installed to $(basename "$profile")"
                        installed=1
                    }
                fi
            done
        fi
    done
    
    return $installed
}

# Function to install for macOS
install_macos() {
    if command -v security &> /dev/null; then
        # Remove old certificate if exists
        sudo security delete-certificate -c "Custom CA" -t /Library/Keychains/System.keychain 2>/dev/null || true
        # Add new certificate
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CA_FILE_PATH"
        log_info "macOS System Keychain: CA certificate installed (affects all browsers)"
        return 0
    else
        log_error "macOS: security command not found"
        return 1
    fi
}

# Function to install for Windows
install_windows() {
    if command -v certutil &> /dev/null; then
        # Note: certutil on Windows doesn't have a simple way to remove by name
        certutil -addstore -f "ROOT" "$CA_FILE_PATH" 2>/dev/null
        log_info "Windows Certificate Store: CA certificate installed (affects all browsers)"
        return 0
    else
        log_error "Windows: certutil not found"
        return 1
    fi
}

# Detect browsers based on OS
echo ""
log_info "Scanning for installed browsers..."
echo ""

if [ "$OS" == "linux" ]; then
    for entry in "${LINUX_BROWSERS[@]}"; do
        IFS='|' read -r name cmd type <<< "$entry"
        if command -v "$cmd" &> /dev/null; then
            browsers_found["$name"]=1
            if [ "$type" == "nss" ]; then
                nss_browsers["$name"]=1
            elif [ "$type" == "firefox" ]; then
                firefox_based["$name"]=1
            fi
            log_debug "Found: $name"
        fi
    done
    
    # Display found browsers
    if [ ${#browsers_found[@]} -gt 0 ]; then
        echo ""
        log_info "Found ${#browsers_found[@]} browser(s):"
        for browser in "${!browsers_found[@]}"; do
            echo "  - $browser"
        done
        echo ""
    else
        log_warn "No browsers detected"
        exit 0
    fi
    
    # Install for NSS-based browsers
    if [ ${#nss_browsers[@]} -gt 0 ]; then
        install_nss_linux
        for browser in "${!nss_browsers[@]}"; do
            installed_browsers+=("$browser")
        done
    fi
    
    # Install for Firefox-based browsers
    if [ ${#firefox_based[@]} -gt 0 ]; then
        install_firefox_linux
        for browser in "${!firefox_based[@]}"; do
            installed_browsers+=("$browser")
        done
    fi
    
    # Install to system certificate store
    if command -v update-ca-certificates &> /dev/null; then
        log_info "Installing to system certificate store..."
        sudo cp "$CA_FILE_PATH" /usr/local/share/ca-certificates/custom-ca.crt 2>/dev/null || true
        sudo update-ca-certificates 2>/dev/null
        log_info "System: CA certificate installed"
    elif command -v trust &> /dev/null; then
        # For Arch/Fedora-based systems
        sudo trust anchor "$CA_FILE_PATH" 2>/dev/null
        log_info "System: CA certificate installed via trust anchor"
    fi

elif [ "$OS" == "macos" ]; then
    for entry in "${MACOS_APPS[@]}"; do
        IFS='|' read -r name path type <<< "$entry"
        if [ -d "$path" ]; then
            browsers_found["$name"]=1
            log_debug "Found: $name"
        fi
    done
    
    # Display found browsers
    if [ ${#browsers_found[@]} -gt 0 ]; then
        echo ""
        log_info "Found ${#browsers_found[@]} browser(s):"
        for browser in "${!browsers_found[@]}"; do
            echo "  - $browser"
        done
        echo ""
    else
        log_warn "No browsers detected"
        exit 0
    fi
    
    # On macOS, install to system keychain (affects all browsers)
    install_macos
    installed_browsers=("${!browsers_found[@]}")

elif [ "$OS" == "windows" ]; then
    for entry in "${WINDOWS_PATHS[@]}"; do
        IFS='|' read -r name path type <<< "$entry"
        # Convert Windows path to Unix-style for test
        unix_path="${path//\\/\/}"
        unix_path="${unix_path//C:\//\/c\/}"
        if [ -f "$unix_path" ]; then
            browsers_found["$name"]=1
            log_debug "Found: $name"
        fi
    done
    
    # Display found browsers
    if [ ${#browsers_found[@]} -gt 0 ]; then
        echo ""
        log_info "Found ${#browsers_found[@]} browser(s):"
        for browser in "${!browsers_found[@]}"; do
            echo "  - $browser"
        done
        echo ""
    else
        log_warn "No browsers detected"
        exit 0
    fi
    
    # On Windows, install to certificate store (affects all browsers)
    install_windows
    installed_browsers=("${!browsers_found[@]}")
else
    log_error "Unsupported operating system: $OS"
    exit 1
fi

# Summary
echo ""
echo "=========================================="
log_info "Installation Summary"
echo "=========================================="
log_info "Total browsers detected: ${#browsers_found[@]}"
if [ ${#installed_browsers[@]} -gt 0 ]; then
    log_info "CA certificate should now work with:"
    for browser in "${installed_browsers[@]}"; do
        echo "  ✓ $browser"
    done
else
    log_warn "No installations performed"
fi
echo ""
log_warn "IMPORTANT: Restart all browsers for changes to take effect!"
echo "=========================================="