#!/bin/bash

# ==========================================
# MySQL Setup Script for Fedora Workstation 43
# Using Podman (Interactive Password)
# ==========================================

# Exit immediately if a command exits with a non-zero status
set -e

# 1. Install Podman
echo ">> Installing Podman..."
sudo dnf install -y podman

# 2. Verify Installation
echo ">> Verifying Podman version..."
podman --version

# 3. Create Persistent Volume
echo ">> Creating persistent volume 'mysql_data'..."
podman volume create mysql_data || true

# 4. Interactive Password Prompt
echo ">> Configuration Required:"
while true; do
    # -s hides the input, -p displays the prompt
    read -s -p "Enter your desired MySQL Root Password: " DB_PASSWORD
    echo ""
    read -s -p "Confirm Password: " DB_PASSWORD_CONFIRM
    echo ""
    
    if [ -z "$DB_PASSWORD" ]; then
        echo "Error: Password cannot be empty. Please try again."
    elif [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
        echo "Error: Passwords do not match. Please try again."
    else
        break
    fi
done

# 5. Run MySQL Container
echo ">> Starting MySQL container..."

# Check if container exists
if podman ps -a --format '{{.Names}}' | grep -q "^mysql-server$"; then
    echo "Container 'mysql-server' already exists."
    echo "If you want to re-create it with the NEW password, remove it first using: podman rm -f mysql-server"
    echo "Attempting to start existing container..."
    podman start mysql-server
else
    podman run -d \
      --name mysql-server \
      -p 3306:3306 \
      -e MYSQL_ROOT_PASSWORD="$DB_PASSWORD" \
      -v mysql_data:/var/lib/mysql:Z \
      docker.io/library/mysql:latest
fi

echo ""
echo "========================================================"
echo "   MySQL Server is running on Port 3306"
echo "========================================================"
echo ""

# 6. Install DBeaver (Added Step)
echo ">> Installing DBeaver Community via Flatpak..."
# Added -y for non-interactive installation
flatpak install -y flathub io.dbeaver.DBeaverCommunity

echo ""

# 7. Print User Instructions
cat <<EOF
# Information to the user:

## Starting/Stopping the server:
- To stop:  podman stop mysql-server
- To start: podman start mysql-server
    - After starting, check logs with: podman logs -f mysql-server

## Ways to interact with the MySQL server: 
1. Option 1 (Inside the container):
   - Standard Client: podman exec -it mysql-server mysql -u root -p
   - Advanced Shell:  podman exec -it mysql-server mysqlsh -u root -p
   
2. Option 2 (From your host):
   - Use GUI tools like DBeaver or MySQL Workbench.
   - Connect to Host: 127.0.0.1
   - Port: 3306
   - Password: (The password you just entered)

## Setting-up DBeaver (Connection Guide)
1. Click the Plug icon (New Database Connection).
2. Select MySQL -> Next.
3. Main Tab Details: 
    - Server Host: 127.0.0.1 (Use IP, not localhost, to force TCP bridge)
    - Port: 3306
    - Username: root
    - Password: (The password you just entered)
4. Driver Properties (Crucial for MySQL 8+):
    - Go to "Driver properties" tab.
    - Set 'allowPublicKeyRetrieval' to TRUE.
    - Set 'useSSL' to FALSE.
5. Click "Test Connection" -> "Finish".

EOF
