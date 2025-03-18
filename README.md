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

1. Download the `dasharo_hcl_reports` folder available on [Cloud](https://cloud.3mdeb.com/index.php/f/467774) 
and unzip it.
2. Clone the `dts-hw-conf-gen` repository.
3. Copy the `dts-hclmgr` file from the cloned repository.
4. Move the copied file to the downloaded `dasharo_hcl_reports` folder.
5. While inside this folder, run the following command:

```bash
find . -name "Micro-Star_International_Co.,_Ltd._MS-7E06*.tar.gz" -print0 | xargs -0 -n1 bash -c './dts-hclmgr cpu "$0"'
```

The command will also extract the specified files into the folder.

6. Expected output:
```bash
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i7-12700K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i7-12700K | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12400 | v1.0.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.1.0 | Dasharo HCL Report |
| 12th Gen Intel(R) Core(TM) i5-12600K | v1.1.0 | Dasharo HCL Report |
```

7. Copy the generated list to a sheet and sort it. 
8. Delete duplicated entries.
9. Check which entries are missing in [Dasharo HCL
   Documentation](https://docs.dasharo.com/unified/msi/hcl/) and update the list
   accordingly.
10. Update date of the hcl report in the documentation.

Example  `platform_name_prefix` for Dasharo supported platforms:

* `ASUS_KGPE-D16`
* `Dell_Inc._OptiPlex_9010`
* `Emulation_QEMU_x86_q35_ich9`
* `Micro-Star_International_Co.,_Ltd._MS-7D25` (MSI PRO Z690)
* `Micro-Star_International_Co.,_Ltd._MS-7E06` (MSI PRO Z790-P WIFI)
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
