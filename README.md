
# README
[![reviewdog misspell](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/catch_typos.yml/badge.svg)](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/catch_typos.yml)[![Docker Image CI](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/docker-image.yml/badge.svg?branch=main)](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/docker-image.yml)

A docker image for running [cDNA_Cupcake] (https://github.com/Magdoll/cDNA_Cupcake)
)

## Overview

There are six Python scripts for singlecell in cDNA_Cupcake, each has been wrapped so that you can execute seamlessly the routines in the container.

## cDNA_Cupcake/singlecell
|   | <p align="center"><img src="https://github.com/Magdoll/images_public/blob/master/logos/Cupcake_logo.png" width="100" align="right"></p> |
|--|--|
| **script name** | **description** |
| `UMI_BC_error_correct.py` | |
| `clip_out_UMI_cellBC.py` | |
| `cluster_by_UMI_mapping.py` | |
| `collate_FLNC_gene_info.py`| |
| `dedup_FLNC_per_cluster.py`| |
| `make_csv_for_dedup.py`| |


## Testing each command 
### Using the most recent version

The following was run from a terminal window on a MacBookPro


```
docker run --rm -v $PWD:$PWD -w $PWD -it --entrypoint /bin/bash cdnacupcake clip_out_UMI_cellBC.py -h
```

If all is well this will return on the command line:
```
usage: clip_out_UMI_cellBC.py [-h] [-u UMI_LEN] [-b BC_LEN] [-t TSO_LEN] [--umi_type {A3,G5,G5-10X,G5-clip}] [--g5_clip_seq G5_CLIP_SEQ] [--bc_rank_file BC_RANK_FILE]
                              bam_filename output_prefix

positional arguments:
  bam_filename          CCS BAM with cDNA primer removed (post LIMA)
  output_prefix         Output prefix

optional arguments:
  -h, --help            show this help message and exit
  -u UMI_LEN, --umi_len UMI_LEN
                        Length of UMI
  -b BC_LEN, --bc_len BC_LEN
                        Length of cell barcode
  -t TSO_LEN, --tso_len TSO_LEN
                        Length of TSO (for G5-10X only)
  --umi_type {A3,G5,G5-10X,G5-clip}
                        Location of the UMI
  --g5_clip_seq G5_CLIP_SEQ
                        Sequence before UMI for G5-clip (for G5-clip only)
  --bc_rank_file BC_RANK_FILE
                        (Optional) cell barcode rank file from short read data

```
