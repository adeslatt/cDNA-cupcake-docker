
# README

A docker image for running [cDNA_Cupcake] (https://github.com/Magdoll/cDNA_Cupcake)
)

## Usage

There are six Python scripts for singlecell in cDNA_Cupcake:

## cDNA_Cupcake/singlecell
|   | <p align="center"><img src="https://github.com/Magdoll/images_public/blob/master/logos/Cupcake_logo.png" width="100" align="right"></p> |
| script name | description |
| `UMI_BC_error_correct.py` | |
| `clip_out_UMI_cellBC.py` | |
| `cluster_by_UMI_mapping.py` | |
| `collate_FLNC_gene_info.py`| |
| `dedup_FLNC_per_cluster.py`| |
| `make_csv_for_dedup.py`| |


```
# Using the most recent version
docker run --rm adeslat/cdnacupcake:latest UMI_BC_error_correct.py --help
# Using a specific version of SQANTI3
docker run --rm adeslat/cdnacupcake:24.3.0 UMI_BC_error_correct.py --help
```

