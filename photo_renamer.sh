#!/bin/bash

source_dir="."
output_dir="/home/tina/test-saved"
test_run=true
failed_rename_file="./failed_rename.txt"

mkdir -p "$output_dir"

last_date=""
running_number=1

reset_running_number() {
    running_number=1
}

rename_file() {
    local file="$1"
    local creation_date="$2"
    local ext="${file##*.}"
    local new_name

    formatted_number=$(printf "%03d" "$running_number")
    new_name="${creation_date}_${formatted_number}.$ext"
    new_path="${output_dir}/${new_name}"

    running_number=$((running_number + 1))

    if cp "$file" "$new_path"; then
        printf "\e[33mRenamed $file to $new_path\n\e[0m"
    else
        echo -e "\e[31m[Error] Could not rename $file. Path and name saved in $failed_rename_file.\e[0m"
        echo "$file" > "$failed_rename_file"
    fi

    last_date="$creation_date"
}

find "$source_dir" -type f -iname '*.jpg' | sort | while read -r file; do
    exif_data=$(exiftool -d "%Y-%m-%d_%H%M%S" -CreateDate -s -s -s "$file")

    if [ -z "$exif_data" ]; then
        printf "\e[31m[Error] Could not retrieve creation date for $file. Skipping.\n\e[0m"
        echo "$file" > "$failed_rename_file"
    else
        if [ "$test_run" = true ]; then
            reset_running_number
            running_number=$((running_number + 1))
            printf "\e[34m[Test Run] Rename $file to ${exif_data}_${running_number}.jpg\n\e[0m"
        else
            rename_file "$file" "$exif_data"
        fi
    fi
done

failed_rename_count=$(wc -l < "$failed_rename_file")

echo "------------------------"
echo "Number of files that could not be renamed: $failed_rename_count"
