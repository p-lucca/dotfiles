# Copy over configs
cp -R ./config/* ~/.config/

# Copy .desktop declarations
mkdir -p ~/.local/share/applications
# cp ./applications/*.desktop ~/.local/share/applications/

# Configure auto-login and disable screen clearing for tty1
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I \$TERM
EOF

# Configure Docker logging and user permissions
sudo mkdir -p /etc/docker
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"5"}}' | sudo tee /etc/docker/daemon.json
sudo usermod -aG docker "${USER}"

# Automatically start Hyprland using uwsm on first TTY session
cat > ~/.bash_profile << 'EOF'
if [[ -z $DISPLAY && $(tty) == /dev/tty1 ]]; then
    if uwsm check may-start; then
        exec uwsm start hyprland-uwsm.desktop
    fi
fi
EOF
