#!/bin/bash
KLIPPER_PATH="${HOME}/klipper"
SYSTEMDDIR="/etc/systemd/system"

# Step 1: Verify Klipper has been installed
check_klipper()
{
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
        
    elif [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper-1.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"

    elif [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper-2.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
        
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

# Step 2: Link extension to Klipper
link_extension()
{
    echo "Linking [filaments] extension to Klipper..."
    ln -sf "${SRCDIR}/filaments.py" "${KLIPPER_PATH}/klippy/extras/filaments.py"
    
    # Copy Filament.cfg to printer_data/config/
    echo "Copying Filament.cfg to printer_data/config/"
    cp "${HOME}/filaments-klipper-extra/Filament.cfg" "${HOME}/printer_data/config/"
}

# Step 4: Restarting Klipper
restart_klipper()
{
    echo "[POST-INSTALL] Restarting Klipper..."
    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        sudo systemctl restart klipper
    elif [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper-1.service')" ]; then
        sudo systemctl restart klipper-1
    elif [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper-2.service')" ]; then
        sudo systemctl restart klipper-2
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

# Ready function
ready()
{
    echo "[READY] YOU ARE READY "
}

# Helper functions
verify_ready()
{
    if [ "$EUID" -eq 0 ]; then
        echo "This script must not run as root"
        exit -1
    fi
}

# Force script to exit if an error occurs
set -e

# Find SRCDIR from the pathname of this script
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"/ && pwd )"

# Parse command line arguments
while getopts "k:" arg; do
    case $arg in
        k) KLIPPER_PATH=$OPTARG;;
    esac
done

# Run steps
verify_ready
link_extension
restart_klipper
ready  # Hier wird die ready-Funktion aufgerufen
