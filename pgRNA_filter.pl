open(ip,"<$ARGV[1]") or die "can't open";
open(out,">$ARGV[3]") or die "can't open";
@file=<ip>;

@used1=();
@used2=();

print out "#Gene\tGeneID\tDistance of guide 1 from gene start\tMismatches in guide 1\tDistance of guide 2 from gene stop\tMismatches in guide 2\tFrame sequence with pgRNA\tGC content\tgRNA pair IDs\tPAM <TTT[AGC]> guide 1\tPAM <TTT[AGC]> guide 2\tScore_PAM\tScore_mismatch\tScore_GC\tScore_Total\n";

for($i=0;$i<@file;$i++)
{
	chomp $file[$i];
	@info=split(/\t/,$file[$i]);
	@id=split(/\-\>/,$info[8]);
	@id_num1=split(/\_/,$id[0]);
	@id_num2=split(/\_/,$id[1]);

	if ( grep(/$id[0]/, @used1) || grep(/$id[1]/, @used2))
	{next;}
	else
	{print out "$file[$i]\n";}

	push(@used1,$id[0]);
	push(@used2,$id[1]);

}
