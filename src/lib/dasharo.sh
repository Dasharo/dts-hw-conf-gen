#!/bin/bash
# lib/dasharo.sh
# shellcheck disable=SC2154

extract_dasharo_version() {
  local dmidecode_file="$1"
  local dasharo_line
  local dasharo_version

  dasharo_line=$(grep 'Version: Dasharo' "$dmidecode_file")
  dasharo_version=$(echo "$dasharo_line" | awk '{print $4}')

  echo "$dasharo_version"
}

extract_board_name() {
  local dmidecode_file="$1"
  local product_name

  product_name=$(awk '
  /^Handle .*DMI type 2,/ { in_base_board=1; next }
  /^Handle / { in_base_board=0 }
  in_base_board && /Product Name:/ {
      sub(/^.*Product Name:[[:space:]]*/, "", $0)
      print
      exit
  }' "$dmidecode_file")

  echo "$product_name"
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
  cleaned=$(echo "$restul_tmp" | awk '{$1=$1;print}')
  echo "$cleaned"
}

# Return the appropriate HCL file path
get_hcl_file_path() {
  local board_name="$1"
  local category="$2"
  local base_path="docs/docs/resources/hcl/$category"

  case "$board_name" in
  "PRO Z690-A WIFI DDR4"*) echo "$base_path/pro-z690-a-wifi-ddr4.md" ;;
  "PRO Z690-A WIFI"*) echo "$base_path/pro-z690-a-wifi.md" ;;
  "PRO Z790-P WIFI DDR4"*) echo "$base_path/pro-z790-p-wifi-ddr4.md" ;;
  "PRO Z790-P WIFI"*) echo "$base_path/pro-z790-p-wifi-ddr4.md" ;;
  *)
    echo "Error: Unknown or unsupported board: $board_name" >&2
    return 1
    ;;
  esac
}

# Update the table section in an HCL file
update_table() {
  local hcl_file_path="$1"
  shift
  local new_rows=("$@")

  [ "$debug" ] && echo "Updating table in: $hcl_file_path"

  # Extract static content and table
  head -n 4 "$hcl_file_path" >before.md

  awk '/<!--start-->/ { flag=1; skip=2; next }
       flag && skip > 0 { skip--; next }
       /<!--end-->/ { flag=0 }
       flag' "$hcl_file_path" >table.md

  {
    cat table.md
    for row in "${new_rows[@]}"; do
      printf "%s\n" "$row"
    done
  } | sort -u >table_sorted.md

  if [[ ! -s table_sorted.md ]]; then
    echo "Error: table_sorted.md is empty or missing" >&2
    return 1
  fi

  {
    cat before.md
    cat table_sorted.md
    echo "<!--end-->"
  } >"${hcl_file_path}.new"

  if ! cmp -s "$hcl_file_path" "${hcl_file_path}.new"; then
    echo "Modified: $hcl_file_path"
    diff_output=$(diff --color=always "$hcl_file_path" "${hcl_file_path}.new" || true)
    [[ -n "$diff_output" ]] && echo "Diff:" && echo "$diff_output" && echo "End Diff"
    echo "From #lines"
    cat "${hcl_file_path}" | wc
    echo "To #lines"
    cat "${hcl_file_path}.new" | wc
    mv "${hcl_file_path}.new" "$hcl_file_path"
  else
    echo "No changes made to $hcl_file_path"
    rm -f "${hcl_file_path}.new"
  fi

  rm -f before.md table.md table_sorted.md
}
