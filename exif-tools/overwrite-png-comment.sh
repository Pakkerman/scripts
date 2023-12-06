#!/bin/bash

# This Script will get Parameter from a png using $exiftool -Parameters <file>
# Then overwrite user comment with the same value, using exiv2,
# This is to get around that exiftool doesn't encode text correctly somehow, and exiv2 doesn't have cli to extract parameter, only API, which is in C

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    echo "exiftool is not installed. Please install it before running this script."
    exit 1
fi

if ! command -v exiv2 &> /dev/null; then
    echo "exiftool is not installed. Please install it before running this script."
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Get the directory path
directory="$1"

# Check if the directory exists
if [ ! -d "$directory" ]; then
    echo "Directory '$directory' not found."
    exit 1
fi

total_pngs=$(find "$directory" -type f -name "*.png" | wc -l | awk '{$1=$1};1')
counter=0

# Process all PNG files in the directory
for png_file in "$directory"/*.png; do
    if [ -f "$png_file" ]; then
        # Get the parameter using exiftool
        user_params=$(exiftool -Parameters "$png_file")

        # Check if the user comment is empty
        if [ -z "$user_params" ]; then
            echo "Parameter not found in $png_file"
        else
            ((counter++))
            echo -e "Processing $png_file ($counter / $total_pngs)\r"

            user_params_trimmed=$(echo "$user_params" | cut -d ':' -f 2-)
            
            # Use exiv2 to set the user comment
            exiv2 -M"set Exif.Photo.UserComment $user_parrams_trimmed" "$png_file"
        fi
    fi
done


echo "Processing complete, Updated $total_pngs files."
