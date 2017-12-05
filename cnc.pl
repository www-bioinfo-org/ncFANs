#!/usr/bin/perl

=head1 NAME

cnc.pl - constructing coding-noncoding coexpression network

=head1 SYNOPSIS

Use:

    perl cnc.pl [options] -g <gene_list.txt> -e <gene_expression.txt>

Examples:

    perl cnc.pl --help

    perl cnc.pl -s 0.2 -g gene_list.txt -e gene_expression.txt


=head1 DESCRIPTION

This script is part of the ncFANs pipeline. The script uses gene expression
profile to construct a coding-noncoding coexpression network.

=head1 ARGUMENTS

cnc.pl takes the following arguments:

=over 4

=item gene list

  -g <gene_list.txt>
 
(Required.) The path of gene list file. Note that,
gene list file must contain two columns. The first is gene id and 
the second is gene type (c, kn or nn).

=item gene epxression file
  
  -e <gene_expression.txt>

(Required.) The path of gene expression file. Note than, row names
and column names are required.

=item network size

  -d

(Optional.) Network size can be "s"(small), "m"(medium) or "l"(large).
A small network has mean degree around 15, medium is 50 and large is 100.
Default is small.

=item ratio

  -r 

(Optional.) Randomly split the lincRNA genes into defined ratio (# lincRNA genes /
# protein-coding genes, the default is 0.2). If s was given 0, the lincRNA genes
would not be splitted.

=item PCC step size

  -s

(Optional.) The default is 10, step size = (1-max(0.6, minimun correlation))/10.

=item top genes

  -t

(Optional.) Probability of the correlation distribution for each genes. Default 
is 0.01.

=item adjusted p-value

  -p

(Optional.) adjusted p-value of each PCC by the Bonferroni method. 
The default is 0.01.

=item output directory

  -o

(Optional.) The path of output directory. The dafault is the path of current
working directory. 

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


use strict;
use warnings;
use Getopt::Long;    #   Resist name-space pollution!
use Pod::Usage;      #   Ditto!
use POSIX;

#   Check arguments.

my( $list, $expression, $ratio, $step, $top, $size,
    $adjusted, $dir, $help );
    

GetOptions(
    'g=s'    => \$list,
    'e=s'    => \$expression,
    'r=f'    => \$ratio,
    's=i'    => \$step,
    'd=s'    => \$size,
    't=f'    => \$top,
    'p=f'    => \$adjusted,
    'o=s'    => \$dir,
    'help'   => \$help);

#   Check for requests for help or for man (full documentation):

pod2usage(-verbose => 1) if ($help);

#   Check for required variables.

unless (defined($list) && defined($expression))
{
    pod2usage(-exitstatus => 2);
}

#   Check for optional variables.

#   Option r
if (defined($ratio)) {
    if ($ratio < 0 ) {
        my $message = "Vaule \"$ratio\" invalid for option r. (number >= 0 expected)";
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $ratio = 0.2;
}

my $avgdegree = 15;
if (defined($size)) {
   $size = lc($size);
   if ($size eq "s") {
       $avgdegree = 15;
   } elsif ($size eq "m") {
       $avgdegree = 50;
   } elsif ($size eq "l") {
       $avgdegree = 100;
   } else {
        my $message = "Vaule \"$size\" invalid for option d. (\"s\", \"m\" or \"l\" expected)";
        pod2usage(-msg     => \$message,
                  -exitval => 2);
   }
} 
 
#   Option s
if (defined($step)) {
    if ($step <= 0) {
        my $message = "Value \"$step\" invalid for option s. (positive integer expected)";
        pod2usage(-msg     => \$message,
                  -exitval => 2);
    }
} else {
    $step = 10;
}

#   Option t
if  (defined($top)) {
    if ($top <= 0 || $top > 1) {
        my $message = "Value \"$top\" invalid for option t. (number in (0, 1] expected)"; 
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $top = 0.01;
}
#   Option p
if  (defined($adjusted)) {
    if ($adjusted <= 0 || $adjusted > 1) {
        my $message = "Value \"$adjusted\" invalid for option p. (number in (0, 1] expected)";
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $adjusted = 0.01;
}

#   Option d
if (defined($dir)) {
    mkdir $dir or die "Can't create directory \"$dir\"" unless (-d $dir);
} else {
    $dir = getcwd();
}
$dir =~ s/\/$//;

#   Get gene type from gene list file

my %genes;
my $coding = 0;
my $noncoding = 0;
my $novel = 0;

#   Confirm gene list file is not empty
unless (-e $list || -s $list) {
    print "Gene list file: $list is not existing or empty\n";
    exit;
}

unless (-e $expression || -s $expression) {
    print "Expression profile file: $expression is not existing or empty\n";
    exit;
}

open FH, $list or die "Can't open file $list\n";
print "Loading gene list file ...\n";
while (<FH>) {
    chomp;
    my @tmp = split /\t/, $_;
    if (defined($tmp[0]) && defined($tmp[1]) ) {
        $genes{$tmp[0]} = $tmp[1];
        if ($tmp[1] eq "c") {
            $coding++;
        } elsif ($tmp[1] eq "kn") {
            $noncoding++;
        } elsif ($tmp[1] eq "nn") {
            $novel++;
        } else {
            print STDERR "In $list line:  $.", 
                         " invalid gene type \" $tmp[1], \".\n";
            exit;
        }
    } else {
        print STDERR "In $list line: $. invalid format.\n";
        exit;
    }
}
close FH;

print "Finish loading gene list file ...\n";
#print "coding = $coding \t noncoding = $noncoding\t novel = $novel\n";



$noncoding = $noncoding + $novel;
my $avg = ceil($coding * $ratio);
my $num;
if ($avg >= $noncoding || $ratio == 0) {
    $num = 1;
    $avg = $noncoding;
} else {
    $num = ceil($noncoding / $avg);
}

#print "avg = $avg \t num = $num\n";

#   Split lincRNA genes

use Cwd 'abs_path';
my $realPath=abs_path($0);
my $position=index($realPath,"cnc.pl");
$position=$position-1;
my $subposition=substr($realPath,0,$position);
print "$subposition\n";
my $Strin="R --slave --args $list $expression $dir < ".$subposition."/Rs/sort.R";
print "$Strin\n";
#system("R --slave --args $list $expression $dir < Rs/sort.R");
system($Strin);

my $message = "Can't create temporary file \"$dir/cexp.tmp\"\n";
open CODING, ">$dir/cexp.tmp" or die $message;
open FH, "$dir/expdata.tmp" or die $!;
my @lines = <FH>;
print CODING shift(@lines); # write column names to cexp.tmp

for (my $i = 0; $i < $coding; $i ++) {
    my @tmp = split /\t/, shift(@lines);
    if (exists($genes{$tmp[0]})) {
        if ($genes{$tmp[0]} eq "c") {
            $tmp[0] = $tmp[0] . "_c";
            print CODING join("\t", @tmp);            
        } else {
           print STDERR "{$tmp[0]} is a noncoding gene.\n";
           exit;
        }
    } else {
        print STDERR "In $dir/expdata.tmp line: $., gene $tmp[0] is", 
                     " not existing in $list.\n";
        exit;
    }
}
close CODING;

print "Constructing network ...\n";
for (my $i = 1; $i <= $num; $i ++) {
    open NCEXP, ">$dir/ncexp$i.tmp" or die "Can't open file \"$dir/ncexp$i.tmp\"\n";
    for (my $j = 0; $j < $avg && $j < $noncoding; $j ++) {
        my $l = shift(@lines);
        my @tmp = split /\t/, $l;
        if (exists($genes{$tmp[0]})) {
            if ($genes{$tmp[0]} eq "kn") {
                $tmp[0] = $tmp[0] . "_kn";
                print NCEXP join("\t", @tmp);
            } elsif ($genes{$tmp[0]} eq "nn") { 
                $tmp[0] = $tmp[0] . "_nn";
                print NCEXP join("\t", @tmp);
            } else {
                print STDERR "gene {$tmp[0]} is a coding gene.\n";
                exit;
            }
        } else {
            print STDERR "In $dir/expdata.tmp line: $., gene {$tmp[0]} is", 
                     " not exist in $list.\n";
            print $l, "\n";
            exit;
        }
    }
    $noncoding = $noncoding - $avg;
    close NCEXP;
}
close FH;

#   Construct the coding-noncoding coexpression network
for (my $i = 1; $i <= $num; $i ++ ) {
    if (-e "$dir/ncexp$i.tmp") {
        print "Constructing network_$i ...\n"; 
        unlink "$dir/cor$i.tmp" if (-e "$dir/cor$i.tmp");
        my $args = "$dir/cexp.tmp $dir/ncexp$i.tmp $dir/cor$i.tmp $top $adjusted"; 
       # print $args, "\n";
        my $Strin="R --slave --args $args < ".$subposition."/Rs/coexp.R";
        #system("R --slave --args $args < Rs/coexp.R");
        print "$Strin\n";
        system($Strin);

        $Strin = "perl ".$subposition."/pls/getcor.pl $dir/cor$i.tmp $dir/network_$i";
        print $Strin;
        #system("perl pls/getcor.pl $dir/cor$i.tmp $dir/network_$i");
        system($Strin);

        open FH, "$dir/network_$i.min" or die $!;
        my $min = <FH>;
        close FH;
        chomp $min;
        unlink "$dir/network_$i.min";
        my @names;
        $min = 0.6 if ($min < 0.6); 
        for (my $s = $min; $s < 1.0; $s = $s + (1 - $min) / $step) {
            my $name = sprintf("network_%d_%f", $i, $s);
            push @names, $name;
            $Strin = "perl ".$subposition."/pls/getnetwork.pl $dir/network_$i $dir/$name $s";
            print "$Strin\n";
            #system("perl pls/getnetwork.pl $dir/network_$i $dir/$name $s");
            system($Strin);
            $Strin = "R --slave --args $dir/$name < ".$subposition."/Rs/score.R";
            print "$Strin\n";
            #system("R --slave --args $dir/$name < Rs/score.R");
            system($Strin);
        }
        my $scale = 0;
        my $best = "";
        my $rate = 100000;
        foreach my $name(@names) {
            open FH, "$dir/$name.score" or die $!;
            my $line = <FH>;
            close FH;
            my @tmp = split /\t/, $line;
            if (abs($avgdegree - $tmp[0]) < $rate) {
                $rate = abs($avgdegree - $tmp[0]);
                if ($tmp[1] > $scale && $tmp[2] < 3) {
                    $scale = $tmp[1];
                    $best = $name;
                }
            }
        }
        if ($scale == 0 && $best eq "") {
            foreach my $name(@names) {
                $Strin = "perl ".$subposition."/pls/splitnetwork.pl $dir/$name";
                #system("perl pls/splitnetwork.pl $dir/$name");
                print "$Strin\n";
                system($Strin);
                
                $Strin = "R --slave --args $dir/${name}_1 < ".$subposition."/Rs/score.R";
                print "$Strin\n";
                #system("R --slave --args $dir/${name}_1 < Rs/score.R");
                system($Strin);
                
                $Strin = "R --slave --args $dir/${name}_2 < ".$subposition."/Rs/score.R";
                print "$Strin\n";
                #system("R --slave --args $dir/${name}_2 < Rs/score.R");
                system($Strin);
            }
        } else {
            foreach my $name(@names) {
                if ($name ne $best) {
                    unlink "$dir/$name", "$dir/$name.info", "$dir/$name.score";
                } else {
                    print $name, "\n";
                    open OUT, ">>$dir/$name.info" or die "Can't open $dir/$name.info";
                    open FH, "$dir/$name.score" or die "Can't open $dir/$name.score";
                    my $line = <FH>;
                    chomp $line;
                    my @tmp = split /\t/, $line;
                    print OUT "\n#  Properties of network\n";
                    print OUT "The mean degree of network\t$tmp[0]\n";
                    print OUT "Scale-free topology criterion\t$tmp[1]\n";
                    print OUT "Gamma\t$tmp[2]\n";
                    close FH;
                    close OUT;
                    unlink "$dir/$name.score";
		    my $newname = substr($name, 0, rindex($name, "_"));
                    print $newname, "\n";
                    unlink "$dir/network_$i";
		    rename "$dir/$name", "$dir/$newname";
		    rename "$dir/$name.info", "$dir/$newname.info";
                }
            }
        }
        unlink "$dir/ncexp$i.tmp", "$dir/cor$i.tmp", "$dir/cor$i.tmp.min";
	print "Finish constructing network_$i.\n";
    }
}

unlink "$dir/cexp.tmp", "$dir/expdata.tmp";
print "Finish constructing co-expression network.\n";

exit(0);
