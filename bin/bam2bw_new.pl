#!/usr/bin/perl
use Parallel::ForkManager;
use FindBin qw($Bin);

$EXT = "$Bin/../external_bin";
#$pm=new Parallel::ForkManager();
$RUN_TYPE = shift@ARGV;
$bam = shift@ARGV;
$genome = "$bam.G1";
$genome_chr = "$bam.G2";
$P = shift@ARGV;
$SEX = shift@ARGV;

die "bam not found!\n" unless -e $bam;
print STDOUT "bam2bw bam found";

system("$EXT/samtools view -H $bam | $Bin/bamHead2Genome.pl $SEX $bam");
print STDOUT "bam2bw header";
open(I,"<$genome");
while(<I>){
	chomp;
	@m = split(/\s+/);
	push @ALL, $m[0];
	open(II,">$bam.$m[0].GG");
	print II $_,"\n";
}
print STDOUT "bam2bw chrm separate";
$pm=new Parallel::ForkManager($P);
for($i = 0; $i < scalar @ALL; $i++){
	my $pid = $pm->start and next;
	$CHR = $ALL[$i];
	system("$EXT/samtools view -b $bam $CHR | $EXT/genomeCoverageBed -ibam stdin -g $bam.$CHR.GG -bga > $bam.$CHR.bed");
    print STDOUT "bam2bw samtools+genomcov, $CHR";
    system("grep \"$CHR\" $bam.$CHR.bed > $bam.$CHR.subset.bed");
	system("cat $bam.$CHR.bed | $Bin/bedTofixWig.pl $bam.$CHR.GG $CHR > $bam.$CHR.wig; rm $bam.$CHR.bed");
    print STDOUT "bam2bw bedTofixWig, $CHR";
	$pm->finish;
}
$pm->wait_all_children;
system("cat $bam.*.wig > $bam.wig; rm $bam.*.wig");
system("cat $bam.*.subset.bed > genome_coverage.bed;rm *.subset.bed");
system("python $Bin/coverage_calculator_bedgraph.py genome_coverage.bed > $bam.coverage; rm genome_coverage.bed");
print STDOUT "bam2bw coveracalc";
if($RUN_TYPE eq "lite"){
	system("rm $bam.*.GG");
}
else{
	system("$EXT/wigToBigWig $bam.wig $genome_chr $bam.bw; rm $bam.*.GG; rm $bam.G1 $bam.G2");
    print STDOUT "bam2bw wigToBigWig";
}

