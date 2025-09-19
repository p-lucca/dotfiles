#!/bin/bash

# Get default interface
iface=$(ip route | awk '/^default/ {print $5}' | head -n 1)

case "$iface" in
    wlx*|wlp*|wl*)
        # Get connection details via `iwd`
        iwd_output=$(iwctl station "$iface" show)

        # Extract SSID (Connected network) and BSSID (ConnectedBss)
        ssid=$(echo "$iwd_output" | grep -i 'Connected network' | sed 's/.*Connected network *\(.*\)/\1/' | tr -d '[:space:]')
        bssid=$(echo "$iwd_output" | grep -i 'ConnectedBss' | sed 's/.*ConnectedBss *\(.*\)/\1/' | tr -d '[:space:]')

        if [[ -n "$ssid" && -n "$bssid" ]]; then
            echo "{\"text\": \"  $ssid ($bssid)\"}"
        else
            echo "{\"text\": \"  Disconnected\"}"
        fi
        ;;
    enp*|eno*|eth*)
        echo "{\"text\": \"󰈀\"}"
        ;;
    *)
        echo "{\"text\": \"⚠\"}"
        ;;
esac
