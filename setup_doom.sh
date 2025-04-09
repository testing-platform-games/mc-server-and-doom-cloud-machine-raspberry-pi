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

#Make the doom_start.sh file
cat <<EOL > ./doom_start.sh
#!/bin/bash n

# Path to the DOOM WAD file
IWAD_PATH="/usr/share/games/doom/DOOM1.WAD"

# Check if the WAD file exists
if [ ! -f "$IWAD_PATH" ]; then
  echo "Error: WAD file not found. Please ensure DOOM1.WAD is installed. Install by using "sudo apt install doom-wad-shareware"."
  exit 1
fi

# Start Chocolate Doom with the shareware WAD
chocolate-doom -iwad "$IWAD_PATH" -nosound -nojoy -nomouse
EOL

# Provide instructions to the user
echo_message "Installation complete!"
echo "You can now play DOOM by running "./doom_start.sh" in the terminal."
