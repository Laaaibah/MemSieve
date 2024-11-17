#include <iostream>
#include <thread>
#include <chrono>

using namespace std;

// Function to display a fancy welcome message
void displayWelcomeMessage() {
    // Fancy welcome message with ASCII art and colors
    cout << "\033[1;34m" << "********************************************" << "\033[0m" << endl;
    cout << "\033[1;32m" << "*        Welcome to the Password Parser        *" << "\033[0m" << endl;
    cout << "\033[1;33m" << "*          Choose an option below:            *" << "\033[0m" << endl;
    cout << "\033[1;34m" << "********************************************" << "\033[0m" << endl;
    cout << endl;
   
}

void executeOption(int choice) {
    if (choice == 1) {
        cout << "Executing memory dump script (newest.sh)..." << endl;
        // Replace this with the absolute path to new.sh if necessary
        int result = system("bash ./newest.sh");
        if (result != 0) {
            cerr << "Error: Failed to execute new.sh. Please check the script and environment." << endl;
        }
    }
    else if (choice == 2) {
    system("clear");
        cout << "Executing live memory script (project.py)..." << endl;
        // Replace this with the full path to lanzagne.py if necessary
        int result = system("sudo python /home/kali/DFPROJECT/Linux/project.py all");
        if (result != 0) {
            cerr << "Error: Failed to execute lanzagne.py. Please check the script and environment." << endl;
        }
    }
    else if (choice == 3) {
        cout << "Dump credentials using pamspy." << endl;

        int result = system("sudo bash ./pam.sh all");
        if (result != 0) {
            cerr << "Error: Failed to execute pam.sh. Please check the script and environment." << endl;
        }
    }
    else {
        cout << "Invalid choice! Please run the program again." << endl;
    }
}

void showOptions() {

    int choice;
    cout << "Do you want to fetch the password from?" << endl;
    cout << "1. Memory Dump" << endl;
    cout << "2. Live RAM Memory" << endl;
    cout << "3. Pamspy: Credentials Dumper for Linux (EXTRA)" << endl;

    cout << "Enter your choice: ";
    cin >> choice;

    executeOption(choice);
}

int main() {
    // Display fancy welcome message
    displayWelcomeMessage();

    // Wait for 3 seconds
    this_thread::sleep_for(chrono::seconds(3));

    // Show options to the user
    showOptions();

    return 0;
}
