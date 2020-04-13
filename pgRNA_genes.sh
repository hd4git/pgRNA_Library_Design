#!/bin/bash
## A shell script to prepare paired guide RNA library 
## for CRISPR-Cpf1 based genome editing tools
# Written by: Heena Dhiman, PhD 

# Last updated on: Dec/19/2019
# ---------------------------------------------------------------------------

if [ "$1" = "--help" ] ; then
  echo "Usage: ./pgRNA_genes.sh -bed <path of bed file for target regions>"
  exit 0
fi

### Set variables
fullfilename=$2
path=$(dirname $fullfilename)
filename=$(basename "$fullfilename")
fname="${filename%.*}"
ext="${filename##*.}"

#################################################
echo "Extracting scaffold sequences for genes..."
#################################################

while read f;
do
	echo $f
	samtools faidx src/picr.fa $f >> $path/picr_scaffold_$fname\.fa
done < <(cut -f1 $fullfilename | sort | uniq)

#####################################################
echo "Extracting 27nt guides with PAM information..."
#####################################################

perl pgRNA_genes.pl -scaff $path/picr_scaffold_$fname\.fa -bed $fullfilename

#############################################################
echo "Mapping guides across the genome (Finding off-targets)"
#############################################################

bowtie src/picr -f $path/picr_gRNA-$fname\.fa \
			-a \
			-y \
			-n 0 \
			-l 18 \
			-p 11 \
			> $path/picr_gRNA-$fname\_bowtie_seed-18.txt
  # -a/--all           report all alignments per read (much slower than low -k)
  # -y/--tryhard       try hard to find valid alignments, at the expense of speed
  # -n/--seedmms <int> max mismatches in seed (can be 0-3, default: -n 2)
  # -l/--seedlen <int> seed length for -n (default: 28)
  # -p/--threads <int> number of alignment threads to launch (default: 1)


##########################################################
echo "Parsing bowtie output and filtering the guides..."
##########################################################

#### Remove all guides with more than 1 match with / without mismatches
#### Remove all guides mapping on - strand
## genes
awk '{if($7==0)print $0}' $path/picr_gRNA-$fname\_bowtie_seed-18.txt > $path/picr_gRNA-$fname\_bowtie_seed-18_uniq.txt

#### Split the guides from upstream and downstream and extract sequences with PAM
## genes
sed -i 's/_new//' $path/picr_gRNA-$fname\_bowtie_seed-18_uniq.txt
sed -i 's/_new//' $fullfilename

awk 'NR==FNR {	OFS="\t";\
				a[$1]=$3"\t"$4"\t"$2"\t"$5"\t"$7"\t"$8; \
				next} \
				($1 in a) \
				{print $0"\t"a[$1]}' \
				$path/picr_gRNA-$fname\_bowtie_seed-18_uniq.txt \
				$path/picr_gRNA-$fname\_pam.txt | \
				awk -F "[_\t]" '{if($2~/p1/ && $8~/\+/) print $0}' \
				> $path/gRNA_1-$fname\.txt
awk 'NR==FNR {	OFS="\t";\
				a[$1]=$3"\t"$4"\t"$2"\t"$5"\t"$7"\t"$8; \
				next} \
				($1 in a) \
				{print $0"\t"a[$1]}' \
				$path/picr_gRNA-$fname\_bowtie_seed-18_uniq.txt \
				$path/picr_gRNA-$fname\_pam.txt | \
				awk -F "[_\t]" '{if($2~/p2/ && $8~/\+/) print $0}' \
				> $path/gRNA_2-$fname\.txt
#### Match the pairs from up and down of the gene
#### filter for GC of the frame without the primer 
perl pgRNA_pair-match.pl \
				-p1 $path/gRNA_1-$fname\.txt \
				-p2 $path/gRNA_2-$fname\.txt \
				-bed $fullfilename \
				-out $path/gRNA-$fname\_info.txt

#substitute ~\t with ~_\t in $path/gRNA-$fname\_info.txt
sed -i 's/~\t/~_\t/g' $path/gRNA-$fname\_info.txt

#### Get gene coordinates 
awk -F "[_\t]" 'NR==FNR \
				{a[$5]=$0; next} \
				($1 in a) \
				{print $0"\t"a[$1]}' \
				$fullfilename \
				$path/gRNA-$fname\_info.txt \
				> $path/gRNA-$fname\_info-gene.txt

#### Get PAM and sort with pam, gc and distance
awk -F "[-~\t]" 'function abs(v) \
				{return v < 0 ? -v : v} \
				{OFS="\t"; \
				print $14,abs($12-$2),$4,abs($6-$13),$8,$9,$10,$1"->"$5,$3,$7}' \
				$path/gRNA-$fname\_info-gene.txt | \
				awk '{\
				String1=substr($(NF-1),1,4);\
				String2=substr($NF,1,4); \
				print $0,String1,String2}'  | \
				sort -k1,1 -k11,12 -k2,2 -k4,4 -k7,7 \
				> $path/gRNA-$fname\_info-gene_sort.txt

#### Add numbers to the genes
awk 'BEGIN 	{Idx=0;}\
			{OFS="\t"; \
			if($1==A)\
				{print Idx,$1,$2,$3,$4,$5,$6,$7,$8,$11,$12}\
			else\
				{A=$1;Idx++; \
				print Idx,$1,$2,$3,$4,$5,$6,$7,$8,$11,$12}}' \
				$path/gRNA-$fname\_info-gene_sort.txt \
				>  $path/gRNA-$fname\_info-gene_sort-num.txt

#### Compute scores based on PAM, mismatches and GC content
perl gRNA_fragment_score.pl \
			-i $path/gRNA-$fname\_info-gene_sort-num.txt | \
			sort -k1,1n -k 15,15r \
			> $path/gRNA-$fname\_info-gene_sort-score.txt

#### Filter for redundancy of guides
perl pgRNA_filter.pl \
			-i $path/gRNA-$fname\_info-gene_sort-score.txt \
			-o $path/gRNA-$fname\_info-gene_sort-score_filter.txt

## Subset for top 4 pairs
perl pgRNA_subset4.pl \
			-i $path/gRNA-$fname\_info-gene_sort-score_filter.txt \
			-o $path/gRNA-$fname\_final.txt



