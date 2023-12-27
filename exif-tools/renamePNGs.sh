#! /bin/bash
### This script is aimed to make rename file in a single click
### Script will take a directory and name all files inside in order from 0000 to 9999

path="$1"
echo "$path"
cd "$path" || exit 1

[ $? -ne 0 ] && echo "The user canceled the dialog or the script returned an empty value." && exit 1


read -rp "Rename files in \"${PWD##*/}\"? (y/n)" confirm
case "$confirm" in
    [yY] | [yY][eE][sS] | "" ) echo "Continuing (y)" ;;
    [nN] | [nN][oO]) echo "Canceled (n)" ; exit ;;
    *) echo "Invalid input."; exit ;;
esac


read -rp "Set prefix (press enter to use folder as the prefix):  " prefix
case "$prefix" in
    "") fileprefix=${PWD##*/}- ;;
    *) fileprefix="$prefix-" ;;
esac

echo "Using \"$fileprefix\" as prefix..."


# rename to temp else to prevent conflict
files=("$path"/*.png)
idx=0
for file in "${files[@]}"; do
    [ $idx -lt 10 ] && fileIdx=0$idx || fileIdx=$idx
    mv "$file" "temp-$fileIdx.png"
    ((idx++))
done

# prepend prefix and rename files
files=("$path"/*.png)
counter=1
for file in "${files[@]}"; do
    FILENAME=$(printf "%04d\n" $counter)
    extension="${file##*.}"
    echo "$(basename "$file") >>> $fileprefix$FILENAME.$extension"
    mv -f "$file" "$fileprefix$FILENAME.$extension"
    
    ((counter++))
done

echo "Renamed ${#files[@]} files."
echo




