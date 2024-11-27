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
    echo -e "    Memory Analysis Script - CTF Tools"
    echo -e "------------------------------------------${RESET}"
}

# Initial header display
display_header

mkdir -p /tmp/registry_dump

# Set variables
MEMORY_DUMP="OtterCTF.vmem"
PROFILE="Win7SP1x64"
PLUGIN_DIR="./plugin"
REGISTRY_DIR="/tmp/registry_dump"
OUTPUT_FILE="/tmp/registry_dump/extracted_strings.txt"
FOUND_FILE="$(dirname "$0")/found_exe.txt"  # Output file for matched keywords
FOUND_FILE_2="$(dirname "$0")/found_registry.txt"
DUMP_DIR="./"  # Directory for saving memory dumps
PROCESSES=("lsass.exe" "chrome.exe" "svchost.exe")  # Processes to search for

# Function to wait for a minimum of 5 seconds
function wait_for_completion() {
    echo -e "${BOLD}${YELLOW}Waiting for 10 seconds...${RESET}"
    sleep 10
}

# Section 0: Run hashdump and lsadump commands
echo -e "${BOLD}${YELLOW}Step 0: Running hashdump and lsadump...${RESET}"

# Run hashdump to extract password hashes
echo -e "${BOLD}${YELLOW}Running hashdump to gather password hashes...${RESET}"
hashdump_output=$(python2 vol.py -f $MEMORY_DUMP --profile=$PROFILE hashdump)
echo "$hashdump_output" > "$(dirname "$0")/hashdump_output.txt"  # Save to script's directory
echo "$hashdump_output"  # Display on console

if [[ -s "$(dirname "$0")/hashdump_output.txt" ]]; then
    echo -e "${GREEN}Hashdump completed successfully. Output saved to $(dirname "$0")/hashdump_output.txt${RESET}"
else
    echo -e "${RED}Failed to run hashdump or no data found.${RESET}"
fi


# Run lsadump to extract LSA secrets
echo -e "${BOLD}${YELLOW}Running lsadump to gather LSA secrets...${RESET}"
lsadump_output=$(python2 vol.py -f $MEMORY_DUMP --profile=$PROFILE lsadump)
echo "$lsadump_output" > "$(dirname "$0")/lsadump_output.txt"  # Save to script's directory
echo "$lsadump_output"  # Display on console

if [[ -s "$(dirname "$0")/lsadump_output.txt" ]]; then
    echo -e "${GREEN}Lsadump completed successfully. Output saved to $(dirname "$0")/lsadump_output.txt${RESET}"
else
    echo -e "${RED}Failed to run lsadump or no data found.${RESET}"
fi
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

# Section 1: Run pslist command and save output
echo -e "${BOLD}${YELLOW}Step 1: Running pslist to gather processes...${RESET}"
pslist_output=$(python2 vol.py --plugins=$PLUGIN_DIR -f $MEMORY_DUMP --profile=$PROFILE pslist)
echo "$pslist_output" > /tmp/pslist_output.txt
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

# Section 2: Extract PIDs for target processes
echo -e "${BOLD}${YELLOW}Step 2: Searching for target processes...${RESET}"
declare -A PID_MAP  # Store process names and their corresponding PIDs

for process in "${PROCESSES[@]}"; do
    pid=$(echo "$pslist_output" | grep -i "$process" | awk '{print $3}' | head -n 1)
    if [[ -n "$pid" ]]; then
        PID_MAP["$process"]=$pid
        echo -e "${GREEN}Found $process with PID $pid.${RESET}"
    else
        echo -e "${RED}Process $process not found.${RESET}"
    fi
done
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

# Section 3: Create memory dumps for the found PIDs
echo -e "${BOLD}${YELLOW}Step 3: Creating memory dumps...${RESET}"
for process in "${!PID_MAP[@]}"; do
    pid=${PID_MAP["$process"]}
    dump_file="${DUMP_DIR}${pid}.dmp"
    python2 vol.py -f $MEMORY_DUMP --profile=$PROFILE memdump -p$pid -D $DUMP_DIR
    if [[ -f "$dump_file" ]]; then
        echo -e "${GREEN}Memory dump created: $dump_file${RESET}"
    else
        echo -e "${RED}Failed to create memory dump for PID $pid ($process).${RESET}"
    fi
done
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

