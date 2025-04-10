#!/bin/bash

echo "=================================="
echo "      DOOM Install Menu"
echo "=================================="
echo "Choose which version of DOOM to install:"
echo "1. ASCII DOOM (runs in terminal, lower quality)"
echo "2. Framebuffer DOOM (fbDOOM - full graphics, no X11, requires sudo)"
read -p "Enter choice (1 or 2): " choice

if [[ $choice == "1" ]]; then
    echo "[+] Installing ASCII DOOM..."

    sudo apt update && sudo apt install -y git make gcc wget

    git clone https://github.com/wojciech-graj/doom-ascii.git ~/doom-ascii
    cd ~/doom-ascii/src || exit 1
    make

    cd ~/doom-ascii || exit 1
    wget -O doom1.wad https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad

    # Add ASCII DOOM shortcut
    if ! grep -q "alias asciidoom=" ~/.bashrc; then
        echo "alias asciidoom='~/doom-ascii/doom_ascii -iwad ~/doom-ascii/doom1.wad -scaling 2'" >> ~/.bashrc
        echo "[✓] Added 'asciidoom' shortcut to your terminal."
    fi

    echo "[✓] ASCII DOOM installed! Type 'asciidoom' in a new terminal to play."

elif [[ $choice == "2" ]]; then
    echo "[+] Installing fbDOOM (Framebuffer DOOM)..."

    sudo apt update && sudo apt install -y git libsdl1.2-dev gcc make unzip wget

    mkdir -p ~/doom/fbdoom && cd ~/doom/fbdoom || exit
    git clone https://github.com/ozkl/fbDOOM.git .
    make

    mkdir -p ~/doom/fbdoom/wads
    wget -O ~/doom/fbdoom/wads/doom1.wad https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad

    echo "[✓] fbDOOM installed! To run: cd ~/doom/fbdoom && sudo ./fbdoom"

else
    echo "[!] Invalid choice. Exiting."
    exit 1
fi
