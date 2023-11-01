#!/bin/bash

# Author: Tina Keil
# Description: This script renames JPEG files in a specified directory 
# based on their exif creation date and time. It also maintains a running 
# number for files created on the same date and creates a text file with
# any files it could not rename.
# Date: 01.11.2023, License: MIT


# Set the source directory, output directory, and the test run flag
source_dir="."
output_dir="/home/tina/test-saved"
copy_dir="/home/tina/test-saved/non-renamable"
test_run=false #change to false to run script proper

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
    fi
    
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
    fi

    # Update the last processed date
    last_date="$compare_creation_date"
}

# function to copy non-renameable files to specified directory
copy_failed() {
    # Check if copy dir exists, otherwise create it
    if [ -e "$copy_dir" ]; then

      # Check if the file exists
      if [ -e "$failed_rename_file" ]; then
        # Prompt user
        read -p "Copy non-renameable files to a separate copy directory? (yes/no): " answer
      
        if [ "$answer" == "yes" ]; then
          # Loop through the files and copy each listed file
          while read -r file; do
            if [ -e "$file" ]; then
              if [ "$test_run" = false ]; then
                cp "$file" "$copy_dir"
              fi
              printf "\e[32m[Copied] $file\n\e[0m"
           else
              printf "[Error] File not found: $file\n"
            fi
          done < "$failed_rename_file"
          echo "Copying complete."
        else
          printf "[Error] No files were copied.\n"
        fi
      else
        printf "[Error] File $file_list not found.\n"
      fi
    
    else
      mkdir "$copy_dir"
      copy_failed
    fi
}

# function to delete non-renameable files from input directory
failed_delete() {
    # Check if the file exists
    if [ -e "$failed_rename_file" ]; then
      # Prompt user
      read -p "Delete all non-renameable files from the input folder? (yes/no): " answer

      if [ "$answer" == "yes" ]; then
        # Loop through the files and delete each listed file
        while read -r file; do
          if [ -e "$file" ]; then
            if [ "$test_run" = false ]; then
              rm "$file"
            fi
            printf "\e[31m[Deleted] $file\n\e[0m"
          else
            printf "[Error] File not found: $file\n"
          fi
        done < "$failed_rename_file"
        echo "Deletion complete."
      else
        printf "[Error] No files were deleted.\n"
      fi
    else
      printf "[Error] File $file_list not found.\n"
    fi
}

# Iterate through JPEG files in the specified directory and its subdirectories
find "$source_dir" -type f -iname '*.jpg' | sort | while read -r file; do
    # Get the creation date using exiftool
    creation_date=$(exiftool -d "%Y-%m-%d_%H%M%S" -CreateDate -s -s -s "$file")

    if [ -z "$creation_date" ]; then
        printf "\e[31m[Error] Could not retrieve creation date for $file. Skipping.\n\e[0m"
        echo "$file" >> "$failed_rename_file"
    else
        # If it's a test run, just show the changes without renaming
        if [ "$test_run" = true ]; then

            running_number=$((running_number + 1))
            printf "\e[34m[Test Run] Renamed $file to ${creation_date}_${running_number}.jpg\n\e[0m"

        else
            # Rename the file and handle errors
            rename_file "$file" "$creation_date"
        fi
    fi
done

# Count the number of lines in the failed_rename_file and assign it to temp_failed_rename_count
if [ -e "$failed_rename_file" ]; then
    if [ -s "$failed_rename_file" ]; then
        failed_rename_count=$(wc -l < "$failed_rename_file")
    else
        failed_rename_count=0
    fi
else
    failed_rename_count=0
fi

# Output the number of files that could not be renamed
if [ -e "$failed_rename_file" ]; then
    echo "------------------------"
    echo "Number of files that could not be renamed: $failed_rename_count"
    copy_failed
    failed_delete
fi
