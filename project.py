#!/usr/bin/env python
# -- encoding: utf-8 --
# Import necessary modules and classes.
import sys
import time
from lazagne.config.write_output import StandardOutput, write_in_file
from lazagne.memorydump import MemoryDump  
from lazagne.homes import Homes 

# Initialize Standard Output directly
st = StandardOutput()  # Instantiate StandardOutput to manage output printing

def execute_modules():
    """
    Function to execute specific modules: homes.py, memorydump.py, and write_output.py.
    This function handles the main execution flow and output handling for the specified modules.
    """
    # Print the title banner at the beginning of the execution.
    st.first_title()

    start_time = time.time()  # Record the start time for performance tracking.

    # Execute Homes module
    st.print_title("Homes Module")  # Print a title for the Homes module output.
    homes = Homes()  # Instantiate the Homes class (assumed to be defined in lazagne.homes)
    homes_results = homes.run()  # Run the Homes module and store the results.
    st.print_output("Homes", homes_results)  # Print the results of the Homes module.

    # Execute Memory Dump module
    st.print_title("Memory Dump Module")  # Print a title for the Memory Dump module output.
    memory_dump = MemoryDump()  # Instantiate the MemoryDump class (assumed to be defined in lazagne.memorydump)
    memory_results = memory_dump.run()  # Run the Memory Dump module and store the results.
    st.print_output("Memory Dump", memory_results)  # Print the results of the Memory Dump module.

    # Write the results to an output file in 'all' format (both readable and JSON)
    write_in_file(st.password_found, output_format='all')  # Write passwords found to the output.

    # Print the execution footer and elapsed time after all modules have been executed.
    st.print_footer()  # Print the footer indicating the number of passwords found.
    elapsed_time = round(time.time() - start_time, 2)  # Calculate the elapsed time for the execution.
    st.do_print(f"\nExecution completed in {elapsed_time} seconds.", color='green')  # Print the elapsed time.

# Check if the script is being executed directly (not imported as a module).
if _name_ == '_main_':
    execute_modules()  # Call the function to execute the modules.
