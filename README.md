# Minecraft Server/DOOM Cloud Machine
:black_square_button: Minecraft Server and :feelsgood: DOOM Cloud Gaming Machine files for Raspberry Pi
### Minimum System Requirements:
- Raspberry Pi 4
- 2 Gigabytes/2048 Megabytes of RAM
- Raspberry Pi OS Version 2024-11-19 (Fresh install without desktop)
- (Optinal) A Bible (if you are afraid that you may break the system)
- Knowledge of using the Linux terminal
### Install Instructions:
- Get wget if you don't have it:
```bash
sudo apt-get install wget
```
- Get the Minecraft Server Setup .sh file and make it executable:
```bash
wget https://github.com/testing-platform-games/mc-server-and-doom-cloud-machine-raspberry-pi/raw/refs/heads/main/install_latest_java.sh
chmod +x install_latest_java.sh
```
- Run it:
```bash
./minecraft_setup.sh
```
- Get the install script for Java 24 (Compiles/Installs on anything) and make it executable:
```bash
wget https://github.com/testing-platform-games/mc-server-and-doom-cloud-machine-raspberry-pi/raw/refs/heads/main/install_latest_java.sh
chmod +x install_latest_java.sh
```
- Run it:
```bash
./install_latest_java.sh
```
- Get the DOOM Cloud Machine Setup .sh file and make it executable:
```bash
wget https://github.com/testing-platform-games/mc-server-and-doom-cloud-machine-raspberry-pi/raw/refs/heads/main/doom_setup.sh
chmod +x doom_setup.sh
```
- Run it:
```bash
./doom_setup.sh
```
