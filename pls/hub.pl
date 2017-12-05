$network = $ARGV[0];
$dir = $ARGV[1];
$hc = $ARGV[2];

#print $dir, "\n";
mkdir "$dir/Hub_node" unless (-d "$dir/Hub_node");
mkdir "$dir/Hub_edge" unless (-d "$dir/Hub_edge");


open(net,$network);
while(<net>)
{
	chomp;
	my($g1,$g2,$c)=split(/\t/,$_);

	$code{$g1}++ if(grep(/_[kn]n$/,$g1) and grep(/_c$/,$g2));
	$code{$g2}++ if(grep(/_[kn]n$/,$g2) and grep(/_c$/,$g1));
	$g1=~s/_c$//g;
	$g2=~s/_c$//g;
	$link{$g1."\t".$g2}=$c;

	$hub{$g1}{$g2}=0 if(grep(/_[kn]n$/,$g1));
	$hubnc{$g1}++ if(grep(/_[kn]n$/,$g1) and grep(/_[kn]n$/,$g2));	
	$hubco{$g1}++ if(grep(/_[kn]n$/,$g1) and !grep(/_[kn]n$/,$g2));	
	$hub{$g2}{$g1}=0 if(grep(/_[kn]n$/,$g2));	
	$hubnc{$g2}++ if(grep(/_[kn]n$/,$g1) and grep(/_[kn]n$/,$g2));	
	$hubco{$g2}++ if(!grep(/_[kn]n$/,$g1) and grep(/_[kn]n$/,$g2));
}
close(net);
#open(hubinfo,">$dir/Hub_info");
#print hubinfo "id\t#coidng genes\n";
while(my($k,$v)=each(%hub))
{
#        print $k, "\t", $code{$k}, "\n";
	if($code{$k}>=$hc)
	{
	@nodes=keys(%{$hub{$k}});
#	push(@nodes,$k);
	open(node,">$dir/Hub_node/$k");

	open(edge,">$dir/Hub_edge/$k");
#	$ncncedge_len=0;		
#	$nccodeedge_len=0;
#	$ccedge_len=0;
	for($i=0;$i<@nodes;$i++)
	{
                if (!grep(/_[kn]n$/, $nodes[$i])) {
			print node $nodes[$i]."\n";
#		for($j=$i+1;$j<@nodes;$j++)
#		{
			if(exists($link{$nodes[$i]."\t".$k}))
			{
			#print edge $k."\t".$nodes[$i]."\t".$link{$nodes[$i]."\t".$k}."\n" ;
			print edge $k."\t".$nodes[$i]."\n";
			}
			if(exists($link{$k."\t".$nodes[$i]}))
			{
			#print edge $k."\t".$nodes[$i]."\t".$link{$k."\t".$nodes[$i]}."\n" ;
			print edge $k."\t".$nodes[$i]."\n";
			}
#		}
		}
	}
#	print node $nodes[$i]."\n";
#	print hubinfo "$k\t$hubco{$k}\n";

	close(node);
	close(edge);
	}
}
#close(hubinfo);

