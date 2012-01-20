#!/usr/bin/perl

use warnings;
use DBI;
use strict;

my $DEBUG=1;

my $my_cnf = '~/scripts/secret/my_cnf.cnf';

open(my $fh, '>', 'output.txt') or die "cant open $!";

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
#my $query="select * from stats limit 10";
my $sth=$dbh->prepare($query);
$sth->execute();

my @categories = qw/id place callsign mu sigma rank wins losses draws defects stack_rating cmd_mu cmd_sigma cmd_rank cmd_wins cmd_losses cmd_draws kills ejects drn_kills stn_kills stn_caps kills_per_ejects hrs_played kills_per_hr timestamp status lgp/;

#note: &haschanged assumes that the last item is timestamp (pops off last item)
#status and lgp should be ignored as well

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
			#$DEBUG && print "TODO: dumping values from hash to db table...\n";
			#we're gonna dump into a file instead of db table
			$DEBUG && print "dumping old values to file...\n";
			&dumptofile(@row);

			#update all new stats in hash
			$DEBUG && print "updating stats in hash with new values\n";
			my $i=0;
			$DEBUG && print "STORED: ";
			foreach my $item (@categories){
				$stats{$row[2]}{$item}=$row[$i];
				$DEBUG && print "$row[$i],";
				$i++;
			}
			$DEBUG && print "\n";
			
		}else{
			$DEBUG && print "duplicate confirmed\n";
			#this is duplicate
			#update timestamp
			$DEBUG && print "id: $stats{$row[2]}{'id'} is now $row[0]\n";
			$stats{$row[2]}{'id'}=$row[0];
			$stats{$row[2]}{'timestamp'}=$row[-3];
		} 

	}else{
		#callsign doesnt exist
		$DEBUG && print "adding new entry to hash: $row[2]\n";
		my $i=0;
		foreach my $item (@categories){
			$stats{$row[2]}{$item}=$row[$i];
			#print "$row[2] : $item $row[$i]\n";
			$i++;
		}
		$DEBUG && print "dumping to file\n";
		$"=',';
		print $fh "@row\n";
		$"=' ';
	}
}

sub haschanged {
#returns 0 if all stats except timestamp,status,lgp have not changed
#returns 1 if any stats except timestamp,status,lgp have changed
	my @row = @_;

	my $callsign=$row[2];

	my $i=3; #ignoring first three fields (id,place,callsign)
	foreach my $item (@categories){
		if($item =~/id|place|callsign|timestamp|status|lgp/){
		#skip the stuff that wouldnt make the stats different
			next;
		}
		if($stats{$callsign}{$item} != $row[$i]){
			$DEBUG && print "hash stored value ($item): $stats{$callsign}{$item} \t encountered value: $row[$i]\n";
			return 1;
		}
		$i++;
	}
return 0;
}

sub dumptofile {
	my @row = @_;
	my $output = "=";
	foreach my $item (@categories){
		$output = $output . "$stats{$row[2]}{$item},";
	}
	chop($output); #remove that last comma
	$DEBUG && print "DUMPED: $output\n";
	print $fh "$output\n";
}
