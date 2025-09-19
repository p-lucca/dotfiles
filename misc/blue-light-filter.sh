# Set variables
SERVICE_NAME="hyprsunset.service"
OVERRIDE_DIR="$HOME/.config/systemd/user/${SERVICE_NAME}.d"
OVERRIDE_FILE="${OVERRIDE_DIR}/override.conf"

# Create the override directory if it doesn't exist
mkdir -p "$OVERRIDE_DIR"

# Write the override configuration
cat > "$OVERRIDE_FILE" <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/hyprsunset -t 2800 -g 80
EOF

echo "Override written to $OVERRIDE_FILE"
