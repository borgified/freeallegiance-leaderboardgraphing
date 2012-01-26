#!/usr/bin/perl

use strict;
use warnings;

my @a=('00','33','66','99','cc','ff');

print "<table width='100%' border='1'> <tbody>\n";

foreach my $x (@a){
	foreach my $y (@a){

		print "<tr>\n";

		foreach my $z (@a){
			my $color = join($x,$y,$z);
			my $bgcolor= "#".$color;

			if($y =~ /99|cc|ff/){
				print "<td bgcolor='$bgcolor' align='center'>$color</td>\n";
			}else{
				print "<td bgcolor='$bgcolor' align='center' style='color: rgb(255, 255, 255);'>$color</td>\n";
			}
		}
		
		print "</tr>\n";
		
	}
}

print "</tbody></table>\n";
