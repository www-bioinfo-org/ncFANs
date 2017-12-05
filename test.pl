
my $string = "I can learn much form perlcn.com";
my $loc = index($string,"perlcn");
print "$loc\n";

use Cwd 'abs_path';
print abs_path($0)."\n";

$realPath=abs_path($0);
print $realPath;

$position=index($realPath,"test");

print "$position";

