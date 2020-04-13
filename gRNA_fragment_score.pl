use Switch;

open(ip,"<$ARGV[1]") or die "Cant open ip";

foreach(<ip>)
{
	chomp $_;
	@info=split(/\t/,$_);

### Scoring with preference to TTTA ###
	switch("$info[9]-$info[10]")
	{
		case "TTTA-TTTA" {$score_nt=1;}
		case "TTTA-TTTG" {$score_nt=0.5;}
		case "TTTA-TTTC" {$score_nt=0.5;}
		case "TTTG-TTTA" {$score_nt=0.5;}
		case "TTTG-TTTC" {$score_nt=0.25;}
		case "TTTG-TTTC" {$score_nt=0.25;}
		case "TTTG-TTTG" {$score_nt=0.25;}
		case "TTTC-TTTA" {$score_nt=0.5;}
		case "TTTC-TTTC" {$score_nt=0.25;}
		case "TTTC-TTTG" {$score_nt=0.25;}
	}

### Scoring with preference for 0 mismatch ###
	
	$count1 = ($info[3] =~ s/:/:/g);
	$count2 = ($info[5] =~ s/:/:/g);
	if(!$count1){$count1=0;}
	if(!$count2){$count2=0;}
	$count_mm=$count1 + $count2;
	
	switch("$count_mm")
	{
		case 0 {$score_mm=1;}
		case 1 {$score_mm= -0.2;}
		case 2 {$score_mm= -0.4;}
		case 3 {$score_mm= -0.6;}
		case 4 {$score_mm= -0.8;}
		case [5..6] {$score_mm= -1;}
	}

### Scoring with preference to GC content = 0.41 ###
	
	switch($info[7])
	{
		case [0.41] {$score_gc=1;}
		case {$info[7] == 0.40} {$score_gc=0.8;}
		case [0.42] {$score_gc=0.8;}
		case [0.39, 0.43] {$score_gc=0.6;}
		case [0.38, 0.44] {$score_gc=0.4;}
	}

	$score_total=$score_nt+$score_mm+$score_gc;

	print "$_\t$score_nt\t$score_mm\t$score_gc\t$score_total\n";
}

