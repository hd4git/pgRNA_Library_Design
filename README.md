# Description 

pgRNA_genes.sh is a wrapper for scripts that are used to: 
  - browse 2kb upstream and downstream regions of the targets mentioned in the input bed file
  - identify guide sequences with PAM sites
  - mapping the guides across the genome to identify potential off target
  - match pairs of guide from upstream and downstream the target to filter them on the basis of GC content
  - parse the alignment map to filter and sort on the basis of PAM, mismatches and GC content
  - Subset top 4 pairs of non-redundant guide RNA pairs
