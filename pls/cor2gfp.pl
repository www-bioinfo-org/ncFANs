%codinglist;
%nclist;
%network;
$thresHold = 0;
$mydir = $ARGV[0];
$nclistFile = $mydir."/nc.list";
$codinglistFile = $mydir."/coding.list";
$networkFile = $mydir."/network";
$CELFile= $ARGV[1];
open CEL,$CELFile;
@lns = <CEL>; chomp @lns;
close CEL;
for($i = 0; $i < @lns; $i ++){
        @edge = split(/\t/,$lns[$i]);
        if($edge[2] >= $thresHold){
	        $pA = substr($edge[0],0,rindex($edge[0],'_'));
	        $pB = substr($edge[1],0,rindex($edge[1],'_'));
	        if($edge[0] =~ m/_[kn]n$/){
	                if(!$nclist{$pA}){
	                        $nclist{$pA} = 1;
	                }
	        }else{
	                if(!$codinglist{$pA}){
	                        $codinglist{$pA} = 1;
	                }
	
	        }
	        if($edge[1] =~ m/_[kn]n$/){
	                if(!$nclist{$pB}){
	                        $nclist{$pB} = 1;
	                }
	        }else{
	                if(!$codinglist{$pB}){
	                        $codinglist{$pB} = 1;
	                }
	
	        }
	        $k1 = $pA.'-'.$pB;
	        $network{$k1} = $edge[2];
#	        $k2 = $pB.'-'.$pA;
#	        if(!$network{$k1} and !$network{$k2}){
#	                if($edge[2] > 0.7){
#	                	$network{$k1} = $edge[2];
#			}
#	        }
	}else{
	}
}
open CODINGH,'>'.$codinglistFile;
for $k (keys %codinglist){
        print CODINGH $k."\n";
}
close CODINGH;

open NCH,'>'.$nclistFile;
for $k (keys %nclist){
        print NCH $k."\n";
}
close NCH;

open NETH,'>'.$networkFile;
for $k (keys %network){
        @ps = split(/-/,$k);
        print NETH $ps[0]."\t".$ps[1]."\t".$network{$k}."\n";
        #print NETH $ps[0]."\t".$ps[1]."\n";
}
close NETH;

