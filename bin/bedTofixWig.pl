#!/usr/bin/perl
#
open(I,"<",shift@ARGV);
$CHR=shift@ARGV;
$flag=0;
$k=substr($CHR,0,3);
if (substr($CHR,0,3) eq "chr"){
    $flag = 1;
}
else{
    $flag = 0;
}
if ($flag == 0 && (length($CHR) > 2 || substr($CHR,0,1) eq "Y" || substr($CHR,0,1) eq "M")){
    exit 0;
}
elsif ($flag == 1 && (length($CHR) > 5 || substr($CHR,3,1) eq "Y" || substr($CHR,3,1) eq "M")){
    exit 0;
}
while(<I>){
	chomp;
	@m = split(/\s+/);
	if(substr($m[0], 0, 1) ne "c"){
		$m[0] = "chr".$m[0];
	}
	$hash{$m[0]} = 1;
}
while(<STDIN>){
	chomp;
	@m = split(/\s+/);
	if($m[3] > 2000){
		$m[3] = 2000;
	}
	if(substr($m[0], 0, 1) ne "c"){
		$m[0] = "chr".$m[0];
	}
	if(!exists $hash{$m[0]}){
		next;
	}
	if($m[0] ne $chr || $m[1] != $lastE){
		$step = $m[2] - $m[1];
		if($m[1]==0){
			$lastE = $m[2];
			next;
		}
		print "fixedStep chrom=$m[0] start=$m[1] step=1 span=1\n";
		$sum=0;
		for $k (3 .. $#m){
			$sum += $m[$k];
		}
		for($i=1;$i<=$step;$i++){
			print $sum,"\n";
		}
	}
	else{
		$step = $m[2] - $m[1];
		$sum=0;
		for $k (3 .. $#m){
			$sum += $m[$k];
		}
		for($i=1;$i<=$step;$i++){
			print $sum,"\n";
		}
	}
	$chr = $m[0];
	$lastSpan = $m[2] - $m[1];
	$lastE = $m[2];
}
