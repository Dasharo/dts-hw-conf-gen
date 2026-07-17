#!/bin/bash
# Variable containing the path to the tar.gz file
# shellcheck disable=SC2154
hcl_report=${args[hcl_report]}
force=${args[--force]}
quiet=${args[--quiet]}
update=${args[--update]}
checkout_docs=${args[--checkout - docs]}

# Extract the directory name from the file path
dir_name=$(basename "$hcl_report" .tar.gz)

perform_extraction "$dir_name" "$force" "$hcl_report"

# Extract the Dasharo Version using the function
dasharo_version=$(extract_dasharo_version "$dir_name/logs/dmidecode.log")

# File containing the cpuinfo
cpuinfo_file="$dir_name/logs/cpuinfo.log"

# Extract the CPU Model
cpu_model=$(grep 'model name' "$cpuinfo_file" | head -1 | awk -F ': ' '{print $2}')

# Define the compatibility information source, for now it is always Dasharo HCL
# Report
source="Dasharo HCL Report"

if [ "$update" ]; then

  if [ -z "$dasharo_version" ]; then
    log "ERROR: Vendor BIOS HCL" >&2
    exit 1
  fi

  if [ "$checkout_docs" ]; then
    # Update docs/ submodule
    git submodule update --init
  fi

  entry="| $cpu_model | $dasharo_version | $source |"

  board_name=$(extract_board_name "$dir_name/logs/dmidecode.log")
  hcl_file_path=$(get_hcl_file_path "$board_name" "cpu")

  [ "$debug" ] && echo "File with HCL table: $hcl_file_path"

  update_table "$hcl_file_path" "$entry"

else

  if [ -n "$dasharo_version" ]; then
    echo "| $cpu_model | $dasharo_version | $source |"
  fi

fi
