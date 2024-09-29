#!/bin/bash

# Function to check for errors after each command
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred in the last step. Exiting..."
        exit 1
    fi
}

# Function to update system and install packages
install_packages() {
    echo "Updating and upgrading the system..."
    sudo apt update && sudo apt upgrade -y
    check_error

    echo "Installing additional utilities and packages..."
    sudo apt install neofetch glances nvtop btop ddgr cool-retro-term kubuntu-restricted-extras ufw timeshift flatpak fonts-noto fonts-ubuntu fonts-dejavu-core aptitude gdebi synaptic -y
    check_error
}

# Function to configure touchpad settings
configure_touchpad() {
    echo "Configuring touchpad settings..."

    # Find the touchpad device ID
    TOUCHPAD_ID=$(xinput list | grep -i touchpad | grep -o 'id=[0-9]*' | cut -d'=' -f2)

    # Check if the touchpad was found
    if [ -z "$TOUCHPAD_ID" ]; then
        echo "No touchpad found. Skipping configuration."
        return
    fi

    # Enable "Touch to Click"
    xinput set-prop "$TOUCHPAD_ID" "libinput Tapping Enabled" 1
    check_error

    # Enable "Natural Scrolling"
    xinput set-prop "$TOUCHPAD_ID" "libinput Natural Scrolling Enabled" 1
    check_error

    echo "Touchpad settings configured."
}

# Function to set global theme to Breeze Dark
set_breeze_dark() {
    echo "Setting global theme to Breeze Dark..."
    lookandfeeltool -a org.kde.breezedark.desktop
}

# Function to remove LibreOffice
remove_libreoffice() {
    echo "Uninstalling LibreOffice..."
    sudo apt purge libreoffice* -y
    sudo apt autoremove -y
}

# Function to install OnlyOffice Desktop Editors
install_onlyoffice() {
    echo "Installing OnlyOffice Desktop Editors via Snap..."
    sudo snap install onlyoffice-desktopeditors
    check_error
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
}

# Function to enable the firewall (UFW)
enable_ufw() {
    echo "Enabling UFW firewall..."
    sudo ufw enable
}

# Function to install drivers
install_drivers() {
    echo "Automatically installing drivers..."
    sudo ubuntu-drivers autoinstall
    # Remove clear to keep the output visible
}

# Function to run system info and finish
finish_script() {
    echo "Cleaning up unused packages..."
    sudo apt-get autoclean
    check_error

    echo "Running system info (neofetch)..."
    neofetch

    echo "Script execution complete, have a nice day."
    echo "The system will reboot in 10 seconds."
    sleep 10
    sudo shutdown -r now
}

# Main script execution
set_breeze_dark
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
