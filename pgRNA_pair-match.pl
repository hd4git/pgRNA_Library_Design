open(p1,"<$ARGV[1]") or die "Can't open";
open(p2,"<$ARGV[3]") or die "Can't open";
open(lnc,"<$ARGV[5]") or die "Can't open lnc";

open(out,">$ARGV[7]");

foreach(<p1>)
{
	chomp $_;
	@info_1=split(/\t/,$_);
	@id_1=split(/\_/,$info_1[0]);
	$guides_1{$id_1[0]}.=$info_1[0]."~".$info_1[1]."~".$info_1[7].";";
	#print "$id_1[0]\n";
}


foreach(<p2>)
{
	chomp $_;
	@info_2=split(/\t/,$_);
	@id_2=split(/_/,$info_2[0]);
	$guides_2{$id_2[0]}.=$info_2[0]."~".$info_2[1]."~".$info_2[7].";";
}


foreach(<lnc>)
{
	chomp $_;
 	@coord=split(/\t/,$_);

 	@gRNA_1=split(/;/,$guides_1{$coord[3]});
 	@gRNA_2=split(/;/,$guides_2{$coord[3]});

#print "$coord[3]\t$guides_1{$coord[3]}\n";

 for($i=0;$i<@gRNA_1;$i++)
 	{
 		@seq_1=split(/\~/,$gRNA_1[$i]); 		
 		for($j=0;$j<@gRNA_2;$j++)
 		{
 			@seq_2=split(/\~/,$gRNA_2[$j]);

 			$seq_1_wo_PAM = substr($seq_1[1],4);
 			$seq_2_wo_PAM = substr($seq_2[1],4);

 			$frame="ctagtagttCGTCTCgCACCGTAATTTCTACTCTTGTAGAT".$seq_1_wo_PAM."AATTTCTACTCTTGTAGAT".$seq_2_wo_PAM."TTTTTGCGTTTgGAGACGttgttctgc";
 			$frame_primer="CACCGTAATTTCTACTCTTGTAGAT".$seq_1_wo_PAM."AATTTCTACTCTTGTAGAT".$seq_2_wo_PAM."TTTTTGCGTTT";
 			
 			$count_G = ($frame_primer =~ s/G/G/g);																														## G,C counts
			$count_C = ($frame_primer =~ s/C/C/g);		
			$count_GC = sprintf("%.2f",($count_G+$count_C)/101);

			if($count_GC>=0.38 && $count_GC<=0.44) 
			{	
				if($gRNA_1[$i]=~/\~$/){$gRNA_1[$i].="_";}
				if($gRNA_2[$i]=~/\~$/){$gRNA_2[$i].="_";}
				print out "$gRNA_1[$i]\t$gRNA_2[$j]\t$frame\t$count_GC\n"; }
 		}	
 	}
 }	
