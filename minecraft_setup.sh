#!/bin/bash
# minecraft_setup.sh
# This script sets up a Minecraft Java server on a Raspberry Pi.
# After setting up, it prompts the user to change their password,
# enable autologin, configure autorun, and finally ask if they want to reboot.

# Function to display messages with separators
echo_message() {
  echo "========================================"
  echo "$1"
  echo "========================================"
}

# ------------------
# Main Setup Phase
# ------------------

echo_message "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo_message "Installing required packages..."
sudo apt install -y wget curl unzip git openjdk-17-jre-headless screen

echo_message "Creating Minecraft server directory..."
sudo mkdir -p /opt/minecraft
sudo chown "$USER:$USER" /opt/minecraft

echo_message "Downloading Minecraft server..."
cd /opt/minecraft || { echo "Directory change failed"; exit 1; }
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

echo_message "Creating start.sh script for Minecraft server..."
cat <<EOL > /opt/minecraft/start.sh
#!/bin/bash
cd /opt/minecraft
screen -dmS java_server java -Xmx1536M -Xms1536M -jar server.jar nogui
EOL
chmod +x /opt/minecraft/start.sh

echo_message "Creating eula.txt..."
cat <<EOL > /opt/minecraft/eula.txt
eula=true
EOL

echo_message "Minecraft server setup complete!"
echo "You can run the server with: /opt/minecraft/start.sh"

# 1. Prompt to change the account password
echo "Do you want to change the password for your current account ($USER)? (y/n)"
read -r change_pw
if [[ "$change_pw" =~ ^[Yy]$ ]]; then
  echo "Changing password for $USER. Please follow the prompts."
  passwd "$USER"
fi

# 2. Prompt to enable automatic sign-in (autologin) on tty1 for your account
echo "Do you want to enable auto sign-in for your account ($USER) on tty1? (y/n)"
read -r auto_signin
if [[ "$auto_signin" =~ ^[Yy]$ ]]; then
  echo_message "Configuring autologin for $USER..."
  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
  sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF
  sudo systemctl daemon-reload
  sudo systemctl restart getty@tty1
  echo "Auto sign-in has been enabled."
fi

# 3. Prompt to set up the Minecraft server script to autorun on boot
echo "Do you want to configure the Minecraft server to autorun on boot? (y/n)"
read -r autorun
if [[ "$autorun" =~ ^[Yy]$ ]]; then
  echo_message "Configuring autorun for the Minecraft server..."
  # Append an @reboot entry to current user's crontab
  (crontab -l 2>/dev/null; echo "@reboot /opt/minecraft/start.sh") | crontab -
  echo "Autorun entry has been added to your crontab."
fi

# 4. Prompt at the end asking if the user wants to reboot now
echo "Do you want to reboot the system now to apply changes? (y/n)"
read -r reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
  echo_message "Rebooting system in 5 seconds... (Press Ctrl+C to cancel)"
  for i in {5..1}; do
    echo "$i..."
    sleep 1
  done
  sudo reboot
else
  echo "Reboot canceled. Please reboot manually later for all changes to take effect."
fi

echo_message "Setup complete. Enjoy your Minecraft server!"
