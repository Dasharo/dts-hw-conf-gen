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

if [ ! -d logs  ]; then
    tar xvf $1 > /dev/null
fi

processor=$(grep "model name" logs/cpuinfo.log |head -1|cut -d":" -f2|sed 's/^ *//g')
manufacturer=$(grep "Manufacturer" logs/dmidecode.log |head -1|cut -d":" -f2|sed 's/^ *//g')
product_name=$(grep "Product Name" logs/dmidecode.log |head -1|cut -d":" -f2|sed 's/^ *//g')
# TBD: not used in optiplex
# sku_number=$(grep "SKU Number" logs/dmidecode.log |head -1|cut -d":" -f2|sed 's/^ *//g')
board_version=$(grep "Board Information" logs/dmidecode.log -A3|grep "Version"|head -1|cut -d":" -f2|sed 's/^ *//g')
flashrom_chipset=$(grep chipset logs/flashrom_read.log|head -1|cut -d\" -f2|sed 's/^ *//g')
lspci_chipset=$(grep chipset logs/flashrom_read.log|head -1|cut -d\" -f2|sed 's/^ *//g')

echo "Processor: $processor"
echo "Motherboard: $manufacturer $product_name $board_version"
echo "Chipset: $flashrom_chipset"
