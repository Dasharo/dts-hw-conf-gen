#!/bin/bash
# Variable containing the path to the tar.gz file
# shellcheck disable=SC2154
hcl_report=${args[hcl_report]}
force=${args[--force]}
quiet=${args[--quiet]}

# echo "ERROR: Not implemented. Waiting for https://github.com/Dasharo/dasharo-issues/issues/462."
# exit 1
# Extract the directory name from the file path
dir_name=$(basename "$hcl_report" .tar.gz)

perform_extraction "$dir_name" "$force" "$hcl_report"

# Extract the Dasharo Version using the function
dasharo_version=$(extract_dasharo_version "$dir_name/logs/dmidecode.log")

if [ ! -n "$dasharo_version" ]; then
  if [ "$quiet" != "1" ]; then
    echo "ERROR: Vendor BIOS HCL"
  fi
  exit 1
fi

# File containing the lspci
lspci_file="$dir_name/logs/lspci.log"

if [ ! -f "$lspci_file" ]; then
  if [ "$quiet" != "1" ]; then
    echo "ERROR: lspci does not extist: $lspci_file"
  fi
  exit 1
fi

# Count how many VGA controllers are detected
gpu_count=$(grep "VGA compatible controller \[0300\]" "$lspci_file" | wc -l)
vga_entries=$(grep "VGA compatible controller \[0300\]" "$lspci_file")

# Report if more than one VGA controller is found
if [ "$gpu_count" -gt 1 ]; then
  mgt="Yes ($gpu_count)"
else
  mgt="No"
fi

# Process each VGA entry separately
echo "$vga_entries" | while IFS= read -r entry; do
  # Extract the GPU Vendor
  gpu_vendor=$(echo "$entry" | awk -F ': ' '{print $2}' | cut -d'[' -f1 | tr -d '\n')

  # Check if the gpu_vendor starts with "NVIDIA"
  if [[ "$gpu_vendor" == NVIDIA* ]]; then
    # Extract the code name (third word in the string)
    gpu_code_name=$(echo "$gpu_vendor" | awk '{print $3}')
    # Extract GPU model (text inside the second square brackets)
    gpu_model=$(echo "$entry" | awk -F'[][]' '{print $4}')
    gpu_vendor="NVIDIA Corporation"
  elif [[ "$gpu_vendor" == "Intel Corporation AlderLake-S GT1 " ]]; then
    if [ "$quiet" != "1" ]; then
      echo "ERROR: This is iGPU: ->$entry<-, we don't have to report it"
    fi
    # This is iGPU, we don't have to report it
    exit 1
  elif [[ "$gpu_vendor" == "Intel Corporation Device " ]]; then
    if [ "$quiet" != "1" ]; then
      echo "ERROR: This is iGPU: ->$entry<-, we don't have to report it"
    fi
    # This is integrated GPU, we don't have to report it
    exit 1
  elif [[ "$gpu_vendor" == "Advanced Micro Devices, Inc. " ]]; then
    gpu_code_name=$(echo "$entry" | awk -F '[:[]' '{print $5}' | sed 's/^\s*//g')
    # Extract Model e.g.(Radeon RX 5600 OEM/5600 XT / 5700/5700 XT)
    gpu_model=$(echo "$entry" | awk -F '[:[]' '{print $6}' | sed 's/^\s*//g')
    gpu_vendor="Advanced Micro Devices, Inc."
  else
    echo $entry
  fi

  pcid=$(echo "$entry" | grep -oP '\[\K[0-9a-f]{4}:[0-9a-f]{4}')

  echo "| $gpu_vendor | $gpu_code_name | $gpu_model | $pcid | $mgt | Dasharo HCL report |"

done
