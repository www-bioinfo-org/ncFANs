use List::Util qw[min max];
use File::Copy;
use POSIX;

sub go2term
{
	open(go,"GO/term.txt");
	while(<go>)
	{
		chomp;
		my($go,$goid,$type,$term)=split(/\t/,$_);
		$go2type{$go}=$type;
		$go2term{$go}=$term;
		$go2id{$go}=$goid;
	}
	close(go);
}

sub go{
	open(gos,"$_[0]");
	while(<gos>)
	{
		chomp;
#	print $_."\n";
		my($n1,$n2)=split(/\t/,$_);
		${$_[1]}{$n1}=$n2;
	}
	close(gos);
}


sub enrich
{
	%enriinfo=();
	my %count_go=();
	my $allgos="";
	my %g2go=%{$_[0]};
	my %go2g=%{$_[1]};
	my @genes=@{$_[2]};  # genes in the module or hub
	my $gene_cutoff=$_[3];
	my $pv_cutoff=$_[4];
	my $m=keys(%g2go);   # genes number of the species
	my $total_go=0;
	my $k=0;
	@exigenes=();
	my $type=$_[5];
	@gogenes=();
	my $minp=1;
	my $info="";
	my %pargos=();
	foreach my $g(@genes)
	{
		if(exists($g2go{$g}))
		{

			$mygos=$g2go{$g};
			$allgos=$allgos.";".$mygos;
			$exigenes[$k]=$g;
			$k++;

		}
	}
	if($k>=3)
	{

		foreach my $go(split(/;/,substr($allgos,1)))
		{

			$count_go{$go}++;
		}
		while(my($key,$val)=each(%count_go))
		{
			$total_go++ if($val>=$gene_cutoff);
		}


		while(my($key,$val)=each(%count_go))
		{
			if($val>=$gene_cutoff)
			{
				@gogenes=split(/;/,$go2g{$key});
				my $n=@gogenes;

	#	print $key."\t".$n."\t".$m."\t".$k."\t".$val."\n";
				my $pv=hypergeom($n,$m-$n,$k,$val);
#print $pv."\n";
				$pv=$pv*$total_go;
#	print $key."\t".$n."\t".$m."\t".$k."\t".$val."\t$pv\t$total_go\n";
				if($pv<=$pv_cutoff)
				{

					$minp=min($minp,$pv);
					if($minp==$pv)
					{
						$info=$type."###".$go2term{$key}."###".$pv;
					}
#	my @owngs=intersect("gogenes","exigenes");
#	my $gs=join(",",@owngs);
##	foreach my $o(@owngs)
#	{
#		print $o."\n";
#	}
					
					$enriinfo{$key}=$type."\t".$go2id{$key}."\t".$go2term{$key}."\t".$n."\t".$val."\t".$pv."\t".join(",",intersect("gogenes","exigenes"))."\n" if($type ne "KEGG");
				}
			}
		}

		
		if(keys(%enriinfo)>=1)
		{


			$enriinfo{"siginfo"}=$info;
			return %enriinfo;

		}
	}
	return $info;
}


my ($dir, $gobp, $gomf, $gocc, $module, 
    $gene_cutoff, $hub_cutoff, $pv_cutoff) = @ARGV;

print $dir, "\n";
print $gobp, "\n";
print $gomf, "\n";
print $gocc, "\n";
print $module, "\n";
print $gene_cutoff, "\n";
print $hub_cutoff, "\n";
print $pv_cutoff, "\n";

if ($module > 0) {
    $module = 1;
}

if ($hub_cutoff > 0) {
    $hub = 1;
}

if($gobp eq "1" || $gocc eq "1" || $gomf eq "1")
{
	go2term();
	if($gobp eq "1")
	{
		%bpg2go=();
		go("$dir/GO/g2bp.txt","bpg2go");
		%bpgo2g=();
		go("$dir/GO/bp2g.txt","bpgo2g");
	}
	if($gocc eq "1")
	{
		%ccg2go=();
		go("$dir/GO/g2cc.txt","ccg2go");
		%ccgo2g=();
		go("$dir/GO/cc2g.txt","ccgo2g");
	}
	if($gomf eq "1")
	{
		%mfg2go=();
		go("$dir/GO/g2mf.txt","mfg2go");
		%mfgo2g=();
		go("$dir/GO/mf2g.txt","mfgo2g");
	}
}

