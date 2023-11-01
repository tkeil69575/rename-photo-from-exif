# Photo Renamer

## Description

**Photo Renamer** is a simple Bash script that renames JPEG files in a specified directory and its sub-directories based on their EXIF creation date and time. It also maintains a running number for files created on the same date.

## Usage

1. Clone this repository or download the `photo-renamer.sh` script to your local machine.

2. Open the script in a text editor to configure the settings:

   - `source_dir`: Set the source directory where your JPEG files are located.
   - `output_dir`: Set the directory where the renamed files will be placed.
   - `copy_dir`: Set the directory where the non-renameable files will be copied to.
   - `test_run`: Set to `true` to perform a dry run (show changes without renaming), or set to `false` to run the script for real.

3. Run the script using the following command:

   ```bash
   ./photo-renamer.sh


## Contributing

If you find issues with the script or have ideas for improvements, please feel free to open an issue or create a pull request. Your contributions are welcome!

## License

This project is licensed under the MIT License. See the LICENSE file for details.
