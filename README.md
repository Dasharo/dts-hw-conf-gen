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
9. Update date of the HCL report in the documentation.

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

The new feature allows the memory report to automatically update the HCL report
tables. The changes are not committed though, leaving the option to review and
fix the final result.
The option is `-u` (`--update`)

To generate memory HCL report:

1. Do the same preparations as for CPU HCL (steps 1-3).

1. Clone the `docs` submodule:

    ```bash
    git submodule update --init
    ```

1. Run the script for all HCL reports found in the directory:

    ```bash
    find . -name "Micro-Star_International_Co.,_Ltd.*.tar.gz" -print0 | xargs -0 -n1 bash -c './dts-hclmgr --quiet --force --update  memory "$0"'
    ```

    Note: here the `--force` option is used. With it, the script would unpack
    all reports again. The script execution may take a while.

    Note: Interrupting the script may break the HCL table in
    `docs/resources/hcl`. In that case, run:

    ```bash
    rm -rf docs/ && git submodule update --init
    ```

    to re-init the `docs` submodule and run the script again.

1. Snippet of output:

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

    1. Diff from the changes:

        ```bash
        Diff:
        20a21
        > | Kingston | KF3200C16D4/32GX | 32768 MB | 2400 MT/s (PC4-19200) | -/-/&#10004 | v0.4.0 | Dasharo HCL report |
        End Diff
        ```

    1. Information about how the number of line changed:

        ```bash
        From #lines
            41     768    4376
        To #lines
            42     788    4487
        ```

    Note: If the changes are already present, or there are no new memory
    modules, script will display:

      ```bash
      No changes made to docs/docs/resources/hcl/memory/pro-z690-a-wifi-ddr4.md
      ```

    If the memory report is valid, but the board is not supported by the script,
    the script will display:

      ```bash
      Error: Unknown or unsupported board: PRO Z690-A DDR4(MS-7D25)
      ```

1. After the script has finished, go to the `docs` directory:

    ```bash
    cd docs
    ```

1. Display the diff:

    ```bash
    git diff
    ```

    Note: If the HCL report does not provide any new information, there may be
    no differences. In that case, no actions required.

1. Commit the desired file:

    ```bash
    git add <path-to-file>
    ```

    ```bash
    git commit -sm "<COMMIT_MESSAGE>"
    ```