if( $module eq "1")
{
        print "module ...\n";
	%c_node=();
	%n_node=();
	%minfo=();
	%cc_edge=();
	%nn_edge=();
	%nc_edge=();
	system("rm -rf $dir/Module_fun_dir") if (-d "$dir/Module_fun_dir");
	system("mkdir $dir/Module_fun_dir");


	open(mod,">>$dir/Module_function") or die $!;
	$mod_num=0;
	opendir(nodes, "$dir/Module_node");
	while($nodef=readdir(nodes))
	{
		if(!grep(/^\./,$nodef))
		{
                        print $nodef, "\n";
			$mod=(split(/_/,$nodef))[0];
			open(module,"$dir/Module_node/$nodef");

			@genes=();
			$i=0;
			while(<module>)
			{
				chomp;
				$genes[$i]=$_;
				$i++;
			}
			close(module);
			%sig=();
			$siginfo="";
			if($gobp eq "1")
			{
				%sigtmp=enrich("bpg2go","bpgo2g","genes",$gene_cutoff,$pv_cutoff,"GOBP");
#                                print "\%sigtmp = ", keys(%sigtmp), "\n";
				$siginfo=$siginfo.";".$sigtmp{"siginfo"} if( $sigtmp{"siginfo"} ne "");
				%sig=(%sig,%sigtmp);
			}
			if($gocc eq "1")
			{

				%sigtmp=enrich("ccg2go","ccgo2g","genes",$gene_cutoff,$pv_cutoff,"GOCC");
				$siginfo=$siginfo.";".$sigtmp{"siginfo"} if( $sigtmp{"siginfo"} ne "");
				%sig=(%sig,%sigtmp);
#print $mod."\t".$siginfo."\n" if($sig ne "");

			}
			if($gomf eq "1")
			{
				%sigtmp=enrich("mfg2go","mfgo2g","genes",$gene_cutoff,$pv_cutoff,"GOMF");
				$siginfo=$siginfo.";".$sigtmp{"siginfo"} if( $sigtmp{"siginfo"} ne "");
				%sig=(%sig,%sigtmp);
#print $mod."\t".$siginfo."\n" if($sig ne "");

			}

			if($siginfo ne "")
			{
				$moduleinfo2{$mod}=$minfo{$mod}."\t".substr($siginfo,1);
				$mod_num++;
				open(res,">$dir/Module_fun_dir/$mod.txt");
				foreach $k (sort hashValueAscendingNum(keys(%sig)))
				{
					my @token=split(/\t/,$sig{$k});
#                                        print $sig{$k}, "\n";
					print res join("\t", $token[0], $token[1], $token[2], $token[5]), "\n" if ($k ne "siginfo");
				}	
                                close(res);
                        
                        	foreach $gene(@genes) {
                        		if ($gene =~ m/_[kn]n$/) {
                                		$gene =~ s/_[kn]n$//;
                                        	copy("$dir/Module_fun_dir/$mod.txt", "$dir/Module_fun_dir/${gene}_M$mod.txt");
                                	}
                        	}
                                unlink "$dir/Module_fun_dir/$mod.txt";
			}
		}
	}
	closedir(nodes);
	print mod "module_fun\t$mod_num\n";
	close(mod);
}
if($hub eq "1")
{
	%c_node=();
	%n_node=();
	%hubinfo=();
	%cc_edge=();
	%nn_edge=();
	%nc_edge=();

	system("rm -rf $dir/Hub_fun_dir") if (-d "$dir/Hub_fun_dir");
	system("mkdir $dir/Hub_fun_dir");
	opendir(hubdir,"$dir/Hub_node");
	while( $nc=readdir(hubdir))
	{
		if(!grep(/^\./,$nc))
		{
                        print $nc, "\n";
                        $name = $nc;
			@genes=();
			open(hub,"$dir/Hub_node/$nc");
			while(<hub>)
			{
				chomp;
				push (@genes,$_) if($_ ne $nc);

			}
			close(hub);
			$nc=~s/_[kn]n$//g;

			%sig=();
			$siginfo="";
			if($gobp eq "1")
			{
				%sigtmp=enrich("bpg2go","bpgo2g","genes",$hub_cutoff,$pv_cutoff,"GOBP");
				$siginfo=$siginfo.";".$sigtmp{"siginfo"} if( $sigtmp{"siginfo"} ne "");
				%sig=(%sig,%sigtmp);
#                                print join("\t", keys(%sig)), "\n";
			}
			if($gocc eq "1")
			{

				%sigtmp=enrich("ccg2go","ccgo2g","genes",$hub_cutoff,$pv_cutoff,"GOCC");
				$siginfo=$siginfo.";".$sigtmp{"siginfo"} if( $sigtmp{"siginfo"} ne "");
				%sig=(%sig,%sigtmp);
#print $mod."\t".$siginfo."\n" if($sig ne "");

			}
			if($gomf eq "1")
			{
				%sigtmp=enrich("mfg2go","mfgo2g","genes",$hub_cutoff,$pv_cutoff,"GOMF");
				$siginfo=$siginfo.";".$sigtmp{"siginfo"} if( $sigtmp{"siginfo"} ne "");
				%sig=(%sig,%sigtmp);
#print $mod."\t".$siginfo."\n" if($sig ne "");

			}

			if($siginfo ne "")
			{
				open(res,">$dir/Hub_fun_dir/$nc.txt");
				foreach $k (sort hashValueAscendingNum(keys(%sig)))
				{
					my @token=split(/\t/,$sig{$k});
					print res join("\t", $token[0], $token[1], $token[2], $token[5]), "\n" if ($k ne "siginfo");
				}	
				close res;
			} else {
                             unlink  "$dir/Hub_node/$name" if (-e "$dir/Hub_node/$name");
                             unlink  "$dir/Hub_edge/$name" if (-e "$dir/Hub_edge/$name");
                        }

		}
	}
}


