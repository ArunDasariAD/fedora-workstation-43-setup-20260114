## MySQL Server
**Start the server**: `podman start mysql-server`  
**Stop the server:** `podman stop mysql-server`

## CopyQ
**Start CopyQ:** `copyq &`  
**Stop CopyQ:** `copyq exit`

## Gnome Extensions
**Enable:** `gnome-extensions enable color-picker@tuberry`  
**Disable:** `gnome-extensions disable color-picker@tuberry`

> `Vitals` Id = `Vitals@CoreCoding.com`

## Runing the Scipt (Fresh OS Installation)
```bash
# 0. Optional
sudo dnf install -y git

# 1. Download the repository
git clone https://github.com/your-username/fedora-setup-2026.git

# 2. Enter the directory
cd fedora-setup-2026

# 3. Make the scripts executable (GitHub does not always preserve permissions)
chmod +x *.sh

# 4. Run the main script
./main-setup.sh
```
