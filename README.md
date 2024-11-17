
# MemSieve (password parser -pwd dictionary from RAM)

## Overview

**MemSieve** is a powerful forensic tool designed to extract credentials from memory dumps, live system RAM, and system configurations. Leveraging tools like Project.py and PAMSpy, it supports credential recovery from browsers, email clients, memory, and more. Built for ethical forensic investigations, this tool provides a wide range of utilities and customizable outputs to aid in cybersecurity and digital forensics.

---

## Key Features

- **Memory Dump Analysis**: Extract passwords and sensitive data from pre-collected memory dumps.
- **Live RAM Parsing**: Real-time extraction of sensitive data from running processes using PID-based analysis.
- **PAM Credential Dumping**: Capture authentication secrets during login attempts using eBPF-based hooks.
- **Customizable Output**: Provides results in readable text, JSON, and structured formats.
- **Cross-Category Support**: Recover credentials from browsers, email clients, and system memory.

---

## Table of Contents

---

## Prerequisites and Dependencies

### System Requirements

- **Operating System**: Linux (Tested on Kali Linux)
- **Root Access**: Required for PAMSpy and some RAMParser functionalities.

### Python Requirements

Install Python (2.x) and the necessary dependencies:

```bash
sudo apt update
sudo apt install python2 python2-pip -y
pip2 install -r requirements.txt
```

### External Libraries and Tools

Run the commands below to setup volatility and python2

```bash
sudo apt install -y build-essential git libdistorm3-dev yara libraw1394-11 libcapstone-dev capstone-tool tzdata
sudo apt install -y python2 python2.7-dev libpython2-dev 
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py 
sudo python2 get-pip.py 
sudo python2 -m pip install -U setuptools wheel
python2 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone 
sudo python2 -m pip install yara 
sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
git clone https://github.com/volatilityfoundation/volatility.git
cd volatility
sudo python2 setup.py install
```
For pamspy module
```bash
openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```



---

## Installation and Setup

### Clone the Repository

```bash
git clone https://github.com/your-repo/password-parser.git
cd password-parser
```

---

## Usage

Run the main project file to navigate through options:

```bash
g++ -o project project.cpp
./project
```

### Menu Options

1. **Memory Dump Analysis**:
   - Navigates to `dump.sh`.
2. **Live RAM Analysis**:
   - Navigates to `RAMparser`.
3. **PAMSpy**:
   - Navigates to `pam.sh`.

---

---

## PID Integration for Memory Analysis

### Purpose

PID (Process ID) is critical for memory analysis, enabling the tool to target specific processes for extracting sensitive data. The tool integrates PIDs in various workflows for enhanced precision and efficiency.

### PID Use Cases and Relevant Files

1. **PID Identification**:

   - **Files/Modules**: `MEMORYDUMP.py`, `MIMIPY.py`, `homes.py`
   - Scans active processes to identify targets such as browsers (`firefox`, `chrome`, `chromium`) and system components (`gnome-keyring-daemon`, `lightdm`).
   - Uses commands like `pslist` to retrieve running process details.

2. **Memory Dump with PID**:

   - **Files/Modules**: `MEMORYDUMP.py`, `MIMIPY.py`, `homes.py`
   - Dumps memory of identified processes using tools like `memdump`.
   - Dumps are analyzed for credentials with regex patterns targeting usernames and passwords.

3. **Process Memory Scanning**:

   - **Files/Modules**: `MEMORYDUMP.py`, `MIMIPY.py`
   - The `MemWorker` class interacts with memory regions of processes identified by their PIDs.
   - Searches for sensitive strings like plaintext credentials in browser or session memory.

4. **Retrieving Process Environment Variables**:

   - **Files/Modules**: `homes.py`
   - Uses the `get_linux_env()` function to fetch environment variables of specific processes by accessing `/proc/<pid>/environ`.
   - This is particularly useful for analyzing session-specific data and configurations.

5. **Memory Analysis with PID**:
   - **Files/Modules**: `MEMORYDUMP.py`, `MIMIPY.py`
   - Matches known markers near credentials in memory, validating sensitive data like login prompts or SSH sessions.

---

## Supported Categories

The tool supports various categories for credential recovery:

- **Browsers**: Extract saved passwords from Firefox.
- **Email Clients**: Retrieve email credentials from Thunderbird.
- **Memory Dumps**: Extract credentials directly from memory dumps.
- **System Memory**: Analyze running processes for sensitive information.

---

## Output Examples

### Example: Analyzing Memory Dump

![Image](https://github.com/Laaaibah/MemSieve/blob/main/lsa_hash.png)

### Example: Live RAM Parsing

- Retrieves passwords of users stored in memory.
![Image](https://github.com/Laaaibah/MemSieve/blob/main/usercred.png)

- Extracts saved passwords from applications like Firefox and Thunderbird (mail client).
![Image](https://github.com/Laaaibah/MemSieve/blob/main/firefox.png)



### Example: Pamspy

![Image](https://github.com/Laaaibah/MemSieve/blob/main/pam.png)

---

## Legal Disclaimer

This tool is intended for ethical and legal use only. Unauthorized usage of this tool may violate applicable laws and is strictly prohibited.

---
