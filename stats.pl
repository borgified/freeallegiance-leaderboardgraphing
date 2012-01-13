#!/usr/bin/perl -w
use CGI qw(:standard);
#require "/home/user/svn/asparser/graph.pl";

$query=new CGI;
unless($action=$query->param('submit')){
	$action='none';
}


print header;
print start_html;
$callsigns=$query->param('callsigns');
$stat=$query->param('stat');
$duration=$query->param('duration');

print <<END;
<a href="http://spathiwa.com"><img src="/img/spathi.gif"></a>
<form action="stats.pl" method="post">
<p>use comma to separate multiple callsigns (7 max)
<p>1. callsigns <input type="text" name="callsigns" value="$callsigns" size="80"></p><br>
type in your callsign EXACTLY as it appears on the leaderboard<br>
<p>2. pick ONE stat: <input type="text" id="stat" name="stat" value="$stat" size="12">(graphing multiple stats on the
same graph is not implemented)<br>
stat choices:
<div style="overflow:auto;">
|
END

my @stats=("mu","sigma","rank","wins","losses","draws","defects","stack_rating","cmd_mu","cmd_sigma","cmd_rank","cmd_wins","cmd_losses","cmd_draws","kills","ejects","drn_kills","stn_kills","stn_caps","kills_per_ejects","hrs_played","kills_per_hr");

foreach my $stat (@stats){
	print "<a href=\"#\" onClick=\"document.getElementById('stat').value='$stat'\">$stat</a> | ";
}


print <<END;
</div>
<br>
<p>3. select a duration: <input type="text" name="duration" id="duration" value="$duration" size="10">
| <a href="#" onClick="document.getElementById('duration').value='past_week'">Past Week<a/> | 
<a href="#" onClick="document.getElementById('duration').value='past_week'"><s>Past Month</s><a/> | 
<a href="#" onClick="document.getElementById('duration').value='past_week'"><s>Show All</s><a/> |
<p>
<p><input type="submit" name="submit" value="submit">
</form>
<p>right click on the graph and hit "view image" to save the URL if you want to bookmark it for future reference
END

if($action eq 'submit'){
	$callsigns=$query->param('callsigns');
	$callsigns=~s/\s+//g;
	my @callsigns_array=split(/,/,$callsigns);
	foreach $a (@callsigns_array){
		$callsign_str="&callsigns=$a".$callsign_str;
	}
	$stat=$query->param('stat');
	$stat_str="?stat=$stat";
	$duration=$query->param('duration');
	$duration_str="&duration=$duration";

#	$callsigns=~s/\s+//g;
#	my @callsigns_array=split(/,/,$callsigns);
	#&graph($stat,$duration,@callsigns_array);
	print '<hr><img src="/cgi-bin/graph.pl'.$stat_str.$duration_str.$callsign_str.'">';
}


print "</body></html>";
