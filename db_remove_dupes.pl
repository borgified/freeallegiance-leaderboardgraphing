#!/usr/bin/perl

use warnings;
use DBI;
use strict;

my $DEBUG=1;

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

my $query="select * from stats where callsign = 'fwiffo' limit 50";
my $sth=$dbh->prepare($query);
$sth->execute();

my @categories = qw/mu sigma rank wins losses draws defects stack_rating cmd_mu cmd_sigma cmd_rank cmd_wins cmd_losses cmd_draws kills ejects drn_kills stn_kills stn_caps kills_per_ejects hrs_played kills_per_hr timestamp/;

#note: &haschanged assumes that the last item is timestamp (pops off last item)


my %stats;

while(my @row = $sth->fetchrow_array()){
	$DEBUG && print "-----------------------------------\n";
	$DEBUG && print "@row\n";

	#does callsign exist? (seen before)
	if(exists($stats{$row[2]}{'mu'})){
		
		$DEBUG && print "callsign exists in hash already\n";
		#have the stats changed from last time?
		if(&haschanged(@row)){
			$DEBUG && print ">>>>>> stats change detected\n";
			#get prev entries from hash and output to db table
			$DEBUG && print "TODO: dumping values from hash to db table...\n";
			#update all new stats in hash
			$DEBUG && print "updating stats in hash\n";
			my $i=3;
			foreach my $item (@categories){
				$stats{$row[2]}{$item}=$row[$i];
				$i++;
			}
			
		}else{
			$DEBUG && print "duplicate confirmed\n";
			#this is duplicate
			#update timestamp
			$stats{$row[2]}{'timestamp'}=$row[-1];
		} 

	}else{
		#callsign doesnt exist
		$DEBUG && print "adding new entry: $row[2]\n";
		my $i=3;
		foreach my $item (@categories){
			$stats{$row[2]}{$item}=$row[$i];
			#print "$row[2] : $item $row[$i]\n";
			$i++;
		}
	}
}

sub haschanged {
#returns 0 if all stats except timestamp have not changed
#returns 1 if any stats except timestamp have changed
	my @row = @_;

	my @categories_no_tstamp = @categories;
	pop(@categories_no_tstamp); #remove the last category, timestamp

	my $callsign=$row[2];

	my $i=3;
	foreach my $item (@categories_no_tstamp){
		if($stats{$callsign}{$item} != $row[$i]){
			$DEBUG && print "hash stored value ($item): $stats{$callsign}{$item} \t encountered value: $row[$i]\n";
			return 1;
		}
		$i++;
	}
return 0;
}

