Dasharo Tool Suite HCL manager
------------------------------

DTS HCL manager is used to generate entries to Dasharo HCL
CPU/memory/mainboard/GPU documentation based on Dasharo HCL reports.

```bash
Usage: ./dts-hclmgr.sh [dasharo_hcl_report]
         [dasharo_hcl_report] - Dasharo HCL report.
```

To speed up parsing of multiple reports (in this case located in `/tmp`) you
can use following snippet:

```
for i in /tmp/*.tar.gz;do ./dts-hclmgr.sh $i;done
```

