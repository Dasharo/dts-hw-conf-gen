# lib/dasharo.sh

extract_dasharo_version() {
  local dmidecode_file="$1"
  local dasharo_line
  local dasharo_version
  
  dasharo_line=$(grep 'Version: Dasharo' "$dmidecode_file")
  dasharo_version=$(echo "$dasharo_line" | awk -F' ' '{print $4}')
  
  echo "$dasharo_version"
}

perform_extraction() {
    local dir_name=$1
    local force=$2
    local hcl_report=$3

    # Check if the directory already exists
    if [ -d "$dir_name" ]; then
        # Remove the directory if force flag is set or ask for confirmation
        if [ "$force" = "1" ]; then
            rm -rf "$dir_name"
        else
            echo "Warning: Directory $dir_name already exists."
            read -p "Do you want to remove the directory and unpack the file again? (y/n) " confirm
            if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                echo "Operation aborted."
                return 0
            fi
            rm -rf "$dir_name"
        fi
    fi

    # Create the directory
    mkdir -p "$dir_name"

    # Unpack the tar.gz file into the directory
    tar -xzf "$hcl_report" -C "$dir_name"
}

