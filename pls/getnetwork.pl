#!/usr/bin/perl

use warnings;
use strict;

my $network = shift @ARGV;
my $output = shift @ARGV;
my $min = shift @ARGV;

open FH, $network or die $!;
open OUT, ">$output" or die $!;
my (%code, %noncode, %nnoncode);
my ($cc, $nc, $nn)= (0, 0, 0);
my ($pcc_cc, $pcc_nc, $pcc_nn) = (0, 0, 0);
my @tmp;
while (<FH>) {
    chomp;
    @tmp = split /\t/, $_;
    if ($tmp[2] >= $min) {
        print OUT $_, "\n";

        if ($tmp[0] =~ m/_c$/) {
            $code{$tmp[0]} = 1;
        } elsif ($tmp[0] =~ m/_kn$/) {
            $noncode{$tmp[0]} = 1;
        } else {
            $nnoncode{$tmp[0]} = 1;
        }
    
        if ($tmp[1] =~ m/_c$/) {
            $code{$tmp[1]} = 1;
        } elsif ($tmp[1] =~ m/_kn$/) {
            $noncode{$tmp[1]} = 1;
        } else {
            $nnoncode{$tmp[1]} = 1;
        }
        
        if ($tmp[0] =~ m/_c$/ && $tmp[1] =~ m/_c$/) {
            $cc ++;
            $pcc_cc = $pcc_cc + $tmp[2];
        } elsif ($tmp[0] =~ m/_c$/ || $tmp[1] =~ m/_c$/) {
            $nc ++;
            $pcc_nc = $pcc_nc + $tmp[2];
        } else {
            $nn ++;
            $pcc_nn = $pcc_nn + $tmp[2];
        }
    }
}
close FH;
close OUT;

open OUT, ">$output.info" or die $!;
my ($c_node, $n_node, $nn_node);
if(keys(%code) > 0) {
    $c_node=keys(%code);
} else {
    $c_node = 0;
}	
if(keys(%noncode) > 0) {
    $n_node=keys(%noncode);
} else {
    $n_node = 0;
}
if(keys(%nnoncode) > 0) {
    $nn_node=keys(%nnoncode);
} else {
    $nn_node = 0;
}
print OUT "Number of known coding gene nodes\t$c_node\n";
print OUT "Number of known lincRNA gene nodes\t $n_node\n";
print OUT "Number of novel lincRNA gene nodes\t$nn_node\n";
print OUT "Number of coding-coding(cc) edges\t$cc\n";
print OUT "Number of noncoding-noncoding(nn) edges\t$nn\n";
print OUT "Number of noncoding-coding(nc) edges\t$nc\n";
if ($cc > 0) {
    print OUT "the mean of PCC for cc edges\t", $pcc_cc / $cc, "\n";
}
if ($nn > 0) {
    print OUT "the mean of PCC for nn edges\t", $pcc_nn / $nn, "\n";
}
if ($nc > 0) {
    print OUT "the mean of PCC for nc edges\t", $pcc_nc / $nc, "\n";
}

print OUT "the PCC cutoff is $min\n";
close OUT;
