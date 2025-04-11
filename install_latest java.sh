#!/bin/bash
# install_bellsoft_java_autodetect.sh
# Automatically detects system architecture and installs BellSoft JRE 24+37
# Builds from source for unsupported architectures (like powerpc)

set -e
echo "=== BellSoft JRE 24+37 Installer ==="

# Detect architecture
ARCH=$(uname -m)

echo "Detected architecture: $ARCH"

# Define download URLs for supported architectures
if [[ "$ARCH" == "x86_64" ]]; then
  JRE_URL="https://download.bell-sw.com/java/24+37/bellsoft-jre24+37-linux-amd64-full.deb"
  DEB_NAME="bellsoft-jre24-amd64.deb"
  JVM_PATH="/usr/lib/jvm/bellsoft-java24-full"
elif [[ "$ARCH" == "aarch64" ]]; then
  JRE_URL="https://download.bell-sw.com/java/24+37/bellsoft-jre24+37-linux-aarch64-full.deb"
  DEB_NAME="bellsoft-jre24-arm64.deb"
  JVM_PATH="/usr/lib/jvm/bellsoft-java24-full"
else
  echo "Unsupported architecture: $ARCH"
  echo "Attempting to build from source for this architecture."
  echo "[+] Starting OpenJDK 24 build process..."
  # Step 1: Install dependencies
  echo "[+] Installing build dependencies..."
  sudo apt-get update
  sudo apt-get install -y build-essential autoconf zip unzip \
  libx11-dev libxext-dev libxrender-dev libxtst-dev libxt-dev \
  libcups2-dev libfreetype6-dev libasound2-dev ccache libffi-dev \
  libnuma-dev libgtk-3-dev libxrandr-dev libxinerama-dev \
  libfontconfig1-dev git curl

# Step 2: Install Boot JDK (OpenJDK 17)
echo "[+] Installing boot JDK (OpenJDK 17)..."
sudo apt-get install -y openjdk-17-jdk

BOOT_JDK=$(dirname $(dirname $(readlink -f $(which javac))))
echo "[+] Boot JDK path: $BOOT_JDK"

# Step 3: Clone latest OpenJDK source
mkdir -p ~/openjdk-build
cd ~/openjdk-build
echo "[+] Cloning latest OpenJDK repo (JDK 24)..."
git clone https://github.com/openjdk/jdk.git
cd jdk

# Step 4: Configure build
echo "[+] Configuring build..."
bash configure --with-boot-jdk="$BOOT_JDK" --disable-warnings-as-errors || {
  echo "[!] Configuration failed"
  exit 1
}

# Step 5: Compile JDK
echo "[+] Compiling OpenJDK 24 (this may take a while)..."
make images || {
  echo "[!] Build failed"
  exit 1
}

# Step 6: Install to /usr/lib/jvm/openjdk-24
echo "[+] Installing OpenJDK 24..."
mkdir -p /usr/lib/jvm/openjdk-24
cp -r build/*/images/jdk/* /usr/lib/jvm/openjdk-24/

# Step 7: Register as default Java
echo "[+] Setting OpenJDK 24 as default Java..."
update-alternatives --install /usr/bin/java java /usr/lib/jvm/openjdk-24/bin/java 1
update-alternatives --set java /usr/lib/jvm/openjdk-24/bin/java

# Final Check
echo "[✓] OpenJDK 24 Installed Successfully!"
java -version
  exit 1
fi

# Download the JRE package
echo "[+] Downloading JRE from: $JRE_URL"
wget -O "$DEB_NAME" "$JRE_URL"

# Install the downloaded JRE package
echo "[+] Installing JRE..."
sudo dpkg -i "$DEB_NAME" || sudo apt-get install -f -y

# Set as the default JRE
echo "[+] Setting JRE as system default..."
sudo update-alternatives --install /usr/bin/java java "$JVM_PATH/bin/java" 1
sudo update-alternatives --set java "$JVM_PATH/bin/java"

# Show Java version
echo "[✓] Java version installed:"
java -version

# Ask if the user wants to enable headless mode
read -p "Would you like to enable Java headless mode globally? (y/n): " enable_headless
if [[ "$enable_headless" =~ ^[Yy]$ ]]; then
  echo 'export JAVA_TOOL_OPTIONS="-Djava.awt.headless=true"' | sudo tee /etc/profile.d/java_headless.sh > /dev/null
  sudo chmod +x /etc/profile.d/java_headless.sh
  echo "[✓] Headless mode enabled (this will apply after reboot or re-login)."
else
  echo "[*] Skipped headless mode setup."
fi

# Ask about creating a systemd service for Java
read -p "Would you like to create a systemd service for a headless Java app? (y/n): " setup_service
if [[ "$setup_service" =~ ^[Yy]$ ]]; then
  echo "[+] Creating headless app directory: /opt/headless-java-app"
  sudo mkdir -p /opt/headless-java-app
  sudo touch /opt/headless-java-app/server.jar

  echo "[+] Creating systemd service file..."
  sudo tee /etc/systemd/system/headless-java.service > /dev/null <<EOL
[Unit]
Description=Headless Java Application
After=network.target

[Service]
ExecStart=$JVM_PATH/bin/java -Djava.awt.headless=true -jar /opt/headless-java-app/server.jar
WorkingDirectory=/opt/headless-java-app
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOL

  echo "[✓] Systemd service created (not enabled)."
  echo "    To enable: sudo systemctl enable --now headless-java.service"
else
  echo "[*] Skipped systemd service creation."
fi

echo "[✓] Installation complete!"
