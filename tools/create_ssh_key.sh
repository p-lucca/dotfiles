#!/bin/bash
# SSH Key Setup Script
# This script helps you add SSH keys to your ~/.ssh/ directory

# Ensure ~/.ssh directory exists
mkdir -p ~/.ssh

# Use Ed25519 key type (most secure and modern)
key_name="id_ed25519"
echo "Using Ed25519 key type: $key_name"

# Set file paths
private_key_path="$HOME/.ssh/$key_name"
public_key_path="$HOME/.ssh/$key_name.pub"

# Check if key already exist
if [ -f "$private_key_path" ] || [ -f "$public_key_path" ]; then
    echo "Please handle your existing key before generating new keys."
    exit 1
fi

# Get user information
user_name=$(gum input --placeholder "Enter your full name" --prompt "Full Name> ")
user_email=$(gum input --placeholder "Enter your email address" --prompt "Email> ")
user_passphrase=$(gum input --password --placeholder "Enter passphrase for SSH and GPG keys")
user_passphrase_confirm=$(gum input --password --placeholder "Confirm passphrase")

if [[ "$user_passphrase" != "$user_passphrase_confirm" ]]; then
  echo "Error: Passphrases do not match." >&2
  exit 1
fi

# Validate inputs
if [ -z "$user_name" ]; then
    echo "Error: Full name cannot be empty"
    exit 1
fi

if [ -z "$user_email" ]; then
    echo "Error: Email address cannot be empty"
    exit 1
fi

if [ -z "$user_passphrase" ]; then
    echo "Error: Passphrase cannot be empty"
    exit 1
fi

echo "User: $user_email"

# =============================================================================
# SSH KEY GENERATION
# =============================================================================

echo ""
echo "=== SSH Key Generation ==="

# Generate Ed25519 SSH key
echo "Generating new Ed25519 SSH key pair..."
ssh-keygen -t ed25519 -C "$user_email" -f "$private_key_path" -N "$user_passphrase" -q

# Check if key generation was successful
if [ $? -eq 0 ]; then
    echo "✓ SSH key pair generated successfully"
else
    echo "Error: Failed to generate SSH key pair"
    exit 1
fi

# Set appropriate permissions (ssh-keygen already sets these correctly, but let's be explicit)
chmod 644 "$public_key_path"
chmod 600 "$private_key_path"
echo "✓ SSH permissions verified (644 for public key, 600 for private key)"

# Optionally add to SSH agent
add_to_agent=$(gum confirm "Add SSH private key to SSH agent?" && echo "yes" || echo "no")
if [ "$add_to_agent" = "yes" ]; then
    ssh-add "$private_key_path"
    if [ $? -eq 0 ]; then
        echo "✓ SSH private key added to SSH agent"
    else
        echo "Warning: Failed to add SSH private key to SSH agent"
    fi
fi

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo "=== Setup Summary ==="
echo "✓ SSH key setup completed successfully!"
echo "  Public key:  $public_key_path"
echo "  Private key: $private_key_path"
echo ""

# =============================================================================
# GIT CONFIGURATION
# =============================================================================

echo "=== Git Configuration ==="
echo "Configure Git with your identity:"
echo "  git config --global user.name \"$user_name\""
echo "  git config --global user.email \"$user_email\""
echo ""

echo "To use SSH key for Git commit signing (GitHub supports this):"
echo "  git config --global gpg.format ssh"
echo "  git config --global user.signingkey \"$public_key_path\""
echo "  git config --global commit.gpgsign true"
echo ""

echo "Alternative: Configure SSH for authentication only (no signing):"
echo "  git config --global user.name \"$user_name\""
echo "  git config --global user.email \"$user_email\""
echo "  # Then use SSH URLs: git@github.com:username/repo.git"
echo ""

# =============================================================================
# SSH KEY DEPLOYMENT
# =============================================================================

echo "=== Adding SSH Key to Services ==="
echo ""
echo "📋 Your SSH Public Key (copy this to GitHub, servers, etc.):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$public_key_path"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📖 Quick Setup Guide:"
echo ""
echo "🐙 GitHub:"
echo "   1. Go to: https://github.com/settings/ssh/new"
echo "   2. Title: $(hostname) - Ed25519 ($(date +%Y-%m-%d))"
echo "   3. Key type:"
echo "      - Authentication Key (for SSH access)"
echo "      - Signing Key (for commit/tag signing)"
echo "      👉 You can use the same key for both — just add it twice, once as Authentication and once as Signing."
echo "   4. Paste the public key above"
echo ""

echo "🖥️  SSH Server Access:"
echo "   1. Copy public key to server: ssh-copy-id -i \"$public_key_path\" user@server"
echo "   2. Or manually: cat \"$public_key_path\" >> ~/.ssh/authorized_keys"
echo ""

echo "🧪 Test SSH Connection:"
echo "   GitHub:  ssh -T git@github.com"
echo "   Server:  ssh -i \"$private_key_path\" user@your-server"
echo ""

echo "💡 Pro Tips:"
echo "   • Your private key stays secret and secure on this machine"
echo "   • The public key (shown above) is safe to share and add to services"
echo "   • SSH agent is recommended for convenience (already configured if you selected it)"
echo "   • For commit signing, GitHub now supports SSH keys as an alternative to GPG"
