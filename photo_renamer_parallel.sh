#!/bin/bash

# Set the source directory, output directory, and the test run flag
source_dir="."
output_dir="/home/tina/test-saved"
test_run=true

# Create a text file to store the paths and names of files that couldn't be renamed
failed_rename_file="./failed_rename.txt"

# Initialize variables for tracking the last processed date and the running number
last_date=""
running_number=1

# Function to reset the running number when the date changes
reset_running_number() {
    running_number=1
}

# Function to rename files with the specified format and a running number
rename_file() {
    local file="$1"
    local creation_date="$2"
    local ext="${file##*.}" # Get the file extension
    compare_creation_date=$(exiftool -d "%Y-%m-%d" -CreateDate -s -s -s "$file")

    # Reset running number if the date has changed
    if [ "$compare_creation_date" != "$last_date" ]; then
        reset_running_number
    }

    # Format the running number with three digits
    formatted_number=$(printf "%03d" "$running_number")

    # Create the new file name with the running number
    new_name="${creation_date}_${formatted_number}.$ext"
    new_path="${output_dir}/${new_name}"

    # Increment the running number for the next file
    running_number=$((running_number + 1))

    # Attempt to rename the file
    if cp "$file" "$new_path"; then
        printf "\e[33mRenamed $file to $new_path\n\e[0m"
    else
        # Print the error message
        echo -e "\e[31m[Error] Could not rename $file. Path and name saved in $failed_rename_file.\e[0m"
        echo "$file" >> "$failed_rename_file"
    }

    # Update the last processed date
    last_date="$compare_creation_date"
}

# Iterate through JPEG files in the specified directory and its subdirectories using parallel processing
find "$source_dir" -type f -iname '*.jpg' | sort | parallel -j+0 'creation_date=$(exiftool -d "%Y-%m-%d_%H%M%S" -CreateDate -s -s -s "{}") && [ ! -z "$creation_date" ] && rename_file "{}" "$creation_date"'

# Count the number of lines in the failed_rename_file and assign it to temp_failed_rename_count
failed_rename_count=$(wc -l < "$failed_rename_file")

# Output the number of files that could not be renamed
echo "------------------------"
echo "Number of files that could not be renamed: $failed_rename_count"
