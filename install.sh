#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

################################
# Install 'yay' (AUR helper)   #
################################
if ! command -v yay &>/dev/null; then
  echo "yay not found, installing yay..."

  # Clone yay from AUR and build it
  git clone https://aur.archlinux.org/yay-bin.git ~/yay-bin
  pushd ~/yay-bin
  makepkg -si --noconfirm
  popd

  # Clean up the yay source directory
  rm -rf ~/yay-bin
else
  echo "✔ yay is already installed."
fi

##################
# Package setup  #
##################

# List of essential packages to be installed
INSTALL_PACKAGES=(
  gum nano unzip openssl libnotify rofi nautilus imv mpv signal-desktop thunderbird bash-completion
  kitty lazygit docker docker-compose ansible tofu terraform go air-bin goose nvim luarocks tree-sitter-cli
  htop curl wget bind inetutils whois traceroute localsend-bin flatpak supersonic-desktop restish infisical-bin
  swaync kvantum-qt5 qt5-wayland qt6-wayland tableplus seahorse tldr fd wl-clipboard wl-clip-persist
  vulkan-radeon vulkan-tools mesa-utils libva-mesa-driver gnome-themes-extra evince imagemagick nmap
  bluez bluez-utils iwd iwgtk playerctl pavucontrol wireplumber alsa-utils fzf tectonic postgresql opencode-bin
  uwsm libnewt hyprland hyprlock hyprpolkitagent hyprland-qtutils hyprsunset hyprpaper waybar gnome-calculator
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk zen-browser-bin bitwarden-bin goreleaser-bin swaks
  ttf-font-awesome ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols speech-dispatcher minify jq python-passlib
)

# Check for missing packages and install them
echo "Checking and installing required packages..."
TO_INSTALL=()

# Loop through the packages and check if they are installed
for pkg in "${INSTALL_PACKAGES[@]}"; do
  if ! pacman -Q "$pkg" &>/dev/null; then
    echo "$pkg is not installed. Marking for installation."
    TO_INSTALL+=("$pkg")
  else
    echo "✔ $pkg is already installed."
  fi
done

# Install the missing packages
if [ ${#TO_INSTALL[@]} -gt 0 ]; then
  echo "Installing missing packages: ${TO_INSTALL[@]}..."
  yay -S --noconfirm --needed "${TO_INSTALL[@]}"
else
  echo "✔ All required packages are already installed."
fi

##########################
# Enable system services #
##########################

# Define required systemd services
SYSTEMD_SERVICES=(
  bluetooth docker iwd
)

# Enable and start required systemd services
echo "Checking and enabling required systemd services..."
for service in "${SYSTEMD_SERVICES[@]}"; do
  if systemctl is-enabled --quiet "$service"; then
    echo "✔ $service is already enabled."
  else
    echo "Enabling $service..."
    sudo systemctl enable --now "$service"
    echo "✔ $service has been enabled."
  fi
done

###############################
# Enable system USER services #
###############################

# Define required systemd user services
SYSTEMD_USER_SERVICES=(
  waybar hyprpolkitagent hyprpaper swaync hyprsunset
)

# Enable and start required systemd user services
echo "Checking and enabling required systemd user services..."
for service in "${SYSTEMD_USER_SERVICES[@]}"; do
  if systemctl --user is-enabled --quiet "$service"; then
    echo "✔ user $service is already enabled."
  else
    echo "Enabling user $service..."
    systemctl --user enable "$service"
    echo "✔ user $service has been enabled."
  fi
done

###########################
# Flatpak + Flathub setup #
###########################

# Add Flathub repository to Flatpak if not already added
echo "Checking if Flathub is already added to Flatpak..."

if flatpak remotes | grep -q "flathub"; then
  echo "✔ Flathub repository is already added."
else
  echo "Adding Flathub repository..."
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  echo "✔ Flathub repository added."
fi

# Flatpak packages to install
FLATPAK_PACKAGES=()
TO_INSTALL=()

# Check for missing Flatpak packages
echo "Checking and installing required Flatpak packages..."
for pkg in "${FLATPAK_PACKAGES[@]}"; do
  if flatpak list --app | grep -q "$pkg"; then
    echo "✔ $pkg is already installed."
  else
    TO_INSTALL+=("$pkg")
  fi
done

# Install missing Flatpak packages
if [ ${#TO_INSTALL[@]} -gt 0 ]; then
  echo "Installing missing Flatpak packages: ${TO_INSTALL[*]}"
  for pkg in "${TO_INSTALL[@]}"; do
    flatpak install -y flathub "$pkg"
  done
  echo "✔ Flatpak packages installed."
else
  echo "✔ All Flatpak packages are already installed."
fi

################
# Misc Setup   #
################
for f in ./misc/*.sh; do
  echo -e "\nRunning misc script: $f"
  source "$f"
done

#############q#######
# Post-installation #
####################

# Ask user for reboot confirmation
echo "All required packages have been installed successfully."

# Use gum (CLI utility) to prompt for reboot
if gum confirm "Reboot to apply all settings?"; then
  echo "Rebooting system..."
  reboot
else
  echo "Reboot skipped. Please reboot later when necessary."
fi
