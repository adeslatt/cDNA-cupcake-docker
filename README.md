
# README
[![Docker Image CI](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/docker-image.yml/badge.svg?branch=main)](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/docker-image.yml)[![Docker](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/adeslatt/cDNA-cupcake-docker/actions/workflows/docker-publish.yml)

This is the repository for the Dockerfile made to containerize the running [cDNA_Cupcake](https://github.com/Magdoll/cDNA_Cupcake).   It is built automatically upon any push to the repository using GitHub actions.  There are several workflows set up to execute upon each push.  The Docker image is automatically built and pushed to the GitHub container registry and may be pulled directly from there with this following command:

```
docker pull ghcr.io/adeslatt/cdna-cupcake-docker:latest
```

## Overview

There are six Python scripts for singlecell in cDNA_Cupcake, each has been wrapped so that you can execute seamlessly the routines in the container.

## cDNA_Cupcake/singlecell
|   | <p align="center"><img src="https://github.com/Magdoll/images_public/blob/master/logos/Cupcake_logo.png" width="100" align="right"></p> |
|--|--|
| **script name** | **description** |
| `UMI_BC_error_correct.py` |  Error correct BCs by gene group and error correct by UMI |
| `clip_out_UMI_cellBC.py` | Given as input a BAM after running LIMA so post-LIMA (primer-trimmed) CCS sequences, the UMI_type either 'A3' or 'G5' or 'G5-10X' and the presence of shortread_bc, aka a dictionary and a Y or N for top-ranked. If given, it came from short read data.  This routine (assumes that the 5'/3' primers have already been removed by lima and makes no assumption about hte polyA tail existing or not, it clips out the UMI and writes out the rest of the sequence, keeping the RT + transcript|
| `cluster_by_UMI_mapping.py` | A group is FLNCs that have the same (mapped locus, UMI) group name is currently a string of the directory we will create later, which is <out_dir>/<loci_index>/<UMI>-<BC>/flnc_tagged.bam |
| `collate_FLNC_gene_info.py`| Given 1. single cell UMI, BC file (ccs -> umi, bc) 2. collapse group.txt  (ccs -> pbid) 3. SQANTI classification (pbid -> transcript, isoform, category) 4. optional ontarget file (pbid -> ontarget or not).  This routine outputs a collated file for each as follows: `ccs, pbid, transcript, gene, category, ontarget (Y or N or NA), UMI, BC, UMIrev, BCrev` |
| `dedup_FLNC_per_cluster.py`| After running UMI_BC_error_correct.py with --bc_rank_file and --only_top_ranked parameters, this routine takes the (1) .annotated.correct.csv file, (2) short read cluster (cell type) csv file, and (3) fasta (file ends with faa), gff, to de-duplicate the FLNC reads by cluster (cell type). It then outputs: (1) a de-dup table of (UMI-ed, BC-ed, gene) ??? pbid ??? associate gene ??? associated transcript ??? category ??? length ??? cluster #, (2)  A ???master??? file, one sequence for each [pbid] that appeared at least once in both a fasta and gff format, and (3) A ???per cluster??? file, one sequence for each [pbid] that appeared once in each cluster also in both a fasta and a gff format |
| `make_csv_for_dedup.py`| A temporary CSV file for isoseq3 (v3.4+) dedup output.  It takes as dedup.fasta and outputs dedup.info.csv |


## Testing each command 
### Using the most recent version

The following was run from a terminal window on a MacBookPro, but this could be run from anywhere accessible to the GitHub container registry.

### Running 'UMI_BC_error_correct.py`
```
docker run --rm -v $PWD:$PWD -w $PWD -it --entrypoint /bin/bash ghcr.io/adeslatt/cdna-cupcake-docker:latest UMI_BC_error_correct.py -h
```
  
IF all is well this will return on the command line:
  
```
usage: UMI_BC_error_correct.py [-h] [--bc_rank_file BC_RANK_FILE] [--only_top_ranked] [--dropseq_clean_report DROPSEQ_CLEAN_REPORT]
                               [--dropseq_synthesis_report DROPSEQ_SYNTHESIS_REPORT]
                               input_csv output_csv

positional arguments:
  input_csv             Input CSV
  output_csv            Output CSV

optional arguments:
  -h, --help            show this help message and exit
  --bc_rank_file BC_RANK_FILE
                        (Optional) cell barcode rank file from short read data
  --only_top_ranked     (Optional) only output those that are top-ranked. Must have --bc_rank_file.
  --dropseq_clean_report DROPSEQ_CLEAN_REPORT
                        Output from running DetectBeadSubstitutionErrors in DropSeq cookbook (ex:
                        star_gene_exon_tagged_clean_substitution.bam_report.txt)
  --dropseq_synthesis_report DROPSEQ_SYNTHESIS_REPORT
                        Output from running DetectBeadSynthesisErrors in DropSeq cookbook (ex:
                        star_gene_exon_tagged_clean_substitution_clean2.bam_report.txt)
```
  
### Running `clip_out_UMI_cellBC.py`

```
docker run --rm -v $PWD:$PWD -w $PWD -it --entrypoint /bin/bash ghcr.io/adeslatt/cdna-cupcake-docker:latest clip_out_UMI_cellBC.py -h
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

### Running `cluster_by_UMI_mapping.py`

```
docker run --rm -v $PWD:$PWD -w $PWD -it --entrypoint /bin/bash ghcr.io/adeslatt/cdna-cupcake-docker:latest cluster_by_UMI_mapping.py -h
```

If all is well this will return on the command line:

```
usage: Cluster reads by UMI/BC [-h] [-d OUT_DIR] [--useBC] flnc_bam sorted_sam umi_bc_csv output_prefix

positional arguments:
  flnc_bam              FLNC BAM filename
  sorted_sam            Mapped, sorted FLNC SAM filename
  umi_bc_csv            Clipped UMI/BC CSV filename
  output_prefix         Output prefix

optional arguments:
  -h, --help            show this help message and exit
  -d OUT_DIR, --out_dir OUT_DIR
                        Cluster out directory (default: tmp/)
  --useBC               Has single cell BC (default: off)
```
### Running `collate_FLNC_gene_info.py`

 ```
docker run --rm -v $PWD:$PWD -w $PWD -it --entrypoint /bin/bash ghcr.io/adeslatt/cdna-cupcake-docker:latest ollate_FLNC_gene_info.py -h
```

If all is well this will return on the command line:

```
usage: collate_FLNC_gene_info.py [-h] [-i ONTARGET_FILENAME] [-p DEDUP_ORF_PREFIX] [--no-extra-base] [--is_clustered]
                                 group_filename csv_gz_filename class_filename output_filename

positional arguments:
  group_filename        Collapse .group.txt
  csv_gz_filename       Trimmed UMI/BC CSV info, compressed with gzip
  class_filename        SQANTI classification.txt
  output_filename       Output filename

optional arguments:
  -h, --help            show this help message and exit
  -i ONTARGET_FILENAME, --ontarget_filename ONTARGET_FILENAME
                        (Optional) on target information text
  -p DEDUP_ORF_PREFIX, --dedup_ORF_prefix DEDUP_ORF_PREFIX
                        (Optional) dedup-ed ORF group prefix, must have <pre>.faa and <pre>.group.txt
  --no-extra-base       Drop all reads where there are extra bases
  --is_clustered        group.txt contains post-UMI clustering result
```

### Running `dedup_FLNC_per_cluster.py`
```
docker run --rm -v $PWD:$PWD -w $PWD -it --entrypoint /bin/bash ghcr.io/adeslatt/cdna-cupcake-docker:latest  dedup_FLNC_per_cluster.py -h
```

If all is well this will return on the command line:

```
usage: De-duplicate FLNC reads per cluster [-h] [--fasta FASTA] [--gff GFF] [--faa FAA] corrected_csv cluster_file

positional arguments:
  corrected_csv  Annotated, error-corrected FLNC CSV file
  cluster_file   Short read barcode to cluster CSV file

optional arguments:
  -h, --help     show this help message and exit
  --fasta FASTA  (Optional) Fasta file (IDs should be PB.X.Y)
  --gff GFF      (Optional) GFF file (IDs should be PB.X.Y)
  --faa FAA      (Optional) Faa file (IDs should be PB.X.Y)
```
