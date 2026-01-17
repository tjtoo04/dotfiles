#!/bin/bash

# Navigate to the directory where the script is located
cd "$(dirname "$0")" || exit

# Iterate over every directory in the current folder
for dir in */; do
    # Remove the trailing slash from the directory name
    dir=${dir%/}

    # Optional: Skip common non-config folders (like .git)
    if [[ "$dir" == ".git" ]]; then
        continue
    fi

    echo "stowing: $dir"

    # Run the stow command
    # -R: Recursive
    # -t ~: Target the home directory (default, but good to be explicit)
    stow -R "$dir"
done

echo "Done! All configurations have been symlinked."
