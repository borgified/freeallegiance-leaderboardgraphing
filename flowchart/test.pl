#!/usr/bin/perl

use warnings;
use strict;
use Text::Flowchart;

my  $f = Text::Flowchart->new("directed"=>1);

my $box1 = $f->box(
        "string" 	=> "does callsign exist?",
        "x_coord" 	=> 30,
        "y_coord" 	=> 0,
		"width"		=> 24,
);

my $box2 = $f->box(
		"string" 	=> "changed from last time?",
		"x_coord" 	=> 15,
		"y_coord" 	=> 8,
);

my $box3 = $f->box(
		"string" 	=> "add to hash.\nnext iteration",
		"x_coord" 	=> 30+24,
		"y_coord" 	=> 8,
);

my $box4 = $f->box(
		"string" 	=> "get prev entries from hash and put them in db table.\nupdate all the current stats for this callsign in the hash.\ngoto next iteration",
		"x_coord" 	=> 0,
		"y_coord" 	=> 16,
		"width"		=> 30,
);

my $box5 = $f->box(
		"string" 	=> "this is a duplicate.\nupdate timestamp.\ngoto next iteration",
		"x_coord" 	=> 35,
		"y_coord" 	=> 16,
);

$f->relate([$box1,"bottom"] => [$box2,"top"], "reason" => "Y");
$f->relate([$box1,"bottom",-1] => [$box3,"top"], "reason" => "N");
$f->relate([$box2,"bottom",] => [$box4,"top"], "reason" => "Y");
$f->relate([$box2,"bottom",-1] => [$box5,"top"], "reason" => "N");


$f->draw();
