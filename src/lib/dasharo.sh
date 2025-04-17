#!/bin/bash
# lib/dasharo.sh

extract_dasharo_version() {
  local dmidecode_file="$1"
  local dasharo_line
  local dasharo_version

  dasharo_line=$(grep 'Version: Dasharo' "$dmidecode_file")
  dasharo_version=$(echo "$dasharo_line" | awk '{print $4}')

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
  if ! tar -xzf "$hcl_report" -C "$dir_name" >/dev/null 2>&1; then
    if [ "$quiet" != "1" ]; then
      echo "Error: Failed to extract archive: $hcl_report"
    fi
    exit 1
  fi
}

extract_lookup_string_from_decode_dimms() {
  local bank_number="$1"
  local file_contents="$2"
  local lookup_string="$3"

  # Find the line number of the given bank line
  bank_line_number=$(echo "$file_contents" | awk -v bank="$bank_number" '/bank/ && $3 == bank {print NR}')

  # Find the first occurrence of lookup string after the given bank line
  match_line=$(echo "$file_contents" | awk -v line="$bank_line_number" 'NR > line && /'"$lookup_string"'/ {print NR; exit}')

  lookup_string_extracted=$(echo "$file_contents" | awk "NR == $match_line")

  restul_tmp=$(echo "$lookup_string_extracted" | awk -F "$lookup_string" '{print $2}')

  # Trim leading and trailing whitespace
  echo $(echo "$restul_tmp" | awk '{$1=$1;print}')
}
