Dasharo Tool Suite HCL manager
------------------------------

DTS HCL manager is used to generate entries to Dasharo HCL
CPU/memory/mainboard/GPU documentation based on Dasharo HCL reports.

```bash
Usage: ./dts-hclmgr --help
```

As Dasharo HCL list maintainer your will typically deal with massive `zip` file
which contain all `*.tar.gz` reports. Assuming your zip file is in tmp you can
use following snippets:

## Dasharo CPU HCL generation

```bash
unzip -o /tmp/filename.zip && find . -name "platform_name_prefix*.tar.gz" -print0 | xargs -0 -n1 bash -c './dts-hclmgr cpu "$0"'
```

Example  `platform_name_prefix` for Dasharo supported platforms:
* `Micro-Star_International_Co.,_Ltd._MS-7D25`


