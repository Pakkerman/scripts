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


# 1. load all png files,
# 2. parse out the parameters
# 3. conver to jpg
# 4. set Exif.Photo.UserComment
# 5. maybe add set resource function in CLI parameters to set Civitai resources

# there is a way through civitai api, lookup model by hash and then get modelId and put it into the resource array in the last part of the user comment.

# remove file for testing
rm /Users/pakk/Downloads/testing/out.png 
rm /Users/pakk/Downloads/testing/out.jpg

# Process all PNG files in the directory
for png_file in "$directory"/*.png; do
    if [ -f "$png_file" ]; then
        # Get the user comment using exiftool
        user_comment=$(exiftool -b -UserComment "$png_file" | jq -r '.prompt, (.models[] | "<lora:\(.modelFileName) :\(.weight)>."), "Negative prompt:", .negativePrompt + ".", "Steps: " + (.steps | tostring) + ", Sampler: " + (.samplerName | tostring) + ", CFG scale: " + (.cfgScale | tostring) + ", Seed: " + (.seed | tostring) + ", Model: " + (.baseModel.modelFileName | tostring) + ", Clip Skip: " + (.clipSkip | tostring) + ", Civitai resources: [{}]" ')

        user_params=$(exiftool -Parameters "$png_file")

        # echo $user_params

        exiftool -all= /Users/pakk/Downloads/testing/1.png -o /Users/pakk/Downloads/testing/out.png 
        user_params_trimmed=$(echo "$user_params" | cut -d ':' -f 2-)
            
        # Use exiv2 to set the user comment
        exiv2 -M "set Parameters $user_params_trimmed" /Users/pakk/Downloads/testing/out.png 
        # exiv2 -M "set Exif.Photo.Parameters "123"" /Users/pakk/Downloads/testing/out.png 

        # exiv2 -M "add Exif.Photo.UserComment $user_comment" /Users/pakk/Downloads/testing/out.png 


        testing=$(exiftool -b -UserComment /Users/pakk/Downloads/testing/test.jpg)
        # echo $testing

        p=$(cat /Users/pakk/Downloads/testing/text.txt)

        exiftool -all= /Users/pakk/Downloads/testing/1.png -o /Users/pakk/Downloads/testing/out.jpg
        exiv2 -M "add Exif.Photo.UserComment $user_comment" /Users/pakk/Downloads/testing/out.jpg




        # echo "$user_comment"

        # Check if the user comment is empty
        # if [ -z "$user_comment" ]; then
        #     echo "UserComment not found in $png_file"
        # else
        #     ((counter++))
        #     echo -e "Processing $png_file ($counter / $total_pngs)\r"


            # user_params_trimmed=$(echo "$user_params" | cut -d ':' -f 2-)
            # echo "$user_params_trimmed"
            # exiv2 -M"set Exif.Photo.UserComment $user_params_trimmed" "$png_file"


            # Use exiv2 to set the user comment
            # exiv2 -M"set Exif.Photo.UserComment """ "$png_file"
        # fi
    fi
done


echo "Processing complete, Updated $total_pngs files."
