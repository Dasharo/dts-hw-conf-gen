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
  log "ERROR: Vendor BIOS HCL" >&2
  exit 1
fi

# Files with logs for processing
decodedimms_file="$dir_name/logs/decode-dimms.log"
dmidecode_file="$dir_name/logs/dmidecode.log"

if [ ! -f "$decodedimms_file" ]; then
  log "Decode DIMMs does not exist: $decodedimms_file, checking for dmidecode..."
  if [ -s "$dmidecode_file" ]; then
    log "But dmidecode exists, proceeding."
  else
    log "ERROR: Neither $decodedimms_file nor $dmidecode_file suitable for processing."
    exit 1
  fi
fi

# Try to use decode-dimms first, since the file exists and isn't empty
if [ -s "$decodedimms_file" ]; then
  log "INFO: Trying decodedimms-based strategy."
  file_contents=$(<"$decodedimms_file")

  num_modules=$(grep -oP "(?<=Number of SDRAM DIMMs detected and decoded: )\d+" "$decodedimms_file" || true)
  if [ -z "$num_modules" ]; then
    log "ERROR: No memory modules found"
    exit 1
  fi

  if [ "$debug" ]; then
    echo "Memory modules: $num_modules"
  fi

  declare -a new_rows

  # Loop through each bank
  for ((bank = 1; bank <= num_modules; bank++)); do

    module_manufacturer=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Module Manufacturer")
    part_num=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Part Number")
    size=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Size")
    speed=$(extract_lookup_string_from_decode_dimms $bank "$file_contents" "Maximum module speed")

    generated_entry=$(generate_memory_table_entry "$num_modules" \
      "$module_manufacturer" "$part_num" "$size" "$speed" "$dasharo_version")
    new_rows+=("$generated_entry")

  done
fi
if [ -s "$dmidecode_file" ]; then
  log "INFO: Trying dmidecode-based strategy."

  # Read the file, but remove all the occurrences of "Configured Memory Speed"
  # dmidecode entry, otherwise it could cause false positives when searching
  # for "Speed" entry:
  file_contents=$(sed '/Configured Memory Speed/d' "$dmidecode_file")
  memory_handles=($(grep -o "Handle 0x...., DMI type 17" "$dmidecode_file" | grep -o "0x...." || true))
  num_modules=${#memory_handles[@]}

  if [ -z "$num_modules" ]; then
    log "ERROR: No memory modules found" >&2
    exit 1
  fi

  if [ "$debug" ]; then
    echo "DEBUG: Reading file ${dmidecode_file}..."
    echo "DEBUG: Memory modules: $num_modules"
    echo "DEBUG: Memory handles: ${memory_handles[*]}"
  fi

  declare -a new_rows

  for handle in "${memory_handles[@]}"; do

    module_manufacturer=$(extract_lookup_string_from_dmidecode $handle "$file_contents" "Manufacturer:")
    part_num=$(extract_lookup_string_from_dmidecode $handle "$file_contents" "Part Number:")
    size=$(extract_lookup_string_from_dmidecode $handle "$file_contents" "Size:")
    # See the comment on "Configured Memory Speed" from earlier - normally that
    # pattern would be matched, but here it has already been removed.
    speed=$(extract_lookup_string_from_dmidecode $handle "$file_contents" "Speed:")

    generated_entry=$(generate_memory_table_entry "$num_modules" \
      "$module_manufacturer" "$part_num" "$size" "$speed" "$dasharo_version")
    new_rows+=("$generated_entry")

  done
fi

if [ "$update" ]; then

  if [ "$checkout_docs" ]; then
    # Update docs/ submodule
    git submodule update --init
  fi

  board_name=$(extract_board_name "$dir_name/logs/dmidecode.log")
  hcl_file_path=$(get_hcl_file_path "$board_name" "memory")

  [ "$debug" ] && echo "File with HCL table: $hcl_file_path"

  update_table "$hcl_file_path" "${new_rows[@]}"

fi
