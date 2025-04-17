#!/bin/bash
# Variable containing the path to the tar.gz file
# shellcheck disable=SC2154
hcl_report=${args[hcl_report]}
force=${args[--force]}
quiet=${args[--quiet]}

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

if [ -n "$dasharo_version" ]; then
  echo "| $cpu_model | $dasharo_version | $source |"
fi
