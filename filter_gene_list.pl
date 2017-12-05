#!/usr/bin/perl


=head1 NAME

filter_gene_list.pl - filtering the expression profile

=head1 SYNOPSIS

Use:

    perl filter_gene_list.pl [options] -g <gene_list.txt> -e <gene_expression.txt>

Examples:

    perl filter_gene_list.pl --help

    perl filter_gene_list.pl -q 0.25 -g gene_list.txt -e gene_expression.txt


=head1 DESCRIPTION

This script is part of the ncFANs pipeline. The script will discard low expression
and small variance genes.

=head1 ARGUMENTS

filter_gene_list.pl takes the following arguments:

=over 4

=item gene list

  -g <gene_list.txt>
 
(Required.) The path of gene list file. Note that,
gene list file must contain two columns. The first is gene id and
the second is gene type (Coding, Noncoding or NovelNoncoding).

=item gene epxression file
  
  -e <gene_expression.txt>

(Required.) The path of gene expression file. Note than, row names
and column names are required.

=item expression evaluation method

  -m

(Optional.) If this option is selected, VST (Variance-Stabilizing-Transformed)
was used as the evaluation method for expression value; Otherwise, fpkm was 
used.

=item minimun expression value of coding genes

  -t 

(Optional.) Expression threshold for coding genes. Coding genes whose
expression value less than the threshold in all samples will be discarded.

=item probability of the population of coding genes expression profile 

  -p

(Optional.) Noncoding genes whose expression value less than p-quantile of
coding genes expression profile in all samples will be discarded.

=item probability of variance population

  -v

(Optional.) Genes whose epxression profile variance less than the v-quantile
of variance will be discarded. The default is 0.25.

=item outliers

  -s

(Optional.) For every gene, if a gene has expression value great than Q3 + s * 
(Q3 - Q1) in one sample, this gene will bed deprecated. The default is 1.5.

=item output directory

  -o
 
(Optional.) Output directory path for result. The default is current directory.

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
use Cwd;

#   Check arguments.

use Cwd 'abs_path';
print abs_path($0)."\n";
#$realPath=abs_path($0);
#print $realPath;
#$position=index($realPath,"filter_gene_list.pl");
#$position=$position-1;
#$subposition=substr($realPath,0,$position);





my( $list, $expression, $method, $threshold, $prob, 
    $variance, $outlier, $dir, $help );
    

GetOptions(
    'g=s'    => \$list,
    'e=s'    => \$expression,
    'm'      => \$method,
    't=f'    => \$threshold,
    'p=f'    => \$prob,
    'v=f'    => \$variance,
    's=f'    => \$outlier,
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

#   Option m
if (defined($method)) {
    $method = "VST";
} else {
    $method = "FPKM";
}

#   Option t
my $th = "yes";
if (defined($threshold)) {
    
    if ($method eq "FPKM" && $threshold < 0) {
        my $message = "Value \"$threshold\" invalid for option t when method is FPKM." .
                      "(number >= 0 expected.)";
        pod2usage(-msg     =>  $message,
                  -exitval => 2);
    }
} else {
    $th = "no"; # // do not filtering
    $threshold = -1;
}

#   Option v
if (defined($variance)) {
    if ($variance < 0 || $variance > 1) {
        my $message = "Value \"$variance\" invalid for option v (number in [0, 1] expected.)";
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $variance = 0.25;
}

#   Option p
if (defined($prob)) {
    if ($prob < 0 || $prob > 1) {
        my $message = "Value \"$prob\" invalid for option p (number in [0, 1] expected.)";
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $prob = -1;
}


#   Option s
if (defined($outlier)) {
    if ($outlier < 0) {
        my $message = "Value \"$outlier\" invalid for option s (number >= 0 expected.)"; 
        pod2usage(-msg     => $message,
                  -exitval => 2);
    }
} else {
    $outlier = 1.5;
}

#   Option d
if (defined($dir)) {
    mkdir $dir or die "Cant't create directory $dir" unless (-d $dir);
} else {
    $dir = getcwd();
}
$dir =~ s/\/$//;

unless ( -e $list || -s $list) {
    print STDERR "Gene list file: $list is not existing or empty.\n";
    exit;
}
unless ( -e $expression || -e $expression) {
    print STDERR "Expression file: $expression is not existing or empty.\n"; 
    exit;
}


my $args = "$list $expression $th $threshold $prob $variance $outlier $dir $method";
#print $args, "\n";

use Cwd 'abs_path';
#print abs_path($0)."\n";

my $realPath=abs_path($0);
my $position=index($realPath,"filter_gene_list.pl");
$position=$position-1;
#print "$position";
my $subposition=substr($realPath,0,$position);
#print "$subposition\n";
my $s;
$s="R --slave --args $args < ".$subposition."/Rs/filter.R";
print "$s";

print "Filtering ...\n";

system($s);

exit(0);
