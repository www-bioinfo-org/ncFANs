#!/usr/bin/perl
use warnings;
use strict;

#my $term = "GO/term.txt";
my $file = shift @ARGV;
my $dir = shift @ARGV;
my $term = shift @ARGV;

open FH, $term or die $!;
my %id;
my %type;
while (<FH>) {
#    print $_;
    chomp;
    my @tmp = split /\t/, $_;
#    foreach (@tmp) {
#        print $_, "\n";
#    }
    $id{$tmp[1]} = $tmp[0];
    $type{$tmp[1]} = $tmp[2];
}
close FH;
#print scalar(keys(%id)), "\t", scalar(keys(%type)), "\n";


open FH, $file or die $!;
my (%g2bp, %g2mf, %g2cc, %bp2g, %mf2g, %cc2g);
my $head = <FH>;
while (<FH>) {
    chomp;
    my @tmp = split /\t/, $_;
#    print "# $.\n";
    next unless (exists($tmp[0]) && exists($tmp[1]));
    if (exists($type{$tmp[1]}) && exists($id{$tmp[1]})) {
        if ($type{$tmp[1]} eq "Process") {
            insert(\%g2bp, $tmp[0], $id{$tmp[1]});
            insert(\%bp2g, $id{$tmp[1]}, $tmp[0]);
        } elsif ($type{$tmp[1]} eq "Function") {
            insert(\%g2mf, $tmp[0], $id{$tmp[1]});
            insert(\%mf2g, $id{$tmp[1]}, $tmp[0]);
        } else {
            insert(\%g2cc, $tmp[0], $id{$tmp[1]});
            insert(\%cc2g, $id{$tmp[1]}, $tmp[0]);
        }
    } else {
#        print STDERR "${tmp[1]} is not existing.\n";
    }
}
close FH;
print "hash..\n";
print "Process: ", scalar(keys(%g2bp)), "\t", scalar(keys(%bp2g)), "\n";
print "Function: ", scalar(keys(%g2mf)), "\t", scalar(keys(%mf2g)), "\n";
print "Component: ", scalar(keys(%g2cc)), "\t", scalar(keys(%cc2g)), "\n";


#$dir = "$wd/$dir";
#print $dir, "\n";
write2file("$dir/g2bp.txt", \%g2bp);
write2file("$dir/bp2g.txt", \%bp2g);
write2file("$dir/g2mf.txt", \%g2mf);
write2file("$dir/mf2g.txt", \%mf2g);
write2file("$dir/g2cc.txt", \%g2cc);
write2file("$dir/cc2g.txt", \%cc2g);



sub insert {
    my $hash = shift @_;
    my $key = shift @_;
    my $value = shift @_;
    if (exists(${$hash}{$key})) {
        ${$hash}{$key} = ${$hash}{$key} . ";$value";
    } else {
        ${$hash}{$key} = $value;
    }
#    print "insert: ", scalar(keys(%hash)), "\n";
}

sub write2file {
    my $file = shift @_;
    my $hash = shift @_;
    open FH, ">$file" or die $!;
    foreach (sort keys(%{$hash})) {
        print FH $_, "\t", $hash->{$_}, "\n";
    }
    close FH;
}

