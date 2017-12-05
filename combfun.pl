#!/usr/bin/perl

=head1 NAME

combfun.pl - Combine function prediction results

=head1 SYNOPSIS

Use:

    perl combfun.pl [options] -m <Module_fun_dir> -h <Hub_fun_dir>
                              -g <Global_fun_dir> 

Examples:

    perl combfun.pl --help

    perl combfun.pl -n 10 -m Module_fun_dir -h Hub_fun_dir -g Global_fun_dir


=head1 DESCRIPTION

This script can combine moudule-based, hub-based and global function 
prediction results for lincRNA genes.

=head1 ARGUMENTS

combfun.pl takes the following arguments:

=over 4

=item Module_fun_dir

  -m <Module_fun_dir>
 
(Optional.) The path of module function result directory. More than one
path can be supplied by using comma as delimiter.

=item Hub_fun_dir
  
  -h <Hub_fun_dir>

(Optional.) The path of hub function result directory. More than one
path can be supplied by using comma as delimiter.


=item Global_fun_dir

  -g <Global_fun_dir>

(Optional.) The path of global function result directory. More than one
path can be supplied by using comma as delimiter.


=item Top n GO terms

  -n

(Optional.) Default is get all GO terms for every genes. However, if
-n is selected, the script will get the top n GO terms.

=item output file

  -o

(Optional.) The path of output file. The dafault is combfun.txt in 
the working directory. 

=item help

  --help

(Optional.) Displays the usage message.

=back

=head1 AUTHOR

Li Ming, E<lt>liming@bioinfo.ac.cnE<gt>.

=head1 COPYRIGHT

This program is distributed under the Artistic License.

=head1 DATE

28-Feb-2014

=cut

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;      #   Ditto!
use POSIX;

my ($module, $hub, $global, $number, $output, $help);

GetOptions(
    'm=s'       => \$module,
    'h=s'       => \$hub,
    'g=s'       => \$global,
    'n=i'       => \$number,
    'o=s'       => \$output,
    'help'      => \$help);

#   Check for requests for help or for man (full documentation):

pod2usage(-verbose => 1) if ($help);

#   Check for required variables.

unless (defined($module) || defined($hub) || defined($global))
{
    pod2usage(-exitstatus => 2);
}

#   Check for optional variables.

#   Option n
if (defined($number)) {
    if ($number <= 0 ) {
        my $message = "Value \"$number\" invalid for option n.(positive integer expected)";
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $number = 0;
}

#   Option o
unless (defined($output)) {
    $output = getcwd() . "/combfun.txt";
}


my (%noncode, %mg, %hg, %gg);

if (defined($module)) {
    my @m = split /,/, $module;
    foreach $module (@m) {
        if (-d $module) {
            $module =~ s/\/$//;
            print "Combining $module ...\n";
            parseDir($module, \%noncode, \%mg);
        } else {
            print "$module is not a directory.\n";
            exit;
        }
    }
}

if (defined($hub)) {
    my @h = split /,/, $hub;
    foreach $hub (@h) {
        if (-d $hub) {
            $hub =~ s/\/$//;
            print "Combining $hub ...\n";
            parseDir($hub, \%noncode, \%hg);
        } else {
            print "$hub is not a directory.\n";
            exit;
        }
    }
}

if (defined($global)) {
    my @g = split /,/, $global;
    foreach $global (@g) {
        if (-d $global) {
            $global =~ s/\/$//;
            print "Combining $global ...\n";
            parseDir($global, \%noncode, \%hg);
        } else {
            print "$global is not a directory.\n";
            exit;
        }
    }
}

open FH, ">$output" or die $!;
foreach (sort(keys %noncode)) {
    my $line = $_;
    if (scalar keys(%mg) > 0) {
        if (exists($mg{$_})) {
            $line = $line . "\t" . $mg{$_};
        } else {
            $line = $line . "\t" . "";
        }
    }
    if (scalar keys(%hg)) {
        if (exists($hg{$_})) {
            $line = $line . "\t" . $hg{$_};
        } else {
            $line = $line . "\t" . "";
        }
    }
    if (scalar keys(%gg)) {
        if (exists($gg{$_})) {
            $line = $line . "\t" . $gg{$_};
        } else {
            $line = $line . "\t" . "";
        }
    }
    print FH $line, "\n";
}
close FH;
sub parseDir {
    my $dir = shift @_;
    my $genes = shift @_;
    my $func = shift @_;
    my $gene;
    foreach (glob("$dir/*.txt")) {
        $gene = substr($_, rindex($_, "/") + 1);
        $gene =~ s/\.txt//;
        ${$genes}{$gene} = 1;
        open FH, "$dir/$gene.txt" or die $!;
        my $count = 0;
        while (<FH>) {
            chomp;
            if ($_ eq "") {
                 next;
            }
            s/\t/~/g;
            if (exists(${$func}{$gene})) {
                ${$func}{$gene} = ${$func}{$gene} . ";" . $_;
            } else {
                ${$func}{$gene} = $_;
            }
            if($number > 0 && $count ++ > $number) {
                last;
            }
        }
        close FH;
    }
}
exit(0);
