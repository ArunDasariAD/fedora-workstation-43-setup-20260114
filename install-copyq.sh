#!/bin/bash

# 1. Install CopyQ
echo "Installing CopyQ..."
sudo dnf install -y copyq

# Define the source (system) and destination (local) paths
SYSTEM_FILE="/usr/share/applications/com.github.hluk.copyq.desktop"
LOCAL_DIR="$HOME/.local/share/applications"
LOCAL_FILE="$LOCAL_DIR/com.github.hluk.copyq.desktop"

# Check if installation was successful and the system file exists
if [ -f "$SYSTEM_FILE" ]; then
    echo "CopyQ installed successfully."

    # 2. Ensure the local applications directory exists
    mkdir -p "$LOCAL_DIR"

    # 3. Copy the desktop file to the local user directory
    # We use cp without sudo because this is your home folder
    cp "$SYSTEM_FILE" "$LOCAL_FILE"
    echo "Copied desktop file to $LOCAL_FILE"

    # 4. Modify the LOCAL file to fix the tray icon
    # No sudo needed here either
    
    # Replace the Exec line to force the XCB platform (fixes missing icon)
    sed -i 's|^Exec=.*copyq|Exec=env QT_QPA_PLATFORM=xcb copyq|' "$LOCAL_FILE"
    
    # Disable DBus activation to ensure our custom Exec command is always used
    sed -i 's|^DBusActivatable=true|DBusActivatable=false|' "$LOCAL_FILE"
    
    # ---------------------------------------------------------
    # 5. Configure Custom Shortcut (Super+V) - Safe Append Mode
    # ---------------------------------------------------------
    echo "Configuring global keyboard shortcut (Super+V)..."
    
    CUSTOM_KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"

    # Set the shortcut details (Name, Command, Binding)
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_KEY_PATH name "CopyQ"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_KEY_PATH command "copyq toggle"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$CUSTOM_KEY_PATH binding "<Super>v"

    # GET current custom keybindings
    CURRENT_LIST=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)

    # CHECK if the list is empty (represented as "@as []")
    if [[ "$CURRENT_LIST" == "@as []" ]]; then
        NEW_LIST="['$CUSTOM_KEY_PATH']"
    else
        # Remove the closing bracket ']'
        TRUNCATED_LIST=${CURRENT_LIST%]}
        # Append our new path and close the bracket
        NEW_LIST="$TRUNCATED_LIST, '$CUSTOM_KEY_PATH']"
    fi

    # APPLY the new list
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST"

    echo "CopyQ shortcut added safely."
    
    echo "Configuration updated successfully."
    echo "Please log out and log back in for the changes to take effect."

else
    echo "Error: CopyQ installation failed or desktop file not found at $SYSTEM_FILE"
    exit 1
fi
