# === Modify /etc/hosts with custom_hosts ===
echo "Checking if custom_hosts marker exists in /etc/hosts..."

HOSTS_FILE="/etc/hosts"
if ! grep -q "# custom_hosts" "$HOSTS_FILE"; then
    echo "Adding hosts entries to $HOSTS_FILE..."

    # Add necessary entries to /etc/hosts
    sudo bash -c "cat <<EOF >> $HOSTS_FILE

# custom_hosts
127.0.0.1   subdomain.localhost
127.0.0.1   *.localhost
EOF"

    echo "Hosts entries added to $HOSTS_FILE."
else
    echo "custom_hosts marker already exists in $HOSTS_FILE. Skipping."
fi
