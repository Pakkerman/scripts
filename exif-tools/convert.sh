#!/bin/bash

[ ! -d "$1" ] && echo "Directory not found." && exit 1

directory="$1"
dir="$(dirname "$0")"

# rename files
echo "Renaming all files"
"$dir"/renamePNGs.sh "$directory/"


echo "Generate new metadata..."
files=("$directory"/*.png)
count=1
for png in "${files[@]}"; do
    [ ! -f "$png" ] && continue
    
    # convert to jpg and crop bottom 30px to get rid of the watermark
    jpg="${png%.*}.jpg"
    convert "$png" -gravity South -chop 0x30 -quality 95 "$jpg"
    # convert "$png" -quality 95 "$jpg"
    
    # Civitai.com API, model lookup
    models=$("$dir"/get-models.sh "$png")
    echo "processing $(basename "$png") ($count / ${#files[@]})"
    echo -e "$models" | jq -r '.[] | (.type | select(. == "Checkpoint") |= "CKPT") + "\t: " + .name' | awk '{ if (length($0) > 45) print subs tr($0, 1, 45) "..."; else print }'
    echo "-"
    
    # get comment
    json_string=$("$dir"/get-comment.sh "$png")
    
    # parse comment
    user_comment=$(
        echo "$json_string" |\
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
    parsedModelInfo=$(echo "$models" | jq -r -c '[.[] | {type, modelVersionId}]')
    exiv2 -M "set Exif.Photo.UserComment $user_comment $parsedModelInfo" "$jpg"
    
    ((count++))
done

echo "Processing complete, Updated ${#files[@]} files."


# move jpg to another directory
jpgs=("$directory"/*.jpg)
mkdir "$directory"/jpg
for jpg in "${jpgs[@]}"; do
    mv "$jpg" "$directory"/jpg
done




