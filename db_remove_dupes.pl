#!/usr/bin/perl

use warnings;
use DBI;
use strict;

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

my $query="select * from stats limit 10";
my $sth=$dbh->prepare($query);
$sth->execute();

my @categories = qw/mu sigma rank wins losses draws defects stack_rating cmd_mu cmd_sigma cmd_rank cmd_wins cmd_losses cmd_draws kills ejects drn_kills stn_kills stn_caps kills_per_ejects hrs_played kills_per_hr timestamp/;

my %stats;

while(my @row = $sth->fetchrow_array()){
	print "@row\n";
	my $i=3;
	foreach my $item (@categories){
		$stats{$row[2]}{$item}=$row[$i];
		print "$row[2] : $item $row[$i]\n";
		$i++;
	}
}

