#!/bin/bash
KLIPPER_PATH="${HOME}/klipper"
SYSTEMDDIR="/etc/systemd/system"

# Step 1: Verify Klipper has been installed
# ... (Rest of your script)

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
# ... (Rest of your script)

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
link_extension
restart_klipper
ready

