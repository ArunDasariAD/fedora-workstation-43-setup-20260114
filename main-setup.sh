#!/bin/bash

# ==========================================
# Complete Fedora Workstation Setup Script
# Includes: System Settings, VS Code, Node, Chrome, and MySQL
# ==========================================

set -e  # Exit immediately if a command exits with a non-zero status

echo ">> Starting System Configuration..."

# -----------------------------------------------------------------------------------
# System Settings
# -----------------------------------------------------------------------------------
echo ">> Applying GNOME System Settings..."

# Disable Hot Corner
gsettings set org.gnome.desktop.interface enable-hot-corners false

# App Switcher: Current workspace only
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# Disable Automatic Screen Blank (0 = never)
gsettings set org.gnome.desktop.session idle-delay 0

# Disable Automatic Suspend when plugged in
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

# Modify Notification Panel (Super+V -> Super+N)
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>n']"

# Modify Quick Settings (Super+S -> Super+A)
# Note: This overrides the default 'Show Applications' shortcut
gsettings set org.gnome.shell.keybindings toggle-quick-settings "['<Super>a']"

# Remap 'Show Applications' (Super+S)
# Since Quick Settings took Super+A, we map the App Grid to Super+S so it isn't lost.
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>s']"

# -----------------------------------------------------------------------------------
# System Updates & Repositories
# -----------------------------------------------------------------------------------
echo ">> Updating System and Repositories..."

# Update the whole system
sudo dnf upgrade -y

# Install Fedora Workstation Repositories
sudo dnf install -y fedora-workstation-repositories

# Enable Flathub Repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Obsidian
echo ">> Installing Obsidian..."
flatpak install -y flathub md.obsidian.Obsidian


# -----------------------------------------------------------------------------------
# Microsoft Tools
# -----------------------------------------------------------------------------------
echo ">> Installing Microsoft Tools..."

# Import Microsoft GPG key
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

# Add VS Code Repository
printf "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

# Refresh package list (allow exit code 100 which means 'updates available')
sudo dnf check-update || true

# Install VS Code
sudo dnf install -y code

# Install PowerShell (v7.4.6)
sudo dnf install -y https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/powershell-7.4.6-1.rh.x86_64.rpm


# -----------------------------------------------------------------------------------
# Node.js Setup
# -----------------------------------------------------------------------------------
echo ">> Setting up Node.js Environment..."

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# MANUALLY load NVM (Script-safe method)
# 'source ~/.bashrc' is skipped by non-interactive scripts, so we load nvm directly here:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verify NVM
nvm -v

# Install Node LTS and NPM
nvm install --lts
node -v
npm -v


# -----------------------------------------------------------------------------------
# Google Tools
# -----------------------------------------------------------------------------------
echo ">> Installing Google Tools..."

# Install Google Chrome
sudo dnf config-manager setopt google-chrome.enabled=1
sudo dnf install -y google-chrome-stable

# Install Google Gemini CLI
npm install -g @google/gemini-cli


# -----------------------------------------------------------------------------------
# GNOME Extensions
# -----------------------------------------------------------------------------------
echo ">> Installing GNOME Extensions..."

# (Uncomment if needed) sudo dnf install -y lm_sensors
# (Uncomment if needed) sudo sensors-detect

sudo dnf install -y pipx
pipx ensurepath

# Reload path for pipx (Simulated source)
export PATH="$PATH:$HOME/.local/bin"

pipx install gnome-extensions-cli --system-site-packages

# Install Extensions
# Note: You may need to restart the shell/session for extensions to fully register
gext install Vitals@CoreCoding.com color-picker@tuberry
gext enable Vitals@CoreCoding.com
gext enable color-picker@tuberry


# -----------------------------------------------------------------------------------
# Run MySQL Setup Script
# -----------------------------------------------------------------------------------
echo ""
echo ">> Launching MySQL Setup Script..."

if [ -f "./mysql-setup.sh" ]; then
    chmod +x ./mysql-setup.sh
    ./mysql-setup.sh
else
    echo "ERROR: 'mysql-setup.sh' not found in the current directory."
    echo "Skipping MySQL setup."
fi

echo ""


# -----------------------------------------------------------------------------------
# Install CopyQ
# -----------------------------------------------------------------------------------
echo ""
echo ">> Launching CopyQ Installation Script..."

if [ -f "./install-copyq.sh" ]; then
    chmod +x ./install-copyq.sh
    ./install-copyq.sh
else
    echo "ERROR: 'install-copyq.sh' not found in the current directory."
    echo "Skipping CopyQ setup."
fi

echo ""
echo ">> Main Setup Complete!"
