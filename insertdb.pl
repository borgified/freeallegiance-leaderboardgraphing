#!/usr/bin/perl

use strict;
use warnings;
use DBI;

my $my_cnf = '~/scripts/secret/my_cnf.cnf';

my $dsn =
  "DBI:mysql:;" .
  "mysql_read_default_file=$my_cnf";

my $dbh = DBI->connect(
    $dsn,
    undef,
    undef,
    {RaiseError => 1}
) or  die "DBI::errstr: $DBI::errstr";

my $filename = 'output.txt';

#read one line to figure out how many fields there are
open(my $fh, '<', $filename) or die "cant open $!";
my @line = split(/,/,<$fh>);
close($fh);

my $query="insert into `newstats` values("."?,"x (@line-1)."?)";

my $sth=$dbh->prepare($query);
#$sth->execute();

#open output.txt for reading each line this time
open($fh, '<', $filename) or die "cant open $!";

while(defined(my $row=<$fh>)){
	#chomp($row);
	#$row=~s/,/','/g;
	#$row="'".$row."'";
	my @row = split(/,/,$row);
	$sth->execute(@row);
}
