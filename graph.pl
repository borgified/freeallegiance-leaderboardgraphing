#!/usr/bin/perl -w

=head1 GRAPH

B<graph.pl> - visual representation of leaderboard stats

=head1 SYNOPSIS
inputs: stat, callsign, duration
stat can be one of (mu,sigma,rank,wins,losses,draws,defects,stack_rating,
cmd_mu,cmd_sigma,cmd_rank,cm_wins,cmd_losses,cmd_draws,kills,ejects,drn_kills,
stn_kills,stn_caps,kills_per_ejects,hrs_played,kills_per_hr)

callsign: up to 7 max or however many colors we can accomodate on a graph
and still be able to distinguish one color from another

duration: past_week,past_month,show_all

=head1 DESCRIPTION
graph.pl - make pretty graphs from collected stats from http://leaderboard.alleg.net
snapshots of the leaderboard are collected regularly and stored into a database
using another script.
=cut

use warnings;
use Chart::Strip;
use DBI;
use Date::Manip;
use strict;
use CGI qw/:standard/;

#sub graph{
#my($stat,$duration,@callsigns)=@ARGV;
my $query=new CGI;

my @stats=$query->param('stats');
my @colors=$query->param('color');
my $duration=$query->param('duration');
my @callsigns=$query->param('callsigns');


#######hardcoded values for testing
@stats=("hrs_played","drn_kills","stn_caps");
$duration="show_all";
@callsigns=("fwiffo","pkunk","spideycw");
##############################

#@stats=('sigma','Sigma','23j',' sigma','drn_kills');
#@stats=(' sigma','drn_kills');
#@callsigns=('fwiffo','jki_kdjf3','$jexit=&','#+=ajaj');
#@colors=('FFFFFF','ZJDKFJ');
##$duration="last_(?{print 'hello';})week";
#$duration="show_all";

#########sanitize inputs

my @known_stats = qw/mu sigma rank wins losses draws defects stack_rating cmd_mu cmd_sigma cmd_rank cmd_wins cmd_losses cmd_draws kills ejects drn_kills stn_kills stn_caps kills_per_ejects hrs_played kills_per_hr/;
my %known_categories;
foreach my $known_stat (@known_stats){
	$known_categories{$known_stat}="";
}
@stats = map { (my $s = $_) =~ s/[^a-z_]*//g; $s} @stats;
foreach my $stat (@stats){
	if(!exists($known_categories{$stat})){
		die "illegal stat: $stat (valid stats: @known_stats)";
	}
}
#----------------------
@colors = map { (my $s =$_) =~ s/[^A-Fa-f0-9]*//g; $s } @colors;
foreach my $color (@colors){
	if(!(hex($color) >= 0 && hex($color) <= 0xFFFFFF)){
		die "color not in range: $color (valid range: 0x000000 - 0xFFFFFF)";
	}
}
#----------------------
if(defined($duration) && $duration ne ''){
	$duration =~ s/[^lastwekmonth_]*//g;
}else{
	die "duration is undefined";
}
if($duration !~ /\blast_week\b|\blast_month\b|\bshow_all\b/){
	die "unrecognized duration: $duration (valid choices: last_week, last_month, show_all)";
}
#----------------------
@callsigns = map {(my $s=$_) =~ s/[^A-Za-z0-9_]*//g; $s } @callsigns;
#----------------------



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

my $img = Chart::Strip->new(
			    x_label => '',
			    y_label => '',
			    transparent => 0,
				draw_data_labels => 1,
				data_label_style => 'box',
				width => '1200',
				height => '600',
			    );


#TODO: implement color picker################
my $color;
#############################################


foreach my $stat (@stats) {
	my $sth;
	my $duration_str;

	if($duration eq 'past_week'){
		$duration_str='AND timestamp > (now() - interval 1 week)';
	}elsif($duration eq 'past_month'){
		$duration_str='AND timestamp > (now() - interval 1 month)';
	}else{
		$duration_str=' ';
	}

	foreach my $callsign (@callsigns) {

		my $query="select timestamp,".$stat." from newstats where callsign=\'".$callsign."\' ".$duration_str." order by timestamp";

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
		$img->add_data( $data, { label => $callsign."(".$stat.")", style => 'line',   color => $color } );
	}
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

