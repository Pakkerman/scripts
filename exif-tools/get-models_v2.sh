#!/bin/bash

# this script is for getting model info from civitai api, using the hashes from the image
# https://github.com/civitai/civitai/wiki/REST-API-Reference#get-apiv1models-versionsby-hashhash

file="$1"
[ ! -f "$file" ] && echo "Invalid file" && exit 1
# if [ ! -f "$file" ]; then
#     echo "need a file path"
#     exit 1
# fi

# Get the directory path of the script
dir=$(dirname "$0")
filepath_json="$dir/cache/models.json"

# If no file or file is empty, create and put an empty object into it
if [ -z "$(jq '.' "$filepath_json")" ]; then
    mkdir "$dir/cache"
    echo "{}" > "$filepath_json"
fi


# getting hashes
user_comment=$(exiftool -b -UserComment "$file")
# get hashes from the file's user comment
json=$(echo "$user_comment" | jq -c '{
    "baseModel": {
        "hash": .baseModel.hash
    },
    "lora": [
        .models[] | {
            "modelFileName": .modelFileName,
            "label": .label,
            "hash": .hash,
            "weight": .weight
        }
    ]
}' | jq '.')

# (.baseModel.hash) : {"modelFileName":.baseModel.modelFileName},
out=$(echo "$user_comment" | jq 'reduce .models[] as $item ({}; . + {
  ($item.hash): {
    "modelFileName": ($item.modelFileName),
    "label": ($item.label)
    }
})' | jq '.')



echo $out
echo $out > log.json


# parse hashes into array
hash_values=($(echo "$json" | jq -r '.baseModel.hash, .lora[].hash'))
json_array=()

# build a object first with hash as keys

# test="{}"
# for hash in "${hash_values[@]}";do
#     test=$(echo "$test" | jq --arg key "$hash" --argjson "$json" '. + { ($key): {"field1" : 123 , "field2" : "some"}}' | jq '.')
# done

# echo "$test"

# echo "$test" | jq .> log.json


# for hash_value in "${hash_values[@]}"; do
#     model_info=$(echo $(cat "$filepath_json" | jq --arg key "$hash_value" '.[$key]' | jq '.'))
#     object=$model_info

#     # check if model is already in models.json
#     if [[ "$model_info" == "null" ]]; then
#         # fetch data from civitai.com
#         echo "fetching model info from civitai.com via hash"
#         response=$(curl -X GET "https://civitai.com/api/v1/model-versions/by-hash/$hash_value" | jq '.')
#         # parse response
#         object=$(echo "$response" | jq '{
#             "name": .model.name,
#             "version": .name,
#             "type" : .model.type,
#             "modelVersionId" : .id,
#         }' | jq -a '.')

#         model_info="$object"
#     fi

#     echo $(jq --arg key "$hash_value" --argjson value "$object" '. + { ($key): $value }' "$filepath_json") > "$filepath_json"

#     # json_array+=("$(echo $(cat "$filepath_json" | jq --arg key "$hash_value" '{"modelVersionId":.[$key].modelVersionId, "type": .[$key].type }' | jq '.'))")
#     json_array+=("$(echo $(cat "$filepath_json" | jq --arg key "$hash_value" '.[$key]'))")

# done



# echo "${json_array[@]}" | jq -s -c '.'



# civitai parsing needs type and id,
# [{"type":"checkpoint","modelVersionId":132828},
# {"type":"embed","weight":1,"modelVersionId":77169},
# {"type":"lora","weight":-1,"modelVersionId":121575},
# {"type":"lora","weight":0.4,"modelVersionId":71871},
# {"type":"lora","weight":0.2,"modelVersionId":100859},
# {"type":"lora","weight":-0.4,"modelVersionId":126824}]
