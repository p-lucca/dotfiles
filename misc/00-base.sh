# Set the timezone to America/Sao_Paulo
echo "Setting the timezone to America/Sao_Paulo..."
timedatectl set-timezone America/Sao_Paulo

# # Ask the user if they want to change the keyboard layout
# echo "Do you want to change the keyboard layout? (y/n)"
# read change_keyboard

# if [[ "$change_keyboard" == "y" || "$change_keyboard" == "Y" ]]; then
#     echo "Setting the keyboard layout..."
#     sudo dpkg-reconfigure keyboard-configuration
#     setupcon
#     sudo update-initramfs -u
#     echo "Keyboard layout changed and configuration updated."
# else
#     echo "Skipping keyboard layout change."
# fi
