# Description 

pgRNA_genes.sh is a wrapper for scripts that are used to: 
  - browse 2kb upstream and downstream regions of the targets mentioned in the input bed file
  - identify guide sequences with PAM sites
  - mapping the guides across the genome to identify potential off target
  - match pairs of guide from upstream and downstream the target to filter them on the basis of GC content
  - parse the alignment map to filter and sort on the basis of PAM, mismatches and GC content
  - Subset top 4 pairs of non-redundant guide RNA pairs

# Pre-requisites 

- Install bowtie, samtools
- Create a src directory
```
    mkdir src
    cd src
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/668/045/GCF_003668045.1_CriGri-PICR/GCF_003668045.1_CriGri-PICR_genomic.fna.gz
    gunzip GCF_003668045.1_CriGri-PICR_genomic.fna.gz 
    mv GCF_003668045.1_CriGri-PICR_genomic.fna picr.fa
```
- Create fasta index with samtools for the reference sequence
```
    samtools faidx picr.fa
```
- Create bowtie index for reference sequence
```
    bowtie-build picr.fa picr
```
# Usage 
```
./pgRNA_genes.sh -bed <input bed file>
```
Input bed file: Its a tab separated text file with ".bed" extension 
    chr | start | stop | name | score | strand 
