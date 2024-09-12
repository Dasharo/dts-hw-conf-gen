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

* `ASUS_KGPE-D16`
* `Dell_Inc._OptiPlex_9010`
* `Emulation_QEMU_x86_q35_ich9`
* `Micro-Star_International_Co.,_Ltd._MS-7D25`
* `Micro-Star_International_Co.,_Ltd._MS-7E06`
* `Notebook_NS50_70MU`
* `Notebook_NS5x_NS7xPU`
* `Notebook_NV4XMB,ME,MZ`
* `Notebook_NV4xPZ`
* `Notebook_V54x_6x_TU`
* `Notebook_V5xTNC_TND_TNE`
* `PC_Engines_apu2`
* `PC_Engines_apu6`
* `Protectli_VP2420`
* `Protectli_VP4630`
* `Protectli_VP4670`
* `Protectli_VP6670`
