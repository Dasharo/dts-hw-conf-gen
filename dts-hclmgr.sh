#!/bin/bash

function usage {
    echo "Usage: $0 [dasharo_hcl_report]"
    echo -e "\t [dasharo_hcl_report] - Dasharo HCL report."
    exit 1
}

[ $# -ne 1 ] && echo "ERROR: invalid number of parameters" && usage && exit 1
[ -z "$1" ] && echo "ERROR: file name is null" && exit 1
hcl=$1

if [ ! -f $1  ]; then
        echo "ERROR: File not found!"
        exit 1
fi

# if [ ! -d logs  ]; then
    tar xf $1
# fi

dasharo_version=$(grep Version logs/dmidecode.log|grep Dasharo|cut -d" " -f4)

# CPU HCL
processor=$(grep "model name" logs/cpuinfo.log |head -1|cut -d":" -f2|sed 's/^ *//g')

# echo "| $processor | $dasharo_version | Dasharo HCL report |"

# Memory HCL
mod_manufacturers=$(grep -E "^Module Manufacturer" logs/decode-dimms.log|cut -d" " -f32-|uniq|sed 's/ /_/g')

for m in $mod_manufacturers;do
  if [ "$m" == "Patriot" ];then
    echo "=== DEBUG:"
    grep -E "^Module Manufacturer" logs/decode-dimms.log -A5 -B59
    echo "=== END OF DEBUG"
  fi
  part_numbers=$(grep -E "^Module Manufacturer" logs/decode-dimms.log -A5|grep "Part Number"|cut -d" " -f40-|uniq|sed 's/ /_/g')
  for p in $part_numbers;do
    part_num=$(echo $p|sed 's/_/ /g')
    speed=$(grep "$part_num" logs/decode-dimms.log -B59|grep "Maximum module speed"|cut -d" " -f32-|uniq)
    mem_type=$(grep "$part_num" logs/decode-dimms.log -B59|grep "Fundamental Memory type"|cut -d" " -f29-|uniq)
    size=$(grep "$part_num" logs/decode-dimms.log -B59|grep "Size"|cut -d" " -f46-|uniq)
    mod_man=$(echo $m|sed 's/_/ /g')
    mod_num=$(grep "$part_num" logs/decode-dimms.log|wc -l)
    case $mod_num in
      1)
        conf="&#10004/-/-";;
      2)
        conf="-/&#10004/-";;
      4)
        conf="-/-/&#10004";;
      *)
        conf="unknown"
    esac
    echo "| $mod_man | $part_num | $size | $mem_type | $speed | $conf | $dasharo_version | Dasharo HCL report |"
  done
done

# Mainboard HCL
manufacturer=$(grep "Manufacturer" logs/dmidecode.log |head -1|cut -d":" -f2|sed 's/^ *//g')
product_name=$(grep "Product Name" logs/dmidecode.log |head -1|cut -d":" -f2|sed 's/^ *//g')

# GPU HCL

# TBD: not used in optiplex
# sku_number=$(grep "SKU Number" logs/dmidecode.log |head -1|cut -d":" -f2|sed 's/^ *//g')
board_version=$(grep "Board Information" logs/dmidecode.log -A3|grep "Version"|head -1|cut -d":" -f2|sed 's/^ *//g')
flashrom_chipset=$(grep chipset logs/flashrom_read.log|head -1|cut -d\" -f2|sed 's/^ *//g')
lspci_chipset=$(grep chipset logs/flashrom_read.log|head -1|cut -d\" -f2|sed 's/^ *//g')

# echo "Motherboard: $manufacturer $product_name $board_version"
# echo "Chipset: $flashrom_chipset"
