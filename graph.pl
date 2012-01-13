#!/usr/bin/perl -w

use warnings;
use Chart::Strip;
use DBI;
use Date::Manip;
use strict;
use CGI qw/:standard/;

#sub graph{
#my($stat,$duration,@callsigns)=@ARGV;
my $query=new CGI;

my $stat=$query->param('stat');
my $duration=$query->param('duration');
my @callsigns=$query->param('callsigns');

#hardcoded values for testing
$stat="drn_kills";
$duration="past_week";
@callsigns=("fwiffo");
##############################

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

my $img = Chart::Strip->new(title   => $stat,
			    x_label => '',
			    y_label => '',
			    transparent => 0,
			    );

my $color;
my @colors=("000000","0000FF","00FF00","00FFFF","FF0000","FF6600","FF00FF");
my $num_colors=@colors;

sub fisher_yates_shuffle {
	my $deck = shift;  # $deck is a reference to an array
    my $i = @$deck;
    while ($i--) {
		my $j = int rand ($i+1);
        @$deck[$i,$j] = @$deck[$j,$i];
    }
}

&fisher_yates_shuffle(\@colors);

foreach my $callsign (@callsigns) {
	my $sth;
	my $duration_str;

	if($duration eq 'past_week'){
		$duration_str='AND timestamp > (now() - interval 1 week)';
	}elsif($duration eq 'past_month'){
		$duration_str='AND timestamp > (now() - interval 1 month)';
	}else{
		$duration_str=' ';
	}

	my $query="select timestamp,".$stat." from stats where callsign=\'".$callsign."\' ".$duration_str." order by timestamp";

	$sth=$dbh->prepare($query);

	$sth->execute();

	my($data);
	my $once=1;
	my($zeroed_stat)=0;

	while(my($timestamp,$chosen_stat)=$sth->fetchrow_array()){
		if($once==1 && $duration =~ /past_/ ){
			$zeroed_stat=$chosen_stat;
			$once=0;
		}
		$chosen_stat=$chosen_stat-$zeroed_stat;
		my $unixdate=UnixDate(ParseDate($timestamp),"%s");
		push @$data, {time => $unixdate, value => $chosen_stat};
	}

	$color=pop(@colors);
	if(!defined($color)){
		print "too many callsigns (>$num_colors), ran out of colors!\n";
		exit;
	}
	
	$img->add_data( $data, { label => $callsign, style => 'line',   color => $color } );

#debugging output to stdout
#	print "$callsign\n";
#	foreach my $item (@$data){
#		print "$$item{'time'} $$item{'value'}\n";
#	}

}


binmode STDOUT;
#remember to comment the next line if you want to output filesystem and view the png
#print $query->header("image/png");
print $img->png();

