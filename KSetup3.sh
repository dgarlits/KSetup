#!/bin/bash

# Function to check for errors after each command
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred in the last step. Exiting..."
        exit 1
    fi
}

# Function to install nala package manager
install_nala() {
    echo "Installing nala Package Manager"
    sudo apt update
    sudo apt install nala -y
    check_error
    echo "nala installed successfully."
}

# Function to update system and install packages using nala
install_packages() {
    echo "Updating and upgrading system with nala..."
    sudo nala update && sudo nala upgrade -y
    check_error

    echo "Installing additional utilities and packages..."
    sudo nala install neofetch glances nvtop btop ddgr cool-retro-term kubuntu-restricted-extras ufw timeshift flatpak fonts-noto fonts-ubuntu fonts-dejavu-core aptitude gdebi synaptic -y
    check_error
    echo "All packages installed successfully."
}

# Function to configure touchpad settings
configure_touchpad() {
    echo "Configuring Touchpad..."

    # Check if xinput is installed
    if ! command -v xinput &> /dev/null; then
        echo "xinput command not found. Please install it."
        return
    fi

    # Attempt to find the touchpad device ID
    TOUCHPAD_ID=$(xinput list | grep -i -E 'touchpad|synaptics|elan|trackpad' | grep -o 'id=[0-9]*' | cut -d'=' -f2)

    # Check if the touchpad was found
    if [ -z "$TOUCHPAD_ID" ]; then
        echo "No touchpad detected. Moving on..."
        return
    fi

    echo "Touchpad detected. Configuring settings..."
    echo "Enabling 'Touch to Click' and 'Natural Scrolling'..."

    sudo xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1
    check_error

    sudo xinput set-prop "$TOUCHPAD_ID" "libinput Natural Scrolling Enabled" 1
    check_error

    echo "Touchpad settings configured successfully."
}

# Function to set global theme to Breeze Dark
set_breeze_dark() {
    echo "Setting global theme to Breeze Dark..."
    lookandfeeltool -a org.kde.breezedark.desktop
    check_error
    echo "Breeze Dark theme applied."
}

# Function to remove LibreOffice
remove_libreoffice() {
    echo "Uninstalling LibreOffice..."
    sudo nala purge libreoffice* -y
    sudo nala autoremove -y
    check_error
    echo "LibreOffice uninstalled successfully."
}

# Function to install OnlyOffice Desktop Editors
install_onlyoffice() {
    echo "Installing OnlyOffice Desktop Editors..."
    sudo snap install onlyoffice-desktopeditors
    check_error
    echo "OnlyOffice installed successfully."
}

# Function to check if OnlyOffice is installed
check_onlyoffice() {
    if snap list | grep onlyoffice-desktopeditors &> /dev/null; then
        echo "OnlyOffice is installed correctly."
    else
        echo "OnlyOffice installation failed."
        exit 1
    fi
}

# Function to add Flathub repository
add_flatpak_repo() {
    echo "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    check_error
    echo "Flathub repository added."
}

# Function to enable the firewall (UFW)
enable_ufw() {
    echo "Enabling UFW firewall..."
    sudo ufw enable
    check_error
    echo "UFW firewall enabled."
}

# Function to install drivers
install_drivers() {
    echo "Installing system drivers..."
    sudo ubuntu-drivers autoinstall
    check_error
    echo "Drivers installed successfully."
}

# Function to run system info and finish
finish_script() {
    echo "Cleaning up unused packages..."
    sudo apt autoclean
    check_error

    echo "Displaying system info (neofetch)..."
    neofetch

    echo "Script execution complete. Rebooting in 10 seconds..."
    sleep 10
    sudo shutdown -r now
}

# Main script execution
set_breeze_dark
install_nala
configure_touchpad

echo "Please enter your sudo password:"
sudo -v

install_packages
remove_libreoffice
install_onlyoffice
check_onlyoffice
enable_ufw
add_flatpak_repo
install_drivers
finish_script
