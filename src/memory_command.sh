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

if [ -z "$dasharo_version" ]; then
  if [ "$quiet" != "1" ]; then
    echo "ERROR: Vendor BIOS HCL" >&2
  fi
  exit 1
fi

# File containing the decode-dimms
decodedimms_file="$dir_name/logs/decode-dimms.log"

if [ ! -f "$decodedimms_file" ]; then
  if [ "$quiet" != "1" ]; then
    echo "ERROR: Decode DIMMs does not exist: $decodedimms_file" >&2
  fi
  exit 1
fi

file_contents=$(<"$decodedimms_file")

num_modules=$(grep -oP "(?<=Number of SDRAM DIMMs detected and decoded: )\d+" "$decodedimms_file" || true)
if [ -z "$num_modules" ]; then
  if [ "$quiet" != "1" ]; then
    echo "ERROR: No memory modules found" >&2
  fi
  exit 1
fi

if [ "$debug" ]; then
  echo "Memory modules: $num_modules"
fi

# Declare an associative array to act as the buffer
declare -A printed_entries

# Loop through each bank
for ((bank = 1; bank <= num_modules; bank++)); do

  module_manufacturer=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Module Manufacturer")
  part_num=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Part Number")
  size=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Size")
  speed=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Maximum module speed")

  case $num_modules in
  1)
    conf="&#10004/-/-"
    ;;
  2)
    conf="-/&#10004/-"
    ;;
  4)
    conf="-/-/&#10004"
    ;;
  *)
    conf="unknown"
    ;;
  esac

  entry=$"| $module_manufacturer | $part_num | $size | $speed | $conf | $dasharo_version | Dasharo HCL report |"

  if [ -n "${printed_entries[$entry]}" ]; then
    continue
  else
    printed_entries["$entry"]=1
    echo "$entry"
  fi

done

if [ "$update" ]; then

  if [ "$checkout_docs" ]; then
    # Update docs/ submodule
    git submodule update --init
  fi

  board_name=$(extract_board_name "$dir_name/logs/dmidecode.log")
  base_hcl_path="docs/docs/resources/hcl/memory/"
  hcl_file_path=""

  case "$board_name" in
  "PRO Z690-A DDR4"*)
    hcl_file_path="$base_hcl_path/pro-z690-a-ddr4.md"
    ;;
  "PRO Z690-A WIFI DDR4"*)
    hcl_file_path="$base_hcl_path/pro-z690-a-wifi-ddr4.md"
    ;;
  "PRO Z790-P DDR4"*)
    hcl_file_path="$base_hcl_path/pro-z790-p-ddr4.md"
    ;;
  "PRO Z790-P WIFI DDR4"*)
    hcl_file_path="$base_hcl_path/pro-z790-p-wifi-ddr4.md"
    ;;
  *)
    echo "Unknown or unsupported board: $board_name" >&2
    exit 1
    ;;
  esac

  if [ "$debug" ]; then
    echo "File with HCL table: $hcl_file_path" >&2
  fi
fi
