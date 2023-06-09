# lib/dasharo.sh

extract_dasharo_version() {
  local dmidecode_file="$1"
  local dasharo_line
  local dasharo_version
  
  dasharo_line=$(grep 'Version: Dasharo' "$dmidecode_file")
  dasharo_version=$(echo "$dasharo_line" | awk -F' ' '{print $4}')
  
  echo "$dasharo_version"
}

