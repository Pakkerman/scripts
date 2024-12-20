#!/bin/bash

[[ ! -d "$1" ]] && echo "Invalid directory" && exit 1
input_dir=$1

clear

function menu() {

	[[ ! -d "$1" ]] && echo "Invalid directory" && exit 1
	dir=$1

	while true; do

		echo -e "\n --- Generated Image Toolkit --- \n"
		echo -e "   Current target: $dir"
		echo -e "   Pick an operation:"
		echo -e "\t1) Convert Images"
		echo -e "\t2) Rename Images"
		echo -e "\t3) Post-porcess Images"
		echo -e "\t4) Sort Images"
		echo -e "\t5) Target subdirectory"
		echo -e "\t6) Add watermark"
		echo -e "\t7) Crop images to 1:2 ratio\n"

		read -rp "   Enter your choice (1-6): " option

		clear

		case $option in
		1)
			echo "Selected convert images"
			../exiftool_v2/convert_tensorart.sh "$dir"
			;;
		2)
			echo "Selected rename images"
			dir=$(./rename.sh "$dir")
			dir=$(echo "$dir" | tail -n 1)
			;;
		3)
			echo "Selected image processing"
			./image_processing.sh "$dir"
			;;
		4)
			echo "Sort images (with text-similarity)"
			read -rp "choose K: (default 3) " K
			bun /Users/pakk/Dropbox/Coding/text-similarity/src/index.ts -p "$dir" -c "${K:-3}"

			break
			;;
		5)
			subdirs=$(find "$input_dir" -type d)
			choice=$(echo "$subdirs" | fzf)

			clear

			echo -e "\n you have chosen $choice as the target"
			menu "$choice"

			break
			;;

		6)
			echo "Add watermark"
			./add_watermark.sh "$dir"
			;;

		7)
			echo "Crop to 1:2 ratio"
			./crop.sh "$dir"
			;;
		*)
			echo "Invalid option. Please enter a number between 1 and 5."
			;;
		esac

	done
}

menu "$input_dir"
