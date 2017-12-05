#!/usr/bin/perl

use warnings;
use strict;

use Cwd 'abs_path';
my $realPath=abs_path($0);
my $position=index($realPath,"pls/gfpResult.pl");
$position=$position-1;
my $subposition=substr($realPath,0,$position);
#print "$subposition\n";

my $dir = shift @ARGV;
my $term = $subposition."/GO/term.txt";
#my $term = "GO/term.txt"
print "$term\n";
my @tmp;
my (%name, %type);


open FH, $term or die $!;
while (<FH>) {
    chomp;
    @tmp  = split /\t/, $_;
    $name{$tmp[1]} = $tmp[3]; 
    if ($tmp[2] eq "Process") {
        $tmp[2] = "GOBP";
    } elsif ($tmp[2] eq "Function") {
        $tmp[2] = "GOMF";
    } else {
        $tmp[2] = "GOCC";
    }
    $type{$tmp[1]} = $tmp[2]; 
}
close FH;

if (-e "$dir/NcFuncAnno.result") {
    open FH, "$dir/NcFuncAnno.result" or die $!;
} else {
    print "File $dir/NcFuncAnno.result is not existing.\n";
    exit;
}
my $result_dir = "$dir/Global_fun_dir";
mkdir "$result_dir" unless (-d "$result_dir");
my @lines = <FH>;
chomp @lines;
for (my $i = 0; $i < @lines; $i = $i + 2) {
    my $gene = $lines[$i];
    open OUT, ">$result_dir/${gene}.txt" or die $!;
    my @go_term = split /\t/, $lines[$i + 1];
    for (my $j = 0; $j < @go_term; $j ++) {
        if (exists($name{$go_term[$j]})) {
            print OUT $type{$go_term[$j]}, "\t", $go_term[$j], "\t", 
                      $name{$go_term[$j]}, "\t", $j + 1, "\n";
        } else {
        #    print STDERR "ERROR: Can't find ~~$go_term[$j]~~\n";
        }
    }
    close OUT;
}
close FH;
