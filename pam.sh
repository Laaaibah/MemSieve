#!/bin/bash

# Color codes for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# Display header function
function display_header() {
    clear  # Clear screen for fresh output
    echo -e "${BOLD}${GREEN}------------------------------------------"
    echo -e "    PAM Event Capture and Analysis"
    echo -e "------------------------------------------${RESET}"
}

# Initial header display
display_header

# Ensure the script is being run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root. Please run with sudo.${RESET}"
    exit 1
fi

# Step 3: Run pamspy to capture PAM-related events
echo -e "${BOLD}${YELLOW}Step 3: Running pamspy to capture PAM-related events...${RESET}"

# Run pamspy
PAM_PATH=$(sudo /usr/sbin/ldconfig -p | grep libpam.so | cut -d ' ' -f4)
if [ -z "$PAM_PATH" ]; then
    echo -e "${RED}Error: libpam.so not found on this system.${RESET}"
    exit 1
fi

# Hardcoded output heading
echo -e "${BLUE}Capturing PAM events from ${PAM_PATH}...${RESET}"
echo -e "${BOLD}${GREEN}PID${RESET}   | ${BOLD}${BLUE}PROCESS${RESET}            | ${BOLD}${YELLOW}USERNAME${RESET}   | ${BOLD}${RED}PASSWORD${RESET}"

# Assuming pamspy output is like: PID | Process            | Username   | Password
# Example:
# 60923  | sshd-session     | laiba      | laiba

# Run pamspy and format output
sudo ./pamspy -p "$PAM_PATH" | tee /tmp/pamspy_output.txt | while read -r line; do
    # Check if the line contains relevant information (pid, process, username, password)
    if echo "$line" | grep -q -E "^[0-9]+"; then
        # Extract fields: PID, Process, Username, Password
        PID=$(echo "$line" | awk '{print $1}')
        PROCESS=$(echo "$line" | awk '{print $2}')
        USERNAME=$(echo "$line" | awk '{print $3}')
        PASSWORD=$(echo "$line" | awk '{print $4}')

        # Format and align the output with fixed-width columns
        printf "%-9s | %-15s | %-20s | %-10s\n" "$PID" "$PROCESS" "$USERNAME" "$PASSWORD"
    fi
done

# Wait for completion
echo -e "${BOLD}${GREEN}PAM event capture completed.${RESET}"

# End of script