# Section 4: Extract usernames and passwords from memory dumps
echo -e "${BOLD}${YELLOW}Step 4: Extracting usernames and passwords from memory dumps...${RESET}"
> "$FOUND_FILE"  # Clear the file before writing
for process in "${!PID_MAP[@]}"; do
    pid=${PID_MAP["$process"]}
    dump_file="${DUMP_DIR}${pid}.dmp"
    if [[ -f "$dump_file" ]]; then
        echo -e "${BLUE}Analyzing dump: $dump_file${RESET}"
        strings "$dump_file" | grep -iE 'username|password' >> "$FOUND_FILE"
    else
        echo -e "${RED}Dump file not found: $dump_file${RESET}"
    fi
done
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

# Section 5: Finalize results
echo -e "${BOLD}${YELLOW}Step 5: Finalizing results...${RESET}"
if [[ -s "$FOUND_FILE" ]]; then
    echo -e "${GREEN}Sensitive keywords found. Results saved in $FOUND_FILE.${RESET}"
else
    echo -e "${RED}No sensitive keywords found in the memory dumps.${RESET}"
fi
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

# Section 6: Dump SAM registry only
echo -e "${BOLD}${YELLOW}Step 6: Dumping SAM registry...${RESET}"
# Dump only the SAM registry hive
python2 vol.py -f $MEMORY_DUMP --profile=$PROFILE dumpregistry --dump-dir=$REGISTRY_DIR --dump-hive SAM
wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header


# Section 7: Extracting strings from SAM registry file only...
echo -e "${BOLD}${YELLOW}Step 7: Extracting strings from SAM registry file...${RESET}"
> "$OUTPUT_FILE"  # Clear the output file before writing

# Only extract strings from the SAM registry file
sam_registry_file="$REGISTRY_DIR/registry.0xfffff8a0016d4010.SAM.reg"
if [[ -f "$sam_registry_file" ]]; then
    strings "$sam_registry_file" >> "$OUTPUT_FILE"
    echo -e "${BLUE}Extracted strings from $sam_registry_file.${RESET}"
else
    echo -e "${RED}SAM registry file $sam_registry_file does not exist.${RESET}"
fi

wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header


# Section 8: Searching for sensitive keywords in SAM registry strings...
echo -e "${BOLD}${YELLOW}Step 8: Searching for sensitive keywords in SAM registry strings...${RESET}"

# Search for sensitive keywords only in the extracted strings from the SAM registry
grep -iE 'username|password' "$OUTPUT_FILE" >> "$FOUND_FILE_2"

wait_for_completion  # Wait for 5 seconds minimum
display_header  # Clear screen and show header

echo -e "${BOLD}${GREEN}All tasks completed. Results saved in $FOUND_FILE_2.${RESET}"

# Section 9: Ask the user if they want to view the SAM registry file
echo -e "${BOLD}${YELLOW}Step 9: View the SAM registry file?${RESET}"
echo -e "Do you want to view the SAM registry file? (y/n)"
read view_choice

# If the user chooses yes, proceed to view the SAM file
if [[ "$view_choice" == "y" || "$view_choice" == "Y" ]]; then
    echo -e "${BOLD}${BLUE}You have selected the SAM registry file to view:${RESET}"
    echo "registry.0xfffff8a0016d4010.SAM.reg"

    # Ask the user if they want to view the file in hex or human-readable format
    echo -e "${BOLD}${BLUE}How would you like to view the SAM registry file?${RESET}"
    echo "1. Hex format"
    echo "2. Human-readable format"
    echo -n "Enter 1 for Hex or 2 for Human-readable: "
    read format_choice

    if [[ "$format_choice" == "1" ]]; then
        # Show the hex dump using xxd
        echo -e "${BOLD}${BLUE}Hex dump of SAM registry file:${RESET}"
        xxd -g 1 -c 32 "$REGISTRY_DIR/registry.0xfffff8a0016d4010.SAM.reg" | less
    elif [[ "$format_choice" == "2" ]]; then
        # Show human-readable strings using the 'strings' command
        echo -e "${BOLD}${BLUE}Human-readable strings from SAM registry file:${RESET}"
        strings "$REGISTRY_DIR/registry.0xfffff8a0016d4010.SAM.reg" | less
    else
        echo -e "${RED}Invalid choice. Exiting.${RESET}"
        exit 1
    fi

# If the user chooses no, exit the script
elif [[ "$view_choice" == "n" || "$view_choice" == "N" ]]; then
    echo -e "${GREEN}You chose not to view the SAM registry file. Exiting.${RESET}"
    exit 0

# If the user input is invalid
else
    echo -e "${RED}Invalid choice. Exiting.${RESET}"
    exit 1
fi
