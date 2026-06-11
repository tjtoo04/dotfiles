#!/bin/bash

# Function to display usage instructions
usage() {
    echo "Usage: $0 -n <mainClassName>"
    echo "Example: $0 -n com.example.MainApp"
    exit 1
}

# Initialize variables
MAIN_CLASS=""

# Parse command line options
while getopts ":n:" opt; do
    case ${opt} in
    n)
        MAIN_CLASS=$OPTARG
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        ;;
    :)
        echo "Error: Option -$OPTARG requires an argument." >&2
        usage
        ;;
    esac
done

# Shift off the options processed by getopts
shift $((OPTIND - 1))

# Check if the main class parameter was actually provided
if [ -z "$MAIN_CLASS" ]; then
    echo "Error: Missing required main class name." >&2
    usage
fi

echo "Compiling and running main class: $MAIN_CLASS..."

# Execute the Maven command
# -Dexec.mainClass defines the entry point for your application
mvn compile exec:java -Dexec.mainClass="$MAIN_CLASS"
