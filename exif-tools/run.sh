#!/bin/bash


[ -z "$1" ] && echo "Invalid directory" && exit 1

target="$1"



dir="$(dirname "$0")"
echo "$dir"

# rename files
"$dir"/renamePNGs.sh "$target"
# "$dir"/rename.sh "$target/"

# conver file to jpg
# echo "Converting to jpg via imagemagick"
# for png in "$target"/*.png; do
#     jpg="${png%.*}.jpg"
#     magick "$png" "$jpg"
#     echo "$(basename "$png") >>> $(basename "$jpg")"
# done
# echo

# # get model info
# for jpg in "$target"/*jpg; do
#     echo "$jpg"
# done

# # done
