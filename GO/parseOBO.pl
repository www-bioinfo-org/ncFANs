#!/usr/bin/perl

use warnings;
use strict;

my $file = shift @ARGV;
my $output = shift @ARGV;

open FH, $file or die $!;
open OUT, ">$output" or die $!;
my ($id, $name, $namespace);     
my $count = 1;
while (<FH>) {
    if (m/^\[Term\]/) {
        $id = <FH>;
        chomp $id;
        $id =~ s/id:\s*//;
        $name = <FH>;
        chomp $name;
        $name =~ s/name:\s*//;
        $namespace = <FH>;
        chomp $namespace;
        $namespace =~ s/namespace:\s*//;
        if ($namespace eq "biological_process") {
            $namespace = "Process";
        } elsif ($namespace eq "molecular_function") {
            $namespace = "Function";
        } else {
            $namespace = "Component";
        }
        print OUT $count++, "\t", $id, "\t", $namespace, "\t", $name, "\n";
    } else {
        next;
    }
}
close FH;
close OUT;
