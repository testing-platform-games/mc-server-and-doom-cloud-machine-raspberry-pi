#!/bin/bash
# setup_doom.sh

# Function to display messages
echo_message() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# Update system packages
echo_message "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Chocolate Doom
echo_message "Installing Chocolate Doom..."
sudo apt install -y chocolate-doom

# Install the shareware DOOM WAD
echo_message "Installing DOOM shareware WAD..."
sudo apt install -y doom-wad-shareware

# Verify installation
if [ -f "/usr/share/games/doom/DOOM1.WAD" ]; then
  echo_message "DOOM shareware WAD installed successfully."
else
  echo_message "Failed to install DOOM shareware WAD."
  exit 1
fi

# Provide instructions to the user
echo_message "Installation complete!"
echo "You can now play DOOM by running 'chocolate-doom' in the terminal."
echo "Enjoy your game!"
