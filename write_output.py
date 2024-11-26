import json
import logging
import socket
import sys
import os
from platform import uname
from time import gmtime, strftime
from collections import OrderedDict


class Bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OK = '\033[92m'
    WARNING = '\033[96m'
    FAIL = '\033[91m'
    TITLE = '\033[93m'
    ENDC = '\033[0m'

class StandardOutput: 
    def __init__(self):
        # Displays a welcome banner for the application.
        self.banner = '''
|====================================================================|
|                                                                    |
|                    The Password Parser Project                     |
|                                                                    |
|====================================================================|
'''
        # Tracks the number of passwords found and the list of unique passwords.
        self.nb_password_found = 0
        self.password_found = []
        self.quiet_mode = False

    def set_color(self, color=None):
        # Changes text color in the terminal based on the color name provided.
        colors = {
            'white': Bcolors.TITLE,
            'red': Bcolors.FAIL,
            'green': Bcolors.OK,
            'cyan': Bcolors.WARNING
        }
        sys.stdout.write(colors.get(color, Bcolors.ENDC))

    def do_print(self, message="", color=None):
        # Prints a message to the terminal with optional color formatting.
        if color:
            self.set_color(color)
        print(message)
        self.set_color()

    def print_logging(self, function, prefix='[!]', message='', color=None):
        # Logs a message with an optional prefix and color.
        if self.quiet_mode:  # Skip logging if quiet mode is enabled.
            return
        formatted_message = f'{prefix} {message}'
        if color:
            self.set_color(color)
        function(formatted_message)  # Call the provided logging function.
        self.set_color()

    def first_title(self):
        # Prints the welcome banner and system information.
        self.do_print(message=self.banner, color='white')
        python_banner = f'Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro} on {uname().system} {uname().release}: {uname().machine}'
        self.print_logging(logging.debug, prefix='[!]', message=python_banner, color='white')

    def print_title(self, title):
        # Prints the title for a section (e.g., the name of the software being processed).
        self.do_print(f'------------------- {title} passwords -----------------', color='white')

    def print_footer(self):
        # Prints the total number of passwords found after processing.
        footer = f'\n[+] {self.nb_password_found} passwords have been found.'
        self.do_print(footer, color='green')

    def print_output(self, software_name, pwd_found):
        # Processes and prints all the passwords found for a specific software.
        if pwd_found:
            self.print_title(software_name)

            # Remove duplicate entries from the found passwords.
            unique_passwords = [OrderedDict(item) for item in set(tuple(d.items()) for d in pwd_found)]

            for pwd in unique_passwords:
                # Find what type of credential was found (password, key, etc.).
                password_category = next(
                    (field for field in pwd if field.lower() in {"password", "key", "hash", "cmd"}), None
                )

                # Skip if no valid password or key is found.
                if not password_category or not pwd[password_category]:
                    continue

                # Count the password and store it if new.
                self.nb_password_found += 1
                password_value = pwd[password_category]
                if password_value not in self.password_found:
                    self.password_found.append(password_value)

                # Print the password and category.
                self.do_print(f'{password_category}: {password_value}', color='green')

            # Save the results to a file.
            self.checks_write(unique_passwords, software_name)
        else:
            # Print a message if no passwords were found.
            self.do_print("No passwords found", color='red')

    def checks_write(self, data, software_name):
        # Writes processed passwords to a file.
        file_name = f"{software_name}_passwords.txt"
        try:
            with open(file_name, 'w', encoding='utf-8') as f:
                for item in data:
                    f.write(json.dumps(item, indent=4) + "\n")
            self.do_print(f"[+] Passwords saved in: {file_name}", color='green')
        except Exception as e:
            self.do_print(f"Error saving passwords: {e}", color='red')


def write_in_file(result, output_format='all', folder_name='output', file_name='results'):
    """
    Write results to \ TXT files.
    """
    try:
        os.makedirs(folder_name, exist_ok=True)

        if output_format in {'txt', 'all'}:
            # Save results in a plain text file.
            txt_path = os.path.join(folder_name, file_name + '.txt')
            with open(txt_path, 'w', encoding='utf-8') as f:
                f.write("\n".join(map(str, result)))
            print(f'[+] File written: {txt_path}')
    except Exception as e:
        # Print an error message if saving fails.
        print(f'Error writing file: {e}')
