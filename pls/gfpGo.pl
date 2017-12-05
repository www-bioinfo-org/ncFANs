#!/usr/bin/perl
use warnings;
use strict;

use Cwd 'abs_path';
my $realPath=abs_path($0);
my $position=index($realPath,"pls/gfpGo.pl");
$position=$position-1;
my $subposition=substr($realPath,0,$position);
#print "$subposition\n";


my $term = $subposition."/GO/term.txt";
#my $term = "GO/term.txt";
print "$term\n";

my $file = shift @ARGV;
my $dir = shift @ARGV;


open FH, $term or die $!;

open BP, ">$dir/gfpData/bp.txt" or die $!;
open MF, ">$dir/gfpData/mf.txt" or die $!;
open CC, ">$dir/gfpData/cc.txt" or die $!; 
my %type;
while (<FH>) {
    chomp;
    my @tmp = split /\t/, $_;
    $type{$tmp[1]} = $tmp[2];
    if ($tmp[2] eq "Process") {
        print BP "$tmp[1]\t$tmp[3]\n";
    } elsif ($tmp[2] eq "Function") {
        print MF "$tmp[1]\t$tmp[3]\n";
    } else {
        print CC "$tmp[1]\t$tmp[3]\n";
    }
}
close FH;
close BP;
close MF;
close CC;


open FH, $file or die $!;
open BP, ">$dir/gfpData/g2bp.txt" or die $!;
open MF, ">$dir/gfpData/g2mf.txt" or die $!;
open CC, ">$dir/gfpData/g2cc.txt" or die $!; 
my $head = <FH>;
while (<FH>) {
    chomp;
    my @tmp = split /\t/, $_;
    next unless (exists($tmp[0]) && exists($tmp[1]));
    if (exists($type{$tmp[1]})) {
        if ($type{$tmp[1]} eq "Process") {
            print BP join("\t", @tmp), "\n";
        } elsif ($type{$tmp[1]} eq "Function") {
            print MF join("\t", @tmp), "\n";
        } else {
            print CC join("\t", @tmp), "\n";
        }
    } else {
#        print STDERR "${tmp[1]} is not existing.\n";
    }
}
close FH;
close BP;
close MF;
close CC;
