# Variable containing the path to the tar.gz file
hcl_report=${args[hcl_report]}
force=${args[--force]}
quiet=${args[--quiet]}

echo "ERROR: Not implemented. Waiting for https://github.com/Dasharo/dasharo-issues/issues/462."
exit 1
# Extract the directory name from the file path
dir_name=$(basename "$hcl_report" .tar.gz)

perform_extraction "$dir_name" "$force" "$hcl_report"

# Extract the Dasharo Version using the function
dasharo_version=$(extract_dasharo_version "$dir_name/logs/dmidecode.log")

if [ ! -n "$dasharo_version" ];then
	if [ "$quiet" != "1" ]; then
		echo "ERROR: Vendor BIOS HCL"
	fi
	exit 1
fi

