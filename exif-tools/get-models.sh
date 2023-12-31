#!/bin/bash

# this script is for getting model info from civitai api, using the hashes from the image
# https://github.com/civitai/civitai/wiki/REST-API-Reference#get-apiv1models-versionsby-hashhash

file="$1"
[ ! -f "$file" ] && echo "Invalid file" && exit 1

# Get the directory path of the script
dir=$(dirname "$0")
filepath_json="$dir/cache/models.json"

# If no file or file is empty, create and put an empty object into it
if [ -z "$(jq '.' "$filepath_json")" ]; then
    mkdir "$dir/cache"
    echo "{}" > "$filepath_json"
fi


# getting metadata from png
json_string=$("$dir"/get-comment.sh "$file")


# get hashes from metadata
json=$(echo "$json_string" | jq -c '{
    "baseModel": {
        "hash": .baseModel.hash
    },
    "lora": [
        .models[] | {
            "hash": .hash,
            "weight": .weight
        }
    ]
}' | jq '.')

# parse hashes into array
hash_values=($(echo "$json" | jq -r '.baseModel.hash, .lora[].hash'))
json_array=()


for hash_value in "${hash_values[@]}"; do
    model_info=$(echo $(cat "$filepath_json" | jq --arg key "$hash_value" '.[$key]' | jq '.'))
    object=$model_info
    
    # check if model is already in models.json
    if [ "$object" == "null" ]; then
        # fetch data from civitai.com
        response=$(curl -X GET "https://civitai.com/api/v1/model-versions/by-hash/$hash_value" | jq '.')
        object=$(echo "$response" | jq '{
            "name": .model.name,
            "version": .name,
            "type" : .model.type,
            "modelVersionId" : .id,
            "poi": .model.poi
        }' | jq -a '.')
    fi
    
    echo $(jq --arg key "$hash_value" --argjson value "$object" '. + { ($key): $value }' "$filepath_json") > "$filepath_json"
    json_array+=("$(echo $(cat "$filepath_json" | jq --arg key "$hash_value" '.[$key]'))")
    
    # json_array+=("$(echo $(cat "$filepath_json" | jq --arg key "$hash_value" '{"modelVersionId":.[$key].modelVersionId, "type": .[$key].type }' | jq '.'))")
    
done

echo "${json_array[@]}" | jq -s -c '.'



# civitai parsing needs type and id,
# [{"type":"checkpoint","modelVersionId":132828},
# {"type":"embed","weight":1,"modelVersionId":77169},
# {"type":"lora","weight":-1,"modelVersionId":121575},
# {"type":"lora","weight":0.4,"modelVersionId":71871},
# {"type":"lora","weight":0.2,"modelVersionId":100859},
# {"type":"lora","weight":-0.4,"modelVersionId":126824}]