sub logfact {
	return gammln(shift(@_) + 1.0);
}

sub hypergeom {
# There are m "bad" and n "good" balls in an urn.
# Pick N of them. The probability of i or more successful selection+s:
# (m!n!N!(m+n-N)!)/(i!(n-i)!(m+i-N)!(N-i)!(m+n)!)
	my ($n, $m, $N, $i) = @_;
	my $loghyp1 = logfact($m)+logfact($n)+logfact($N)+logfact($m+$n-$N);
	my $loghyp2 = logfact($i)+logfact($n-$i)+logfact($m+$i-$N)+logfact($N-$i)+logfact($m+$n);
	return exp($loghyp1 - $loghyp2);
}

sub gammln {
	my $xx = shift;
	my @cof = (76.18009172947146, -86.50532032941677,
			24.01409824083091, -1.231739572450155,
			0.12086509738661e-2, -0.5395239384953e-5);
        $xx = 1 if ($xx <= 0);
	my $y = my $x = $xx;
 #       print $y, "\n";
	my $tmp = $x + 5.5;
	$tmp -= ($x + .5) * log($tmp);
	my $ser = 1.000000000190015;
	for my $j (0..5) {
		$ser += $cof[$j]/++$y;
	}
	-$tmp + log(2.5066282746310005*$ser/$x);
}

#print hypergeom(325,13895-325,260,7),"\n";
sub intersect{

	my @intersection = ();
	my %count = ();

	foreach $element (@{$_[0]},@{$_[1]}) { $count{$element}++ }
	foreach $element (keys %count) {
#push @union, $element;

		push @intersection, $g2symbol{$element} if($count{$element} > 1);
	}
	return @intersection;
}

sub hashValueAscendingNum {

	$av=(split(/\t/,$sig{$a}))[5];
	$bv=(split(/\t/,$sig{$b}))[5];	
	$av <=> $bv;

}
sub hashsort12 {

	$sortfc{$a}<=>$sortfc{$b};
}
sub hashsort21 {

	$sortfc{$b}<=>$sortfc{$a};
}

