# Variable containing the path to the tar.gz file
hcl_report=${args[hcl_report]}

# Extract the directory name from the file path
dir_name=$(basename "$hcl_report" .tar.gz)

# Check if the directory already exists
if [ -d "$dir_name" ]; then
    # Warn the user that the directory exists
    echo "Warning: Directory $dir_name already exists."

    # Ask for confirmation to remove the directory
    read -p "Do you want to remove the directory and unpack the file again? (y/n) " confirm
    if [ "$confirm" == "y" ] || [ "$confirm" == "Y" ]; then
        # Remove the directory
        rm -rf "$dir_name"

        # Create the directory
        mkdir "$dir_name"

        # Unpack the tar.gz file into the directory
        tar -xzf "$hcl_report" -C "$dir_name"

        echo "Directory removed and file $hcl_report unpacked."
    else
        echo "Operation aborted."
    fi
else
    # If the directory does not exist, create the directory
    mkdir "$dir_name"

    # If the directory does not exist, unpack the tar.gz file
    tar -xzf "$hcl_report" -C "$dir_name"

    echo "File $hcl_report unpacked."
fi

# Extract the Dasharo Version using the function
dasharo_version=$(extract_dasharo_version "$dir_name/logs/dmidecode.log")

# File containing the cpuinfo
cpuinfo_file="$dir_name/logs/cpuinfo.log"

# Extract the CPU Model
cpu_model=$(grep 'model name' "$cpuinfo_file" | head -1 | awk -F ': ' '{print $2}')

# Define the compatiblity information source, for now it is always Dasharo HCL
# Report
source="Dasharo HCL Report"

echo "| $cpu_model | $dasharo_version | $source |"
