use File::Basename;

$scaff=$ARGV[1];
$bed=$ARGV[3];
$path=dirname($bed);
$file=basename($bed);
@name=split('\.', $file);

### Read the reference fasta
open(REFERENCE, "<$scaff") or die "Can't open REF";
print "Reading the reference ...\n";
foreach(<REFERENCE>)
{
	chomp $_; 
	if($_ =~ /^>/)
	{	$id= substr($_,1);}
	if($_ !~ /^>/)
	{	$sequence{$id}.=$_;}
}
close(REFERENCE);

### Read the reference index
open(INDEX, "<src/picr.fa.fai") or die "Can't open INDEX";
print "Reading the index ...\n";
foreach(<INDEX>)
{
	chomp $_;
	@index=split(/\t/,$_);

	$size{$index[0]}=$index[1];
	$length{$index[0]}=$index[3]
}
close(INDEX);

### Read the lnc gene coordinates
open(lnc,"<$bed") or die "Can't open lnc";
foreach(<lnc>)
{
	chomp $_;
 	@coord=split(/\t/,$_);
 	$picr_sequence=$sequence{$coord[0]};

 	if($coord[5] =~ /^+$/)
 	{
	 	$start=$coord[1];
	 	$stop=$coord[2];

	 	$target_sequence_p1{$coord[3]}=substr($picr_sequence,$start,2000);
	 	$target_sequence_p2{$coord[3]}=substr($picr_sequence,$stop,2000);
 	}
 	else
 	{
 		$start=$coord[1]-2000;
	 	$stop=$coord[2]-2000;

	 	$target_sequence_p1{$coord[3]}=substr($picr_sequence,$start,2000);
	 	$target_sequence_p2{$coord[3]}=substr($picr_sequence,$stop,2000);
 	}
 	print "Preparing $coord[3] ...\n";

 	&get_gRNA($target_sequence_p1{$coord[3]},p1,$coord[3],$start,$coord[0]);
 	print "$coord[3]\_p1 Prepared\t$coord[0]\n";
 	&get_gRNA($target_sequence_p2{$coord[3]},p2,$coord[3],$stop,$coord[0]);
 	print "$coord[3]\_p2 Prepared\t$coord[0]\n";
}
close(lnc);

sub get_gRNA
{
### Finding PAM sites (TTT[ACG]) in picr
### Extracting 27 nucleotide frames as guides
### Removing the ones containing TTTTT or GGGGG (also AAAAA and CCCCC)
### Removing the ones containing recognition sites for restriction enzymes Bsmb1 and Bbs1 (CGTCTC, GAAGAC)
### Removing the ones with extreme GC content (removed to be filtered later)
my @info=@_;

open(OUT,">>$path/picr_gRNA-$name[0]\.fa");
open(OUT2,">>$path/picr_gRNA-$name[0]\_pam.txt");

for($i=0,$count=1; $i<$size{$info[4]}; $i++)
{
	$gRNA=substr($info[0],$i,27);																															## 27 ntd window 
	$gRNA_len=length($gRNA);																																							

	$gRNA_start=$info[3]+$i;

	$count_G = ($gRNA =~ s/G/G/g);																															## G,C counts
	$count_C = ($gRNA =~ s/C/C/g);		
	$count_GC = sprintf("%.2f",($count_G+$count_C)/27);

	if($gRNA =~ /^TTT/ && $gRNA !~ /^TTTT/ && $gRNA_len == 27 && $gRNA !~ /A{5}|C{5}|T{5}|G{5}|CGTCTC|GAAGAC/ && $count_GC >= 0.3 && $count_GC <= 0.7)		## Filtering
	{	
		$gRNA_wo_PAM = substr($gRNA,4);																														## Remove PAM to report target
		print OUT ">$info[2]\_$info[1]\_$count-$gRNA_start\n$gRNA_wo_PAM\n";	
		print OUT2 "$info[2]\_$info[1]\_$count-$gRNA_start\t$gRNA\n";	
		$count++;
	}
}

}