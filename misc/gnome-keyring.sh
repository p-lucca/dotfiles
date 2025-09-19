#!/bin/bash

# Step 1: Delete any file with prefix "gnome-keyring" in /etc/xdg/autostart/
echo "Deleting files with prefix 'gnome-keyring' from /etc/xdg/autostart/..."
for file in /etc/xdg/autostart/gnome-keyring*; do
  if [ -f "$file" ]; then
    sudo rm -f "$file"  # Added -f to force the removal without prompting
    echo "Deleted: $file"
  fi
done

# Step 2: Create the necessary directories for the override
echo "Creating necessary directories for the override..."
mkdir -p ~/.config/systemd/user/gnome-keyring-daemon.service.d/

# Step 3: Create an override for the systemd service
echo "Creating an override for gnome-keyring-daemon.service..."

# Create or edit the override file
cat <<EOL > ~/.config/systemd/user/gnome-keyring-daemon.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/gnome-keyring-daemon --foreground --components="ssh,pkcs11,secrets" --control-directory=%t/keyring
EOL

# Step 4: Reload systemd user services to apply the change
echo "Reloading systemd user services..."
systemctl --user daemon-reload

# Step 5: Restart the GNOME Keyring service to apply the changes
echo "Restarting gnome-keyring-daemon service..."
systemctl --user restart gnome-keyring-daemon.service

echo "Script execution completed."
