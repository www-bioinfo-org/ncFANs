#!/usr/bin/perl
use warnings;
use strict;
use POSIX;

my $file = shift @ARGV;

open FH, $file or die $!;

my (%code, %noncode1, %noncode2, %nnoncode1, %nnoncode2, %edges);
my @tmp;
my ($coding, $nc1, $nc2, $nn1, $nn2) = (0, 0, 0, 0, 0);
my ($ccedge, $ncedge1, $ncedge2, $nnedge1, $nnedge2) = (0, 0, 0, 0, 0);
my ($pcc_cc, $pcc_nc1, $pcc_nc2, $pcc_nn1, $pcc_nn2) = (0, 0, 0, 0, 0);

while (<FH>) {
    chomp;
    @tmp = split /\t/;
    if ($tmp[0] =~ m/_c$/) {
        $code{$tmp[0]} = 1;
    } elsif ($tmp[0] =~ m/_kn$/) {
        if (rand(1) < 0.5) {
            $noncode1{$tmp[0]} = 1 unless (exists($noncode2{$tmp[0]}));
        } else {
            $noncode2{$tmp[0]} = 1 unless (exists($noncode1{$tmp[0]}));
        }
    } else {
        if (rand(1) < 0.5) {
            unless (exists($noncode2{$tmp[0]})) {
                $noncode1{$tmp[0]} = 1;
                $nnoncode1{$tmp[0]} = 1;
            } 
        } else {
            unless (exists($noncode1{$tmp[0]})) {
                $noncode2{$tmp[0]} = 1;
                $nnoncode2{$tmp[0]} = 1;
            }
        }
    }
    if ($tmp[1] =~ m/_c$/) {
        $code{$tmp[1]} = 1;
    } elsif ($tmp[1] =~ m/_kn$/) {
        if (rand(1) < 0.5) {
            $noncode1{$tmp[1]} = 1 unless (exists($noncode2{$tmp[1]}));
        } else {
            $noncode2{$tmp[1]} = 1 unless (exists($noncode1{$tmp[1]}));
        }
    } else {
        if (rand(1) < 0.5) {
            unless (exists($noncode2{$tmp[1]})) {
                $noncode1{$tmp[1]} = 1;
                $nnoncode1{$tmp[1]} = 1;
            } 
        } else {
            unless (exists($noncode1{$tmp[1]})) {
                $noncode2{$tmp[1]} = 1;
                $nnoncode2{$tmp[1]} = 1;
            }
        }
    }
    $edges{join("\t", @tmp[0..1])} = $tmp[2];
}
close FH;

open NC1, ">${file}_1" or die $!;
open NC2, ">${file}_2" or die $!;
while (my ($edge, $cor) = each(%edges)) {
    @tmp = split /\t/, $edge;
    if ($tmp[0] =~ /_c$/ && $tmp[1] =~ /_c$/) {
        print NC1 join("\t", $edge, $cor), "\n";
        print NC2 join("\t", $edge, $cor), "\n";
        $ccedge ++;
        $pcc_cc = $pcc_cc + $cor;
    } elsif ($tmp[0] =~ /_c$/ || $tmp[1] =~ /_c$/) {
        if (exists($noncode1{$tmp[0]})) {
            print NC1 join("\t", $edge, $cor), "\n";
            $ncedge1 ++;
            $pcc_nc1 = $pcc_nc1 + $cor;
        }
        if (exists($noncode2{$tmp[0]})) {
            print NC2 join("\t", $edge, $cor), "\n";
            $ncedge2 ++;
            $pcc_nc2 = $pcc_nc2 + $cor;
        }
        if (exists($noncode1{$tmp[1]})) {
            print NC1 join("\t", $edge, $cor), "\n";
            $ncedge1 ++;
            $pcc_nc1 = $pcc_nc1 + $cor;
        }
        if (exists($noncode2{$tmp[1]})) {
            print NC2 join("\t", $edge, $cor), "\n";
            $ncedge2 ++;
            $pcc_nc2 = $pcc_nc2 + $cor;
        }
    } else {
        if (exists($noncode1{$tmp[0]}) && exists($noncode1{$tmp[1]})) {
            print NC1 join("\t", $edge, $cor), "\n";
            $nnedge1 ++;
            $pcc_nn1 = $pcc_nn1 + $cor;
        }
        if (exists($noncode2{$tmp[0]}) && exists($noncode2{$tmp[1]})) {
            print NC2 join("\t", $edge, $cor), "\n";
            $nnedge2 ++;
            $pcc_nn2 = $pcc_nn2 + $cor;
        }
    }
}
close NC1;
close NC2;

open NC1, ">${file}_1.info" or die $!;
$coding=keys(%code);
$nc1=keys(%noncode1);
$nn1=keys(%nnoncode1);
$nc1 = $nc1 - $nn1;

print NC1 "Number of known coding gene nodes\t$coding\n";
print NC1 "Number of known lincRNA gene nodes\t$nn1\n";
print NC1 "Number of novel lincRNA gene nodes\t$nn1\n";
print NC1 "Number of coding-coding(cc) edges\t$nn1\n";
print NC1 "Number of coding-coding(cc) edges\t$ccedge1\n";
print NC1 "Number of noncoding-noncoding(nn) edges\t$nnedge\n";
if ($coding > 0) {
    print NC1 "the mean of PCC of cc edges\t", $pcc_cc / $ccedge, "\n";
}
if ($nn1 > 0) {
    print NC1 "the mean of PCC of nn edges\t", $pcc_nn1 / $nnedge1, "\n";
}
if ($nc1 > 0) {
    print NC1 "the mean of PCC of nc edges\t", $pcc_nc1 / $ncedge1, "\n";
}
close NC1;

open NC2, ">${file}_2.info" or die $!;
$nc2=keys(%noncode2);
$nn2=keys(%nnoncode2);
$nc2 = $nc2 - $nn2;
print NC2 "Number of known coding gene nodes\t$coding\n";
print NC2 "Number of known lincRNA gene nodes\t$nn2\n";
print NC2 "Number of novel lincRNA gene nodes\t$nn2\n";
print NC2 "Number of coding-coding(cc) edges\t$nn2\n";
print NC2 "Number of coding-coding(cc) edges\t$ccedge2\n";
print NC2 "Number of noncoding-noncoding(nn) edges\t$nnedge\n";
if ($coding > 0) {
    print NC2 "the mean of PCC of cc edges\t", $pcc_cc / $ccedge, "\n";
}
if ($nn2 > 0) {
    print NC2 "the mean of PCC of nn edges\t", $pcc_nn2 / $nnedge2, "\n";
}
if ($nc2 > 0) {
    print NC2 "the mean of PCC of nc edges\t", $pcc_nc2 / $ncedge2, "\n";
}

close NC2;

