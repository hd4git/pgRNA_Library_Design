open(ip,"<$ARGV[1]") or die "can't open";
open(out,">$ARGV[3]") or die "can't open";
@file=<ip>;

$prev="";

print out "#Gene\tGeneID\tDistance of guide 1 from gene start\tMismatches in guide 1\tDistance of guide 2 from gene stop\tMismatches in guide 2\tFrame sequence with pgRNA\tGC content\tgRNA pair IDs\tPAM <TTT[AGC]> guide 1\tPAM <TTT[AGC]> guide 2\tScore_PAM\tScore_mismatch\tScore_GC\tScore_Total\n";

for($i=0;$i<@file;$i++)
{
	chomp $file[$i];
	@info=split(/\t/,$file[$i]);
	if($info[1]=~/^$/ || $info[1]!~/^$prev$/)
	{
		$count=0;
		print out "$file[$i]\n";
	}
	else
	{
		$count++;
		if($count<=3)
		{print out "$file[$i]\n";}
	}		
$prev=$info[1];		
}
	
