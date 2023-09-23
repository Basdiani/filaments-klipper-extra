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

# Step 2: Link extension to Klipper and copy Filament.cfg to printer_data/config/
link_extension()
{
    echo "Linking [filaments] extension to Klipper..."
    ln -sf "${SRCDIR}/filaments.py" "${KLIPPER_PATH}/klippy/extras/filaments.py"
    
    # Copy Filament.cfg to printer_data/config/
    echo "Copying Filament.cfg to printer_data/config/"
    cp "${HOME}/filaments-klipper-extra/Filaments.cfg" "${HOME}/printer_data/config/"

     # Copy Filament.cfg to printer_data/config/
    echo "Copying Variables.cfg to printer_data/config/"
    cp "${HOME}/filaments-klipper-extra/variables.cfg" "${HOME}/printer_data/config/"
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

# Überprüfe, ob [include filaments.cfg] in ~/printer_data/config/printer.cfg vorhanden ist und füge sie hinzu, falls nicht vorhanden
check_include_line()
{
    local config_file="${HOME}/printer_data/config/printer.cfg"
    if grep -q -F '[include filaments.cfg]' "$config_file"; then
        echo "[CONFIG] 'include filaments.cfg' line found in $config_file"
    else
        echo "[CONFIG] 'include filaments.cfg' line not found in $config_file. Adding it..."
        echo "[include filaments.cfg]" >> "$config_file"
        echo "[CONFIG] 'include filaments.cfg' line has been added to $config_file"
    fi
}

# Überprüfe, ob [update_manager client Filaments] in ~/printer_data/config/moonraker.conf vorhanden ist und füge es hinzu, falls nicht vorhanden
check_update_manager()
{
    local config_file="${HOME}/printer_data/config/moonraker.conf"
    if grep -q -F '[update_manager client Filaments]' "$config_file"; then
        echo "[CONFIG] '[update_manager client Filaments]' section found!"
    else
        echo "[CONFIG] '[update_manager]' section not found. Adding it..."
        cat <<EOF >> "$config_file"
[update_manager client Filaments]
type: git_repo
path: ~/filaments-klipper-extra
primary_branch: mainline
origin: https://github.com/basdiani/filaments-klipper-extra.git
install_script: install.sh
managed_services: klipper
EOF
        echo "[CONFIG] '[update_manager client Filaments]' section has been added to $config_file"
    fi
}

# Erstelle ein Backup der Konfigurationsdatei printer.cfg als Printerbackup.cfg
create_config_backup()
{
    local config_file="${HOME}/printer_data/config/printer.cfg"
    local backup_file="${HOME}/printer_data/config/Printerbackup.cfg"

    if [ -f "$config_file" ]; then
        echo "[BACKUP] Creating backup of printer.cfg as Printerbackup.cfg..."
        cp "$config_file" "$backup_file"
        echo "[BACKUP] Backup created as $backup_file"
    else
        echo "[BACKUP] printer.cfg not found. No backup created."
    fi
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
create_config_backup
check_include_line
check_update_manager
link_extension
restart_klipper
ready
