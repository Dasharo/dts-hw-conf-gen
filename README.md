# Dasharo Tool Suite HCL manager

---

DTS HCL manager is used to generate entries to Dasharo HCL
CPU/memory/mainboard/GPU documentation based on Dasharo HCL reports.

```bash
Usage: ./dts-hclmgr --help
```

As Dasharo HCL list maintainer your will typically deal with massive `zip` file
which contain all `*.tar.gz` reports. Assuming your zip file is in tmp you can
use following snippets:

## Dasharo CPU HCL generation

1. Download the `dasharo_hcl_reports` folder from 3mdeb's Cloud and unzip it.
2. Clone the `dts-hw-conf-gen` repository.
3. Copy the `dts-hclmgr` file from the cloned repository to the
   `dasharo_hcl_reports` folder.
4. While inside this folder, run the following command:

    ```bash
    find . -name "Micro-Star_International_Co.,_Ltd._MS-7E06*.tar.gz" -print0 | xargs -0 -n1 bash -c './dts-hclmgr cpu "$0"'
    ```

    The command will also extract the specified files into the folder.

5. Expected output:

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

6. Copy the generated list to a sheet and sort it.
7. Delete duplicated entries.
8. Check which entries are missing in [Dasharo HCL
   Documentation](https://docs.dasharo.com/unified/msi/hcl/) and update the list
   accordingly.
9. Update date of the hcl report in the documentation.

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

## Dasharo Memory HCL generation

1. Do the same preparations as for CPU HCL.

2. Example command:

    ```bash
    find . -name "Micro-Star_International_Co.,_Ltd.*.tar.gz" -print0 | xargs -0 -n1 bash -c './dts-hclmgr --force  memory "$0"'
    ```

  Note: it is possible to avoid error messages by using the `-q` (`--quiet`)
  option.

### The "Update" option

The new feature allows the memory report to automatically update the hcl report
tables. The changes are not committed though, leaving the option to review and
fix the final result.

The option is `-u` (`--update`)

Example usage:

1. Command:

    ```bash
    find . -name "Micro-Star_International_Co.,_Ltd.*.tar.gz" -print0 | xargs -0 -n1 bash -c './dts-hclmgr --quiet --force --update  memory "$0"'
    ```

2. Snippet of output:

    ```bash
    Modified: docs/docs/resources/hcl/memory/pro-z690-a-wifi-ddr4.md
    Diff:
    20a21
    > | Kingston | KF3200C16D4/32GX | 32768 MB | 2400 MT/s (PC4-19200) | -/-/&#10004 | v0.4.0 | Dasharo HCL report |
    End Diff
    From #lines
        41     768    4376
    To #lines
        42     788    4487
    ```

    Here:

    1. Information about what file was modified:

        `Modified: docs/docs/resources/hcl/memory/pro-z690-a-wifi-ddr4.md`

    2. Diff from the changes:

        ```bash
        Diff:
        20a21
        > | Kingston | KF3200C16D4/32GX | 32768 MB | 2400 MT/s (PC4-19200) | -/-/&#10004 | v0.4.0 | Dasharo HCL report |
        End Diff
        ```

    3. Information about how the number of line changed:

        ```bash
        From #lines
            41     768    4376
        To #lines
            42     788    4487
        ```
