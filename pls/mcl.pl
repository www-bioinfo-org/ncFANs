
$graph_file = $ARGV[0];
$module_out="$ARGV[1]/module";
$module_out2="$ARGV[1]/module_CEL";

$mc=$ARGV[2]; #
$gc=$ARGV[3]; #
$mp = $ARGV[4];

mkdir "$ARGV[1]/Module_edge" unless (-d "$ARGV[1]/Module_edge");
mkdir "$ARGV[1]/Module_node" unless (-d "$ARGV[1]/Module_node");

open(module,"$module_out");
open(net,$graph_file);
while(<net>)
{
	chomp;
	my($node1,$node2,$c)=split(/\t/,$_);
	$node1=~s/_c$//g;
	$node2=~s/_c$//g;
	$edge{$node1."\t".$node2}=$c;
}
close(net);
open(res,">$module_out2");
$i=1;
open(modinfo,">$ARGV[1]/module_info");
print modinfo "module ID\t#coding nodes\t#noncoding nodes\t#cc edges\t#nn edges\tnc edges\n";
while(<module>)
{

	if(grep(/_[kn]n\t?/,$_))
	{
            my %module_edge;
		chomp;
		@nodes=split(/\t/,$_);
		$cnodes=0;
		foreach my $n(@nodes){ $cnodes++ if(grep(/_c$/,$n));}
		if((scalar @nodes)>=$mc and $cnodes>=$gc)
		{
			$outedge=$i."_edge";
			$outnode=$i."_node";

			open(edge,">$ARGV[1]/Module_edge/$outedge");
			open(node,">$ARGV[1]/Module_node/$outnode");
			$ncnode_len=0;	
			$codenode_len=0;	
			$ncncedge_len=0;		
			$nccodeedge_len=0;
			$ccedge_len=0;
			print res $_."\n";

			for($s=0;$s<@nodes;$s++)
			{
                                if(grep(/_[kn]n$/,$nodes[$s])) {
				    $ncnode_len++ ;
				} else {
                                    $codenode_len++; 
				    $nodes[$s]=~s/_c$//g;	
                                }
				print node $nodes[$s]."\n" ;
				for($j=$s+1;$j<@nodes;$j++)
				{
					$nodes[$j]=~s/_c$//g;	
						if(exists($edge{$nodes[$s]."\t".$nodes[$j]}))
						{

							$ncncedge_len++ if(grep(/_[kn]n$/,$nodes[$s]) and grep(/_[kn]n$/,$nodes[$j]));
							$nccodeedge_len++ if((grep(/_[kn]n$/,$nodes[$s]) and !grep(/_[kn]n$/,$nodes[$j])) or (!grep(/_[kn]n$/,$nodes[$s]) and grep(/_[kn]n$/,$nodes[$j])));
							$ccedge_len++ if(!grep(/_[kn]n$/,$nodes[$s]) and !grep(/_[kn]n$/,$nodes[$j]));

#							print edge $nodes[$s]."\t".$nodes[$j]."\t".$edge{$nodes[$s]."\t".$nodes[$j]}."\n";
							print edge $nodes[$s]."\t".$nodes[$j]."\n";
                                                        $module_edge{$nodes[$s]."\t".$nodes[$j]} = $edge{$nodes[$s]."\t".$nodes[$j]};
						}
					if(exists($edge{$nodes[$j]."\t".$nodes[$s]}))
					{
						$ncncedge_len++ if(grep(/_[kn]n$/,$nodes[$s]) and grep(/_[kn]n$/,$nodes[$j]));
						$nccodeedge_len++ if((grep(/_[kn]n$/,$nodes[$s]) and !grep(/_[kn]n$/,$nodes[$j])) or (!grep(/_[kn]n$/,$nodes[$s]) and grep(/_[kn]n$/,$nodes[$j])));
						$ccedge_len++ if(!grep(/_[kn]n$/,$nodes[$s]) and !grep(/_[kn]n$/,$nodes[$j])) ;
                                                $module_edge{$nodes[$j]."\t".$nodes[$s]} = $edge{$nodes[$j]."\t".$nodes[$s]};
#						print edge $nodes[$j]."\t".$nodes[$s]."\t".$edge{$nodes[$j]."\t".$nodes[$s]}."\n" ;
						print edge $nodes[$j]."\t".$nodes[$s]."\n";
					}

				}


			}
			$ncnode_len++ if(grep(/_[kn]n$/,$nodes[$s]));
			$codenode_len++ if(grep(/_c$/,$nodes[$s]));
                       if(keys(%module_edge) / keys(%edge) < $mp) {
			    print modinfo "$i\t$codenode_len\t$ncnode_len\t$ccedge_len\t$ncncedge_len\t$nccodeedge_len\n";
			    $i++;
			    $nodes[$s]=~s/_c$//g;	
			    print node $nodes[$s];
			   close(node);
			   close(edge);
                       } else {
                          close(node);
			   close(edge);
                           unlink "$ARGV[1]/Module_edge/$outedge", ">$ARGV[1]/Module_node/$outnode";
                       }

		}
	}
}
close(modinfo);
$i=$i-1;
open(mod,">$ARGV[1]/Module_function");
print mod "module_num\t$i\n";
close(mod);
close(module);
close(res);

