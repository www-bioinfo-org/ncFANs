use List::Util qw[min max];

%link=();

$file = shift @ARGV;
$outf = shift @ARGV;
$top = 1;
$pv = 1;


$mincor = 1;
open(one,"$file");
open(res,">$outf");
while(<one>)
{
	chomp;
	$_=~s/^"//;
	$_=~s/"$//;
	if(grep(/^corinfo/,$_))
	{
		#	print $acor."\t".$bcor."\n";
		$acor=(split(/\t/,$_))[1];
		$bcor=(split(/\t/,$_))[2];
	}
	my($node1,$node2,$c)=split(/\t/,$_);

	if((!exists($link{$node1."\t".$node2})) and (!exists($link{$node2."\t".$node1})) and ($node1 ne $node2) and $node1 ne "" and $node2 ne "" and $c ne "" )
	{
		
		if($c>=$acor)
		{

		if($node1 ge $node2)
		{
			$max=$node1;
			$less=$node2;
		}
		else
		{
			$max=$node2;
			$less=$node1;
		}
		$code{$max}=0 if(grep(/_c$/,$max));
		$code{$less}=0 if(grep(/_c$/,$less));
		$noncode{$max}=0 if(grep(/_kn$/,$max));
		$noncode{$less}=0 if(grep(/_kn$/,$less));			
		$nnoncode{$max}=0 if(grep(/_nn$/,$max));
		$nnoncode{$less}=0 if(grep(/_nn$/,$less));			
		$link{$max."\t".$less}="$c\n";
		}
	}
}
close(one);
$cc=0;
$nc=0;
$nn=0;
$pcc_cc = 0;
$pcc_nc = 0;
$pcc_nn = 0;
while(my($k,$v)=each(%link))
{
	print res $k."\t".$v;		
        my @tmp = split "\t", $k;
        if($tmp[0] =~ m/_c$/ && $tmp[1] =~ m/_c$/) {
            $cc++;
            $pcc_cc = $pcc_cc + $v;
        } elsif ($tmp[0] =~ m/_c$/ || $tmp[1] =~ m/_c$/) {
            $nc++; 
            $pcc_nc = $pcc_nc + $v;
        } else {
            $nn++;
            $pcc_nn = $pcc_nn + $v;
        }
        $mincor = $v if ($v < $mincor);
}
close(res);
=comment
open(res,">$outf.info");
if(defined(%code)) {
    $c_node=keys(%code);
} else {
    $c_node = 0;
}	
if(defined(%noncode)) {
    $n_node=keys(%noncode);
} else {
    $n_node = 0;
}
if(defined(%nnoncode)) {
    $nn_node=keys(%nnoncode);
} else {
    $nn_node = 0;
}
print res "Number of known coding gene nodes\t$c_node\n";
print res "Number of known lincRNA gene nodes\t $n_node\n";
print res "Number of novel lincRNA gene nodes\t$nn_node\n";
print res "Number of coding-coding(cc) edges\t$cc\n";
print res "Number of noncoding-noncoding(nn) edges\t$nn\n";
print res "Number of noncoding-coding(nc) edges\t$nc\n";
if ($cc > 0) {
    print res "the mean of PCC for cc edges\t", $pcc_cc / $cc, "\n";
}
if ($nn > 0) {
    print res "the mean of PCC for nn edges\t", $pcc_nn / $nn, "\n";
}
if ($nc > 0) {
    print res "the mean of PCC for nc edges\t", $pcc_nc / $nc, "\n";
}
close(res);
=cut
open MIN, ">$outf.min";
print MIN $mincor, "\n";
close MIN;
