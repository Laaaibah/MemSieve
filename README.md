# MemSieve (password parser - pwd dictionary from RAM)

## Overview

_MemSieve_ is a powerful forensic tool designed to extract credentials from memory dumps, live system RAM, and system configurations. Leveraging tools like Project.py and PAMSpy, it supports credential recovery from browsers, email clients, memory, and more. Built for ethical forensic investigations, this tool provides a wide range of utilities and customizable outputs to aid in cybersecurity and digital forensics.
The password for DFPROJECT.tar.gz.cpt is 123456

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Prerequisites and Dependencies](#prerequisites-and-dependencies)
   - [System Requirements](#system-requirements)
   - [Python Requirements](#python-requirements)
   - [External Libraries and Tools](#external-libraries-and-tools)
4. [Installation and Setup](#installation-and-setup)
   - [Clone the Repository](#clone-the-repository)
5. [Usage](#usage)
   - [Menu Options](#menu-options)
6. [PID Integration for Memory Analysis](#pid-integration-for-memory-analysis)
   - [Purpose](#purpose)
   - [PID Use Cases and Relevant Files](#pid-use-cases-and-relevant-files)
7. [Supported Categories](#supported-categories)
8. [Output Examples](#output-examples)
   - [Analyzing Memory Dump](#example-analyzing-memory-dump)
   - [Live RAM Parsing](#example-live-ram-parsing)
   - [Pamspy](#example-pamspy)
9. [Legal Disclaimer](#legal-disclaimer)
    

---

## Key Features

- _Memory Dump Analysis_: Extract passwords and sensitive data from pre-collected memory dumps.
- _Live RAM Parsing_: Real-time extraction of sensitive data from running processes using PID-based analysis.
- _PAM Credential Dumping_: Capture authentication secrets during login attempts using eBPF-based hooks.
- _Customizable Output_: Provides results in readable text, JSON, and structured formats.
- _Cross-Category Support_: Recover credentials from browsers, email clients, and system memory.

---

## Prerequisites and Dependencies

### System Requirements

- _Operating System_: Linux (Tested on Kali Linux)
- _Root Access_: Required for PAMSpy and some RAMParser functionalities.

### Python Requirements

Install Python (2.x) and the necessary dependencies:

```bash
sudo apt update
sudo apt install python2 python2-pip -y
pip2 install -r requirements.txt
```

### External Libraries and Tools

Run the commands below to setup volatility and python2:

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

For PAMSpy module:

```bash
openssh-server
sudo systemctl enable --now ssh
sudo systemctl status ssh
```

---

## Installation and Setup

### Clone the Repository

```bash
git clone https://github.com/Laaaibah/MemSieve.git
cd MemSieve
```

---

## Usage

Run the main project file to navigate through options:

```bash
g++ -o project project.cpp
./project
```

### Menu Options

1. _Memory Dump Analysis_:
   - Navigates to dump.sh.
2. _Live RAM Analysis_:
   - Navigates to RAMparser.
3. _PAMSpy_:
   - Navigates to pam.sh.

---

## PID Integration for Memory Analysis

### Purpose

PID (Process ID) is critical for memory analysis, enabling the tool to target specific processes for extracting sensitive data. The tool integrates PIDs in various workflows for enhanced precision and efficiency.

### PID Use Cases and Relevant Files

1. _homes.py_:

   - Checks read access to /etc/shadow to extract user credentials securely.
   

2. _write_output.py_:

   - Saves extracted data into a text file for further analysis and use.
   - Prints the retrieved data on console
     
3. _memorydump.py_:

   - Utilizes PIDs to identify processes (e.g., browsers) likely to contain sensitive data.
   - The MemWorker class interacts with memory regions of processes identified by their PIDs.
   - Searches memory dumps for credential patterns using predefined regex expressions.


---

## Supported Categories

The tool supports various categories for credential recovery:

- _Browsers_: Extract saved passwords from Firefox.
- _Email Clients_: Retrieve email credentials from Thunderbird.
- _Memory Dumps_: Extract credentials directly from memory dumps.
- _System Memory_: Analyze running processes for sensitive information.

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
