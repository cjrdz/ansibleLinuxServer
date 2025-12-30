#!/bin/bash
# -----------------------------------------------------------------
# Ansible Ubuntu Server Configuration Menu
# Simple menu with Normal Mode and Check Mode + Verbose Mode
# -----------------------------------------------------------------

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to project root directory
cd "$PROJECT_ROOT" || exit 1

# Source .env if it exists
if [ -f .env ]; then
    source .env
fi

# Define Playbook Paths
declare -A PLAYBOOKS=(
    [1]="playbooks/01_updates_patching.yml"
    [2]="playbooks/03_ufw_firewall.yml"
    [3]="playbooks/04_ssh_hardening.yml"
)

# Global variable to store Ansible command options
ANSIBLE_OPTIONS=""
MODE_DISPLAY="Normal Mode"

# Function to toggle execution mode
select_mode() {
    clear
    echo "---------------------------------------------------------------------"
    echo " 🎯 ANSIBLE EXECUTION MODE"
    echo "---------------------------------------------------------------------"
    echo " 1) Normal Mode (Apply changes)"
    echo " 2) Check Mode + Verbose (Dry run with detailed output)"
    echo "---------------------------------------------------------------------"
    read -rp "Select mode (1-2) [default: 1]: " mode_choice

    case $mode_choice in
        2)
            ANSIBLE_OPTIONS="--check -v"
            MODE_DISPLAY="Check Mode + Verbose"
            ;;
        *)
            ANSIBLE_OPTIONS=""
            MODE_DISPLAY="Normal Mode"
            ;;
    esac

    echo "✓ Mode set to: $MODE_DISPLAY"
    sleep 1
}

# Function to execute an Ansible Playbook
run_playbook() {
    local playbook_path=$1
    local playbook_name=$(basename "$playbook_path")

    echo ""
    echo "=========================================================="
    echo "▶️ Running: $playbook_name"
    echo "Mode: $MODE_DISPLAY"
    echo "=========================================================="

    ansible-playbook "$playbook_path" $ANSIBLE_OPTIONS

    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ SUCCESS: $playbook_name completed."
        if [[ "$ANSIBLE_OPTIONS" == *"--check"* ]]; then
            echo "   (Check mode - no changes were applied)"
        fi
    else
        echo ""
        echo "❌ ERROR: $playbook_name failed."
    fi
}

# Function to display the playbook menu
show_playbook_menu() {
    clear
    echo "---------------------------------------------------------------------"
    echo " ANSIBLE UBUNTU SERVER CONFIGURATION"
    echo " Mode: $MODE_DISPLAY"
    echo "---------------------------------------------------------------------"
    echo " 1) Updates & Patching"
    echo " 2) UFW Firewall"
    echo " 3) SSH Hardening"
    echo " 4) Change Mode"
    echo " 5) Exit"
    echo "---------------------------------------------------------------------"
}

# Main script loop
select_mode

while true; do
    show_playbook_menu
    read -rp "Select option (1-5): " choice

    case $choice in
        1|2|3)
            run_playbook "${PLAYBOOKS[$choice]}"
            read -rp "Press Enter to continue..."
            ;;
        4)
            select_mode
            ;;
        5)
            echo ""
            echo "Exiting. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            sleep 1
            ;;
    esac
done
