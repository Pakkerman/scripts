#! /bin/bash

# this script is for getting out the JSON part of the metadata

file="$1"

metadata=$(exiftool -b "$file")
start="${metadata#*\{}"             # get text starting from the first "{"
end="${start%\}*}"                  # until the last "}"
json_string="{$end}"

echo "$json_string" > log.txt

echo "$json_string"
