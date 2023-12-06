#!/bin/bash

directory="$1"
if [ ! -d "$directory" ]; then
    echo "Directory '$directory' not found."
    exit 1
fi

echo "Renaming all files"
dir="$(dirname "$0")"
# rename files
"$dir"/rename.sh "$directory/"



echo "Process all png files"
count=0
for png in "$directory"/*.png; do
    if [ -f "$png" ]; then
        
        # convert to jpg
        jpg="${png%.*}.jpg"
        magick "$png" "$jpg"
        
        # Civitai.com API, model lookup
        models=$("$dir"/get-models.sh "$png")
        echo "$models"
        
        
        user_comment=$(
            exiftool -b -UserComment "$png" |
            jq -r '
            .prompt, (.models[] | "<lora:\(.modelFileName) :\(.weight)>."),
            "Negative prompt:", .negativePrompt + ".",
            "Steps: " + (.steps | tostring) +
            ", Sampler: " + (.samplerName | tostring) +
            ", CFG scale: " + (.cfgScale | tostring) +
            ", Seed: " + (.seed | tostring) +
            ", Model: " + (.baseModel.modelFileName | tostring) +
            ", Clip Skip: " + (.clipSkip | tostring) + ", Civitai resources:"
        ')
        
        # set user comment
        exiv2 -M "set Exif.Photo.UserComment $user_comment $models" "$jpg"
        
        # rm -f "$png"
        ((count++))
    fi
done

total_pngs=$(find "$directory" -type f -name "*.png" | wc -l | awk '{$1=$1};1')
echo "Processing complete, Updated $total_pngs files."


