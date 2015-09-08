#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20mainBar45_144x191.pl $
# $Id: e20mainBar45_144x191.pl 421 2014-04-25 17:03:29Z mrwhat $
#
# script to draw main bar, plus associated braces and spacers
#    This version is for 3/16" standoff hinges, with standoff axle and 20mm crank-arm
# Jansen configuration E
$preview = 0;  # Always a preview now.  Hand edit .svg, make thin pitch, for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';
require 'payloadBox.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printLaserCutHeader($wPx,$hPx,$preview);

&printMainQuadFlat(257-185,50.5,0);
#&drawCrankArms(230-185,13,90,$AC,4);  ### AC, need only 4
#&drawCrankArms(320-185,13,90,$AC,4);  #   cutting spares
#&braceB(7,212,-90,12);
&braceB( 48.7,18.5,90,5);
&braceB(137.4,18.5,90,5);
&braceB(95,173,-90,3); # one spare... just in case


#&drawCrankArms(26,6.3,0,$AC,1);  #barely fits... just leave these to T cut?

print "<desc>spacers for motor mount</desc>\n";
local $ri = $rad4+0.5*$fuzz;
local $ro = 6;  # same radius as fork tyne on main bar
local $x0 = 13;
local $y0 = 160;
local $d = 12.5;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d/2;   $y0 += 0.85*$d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d/2;   $y0 += 0.85*$d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
#&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
#&roundSpacer($x0,$y0,$ro,$ri);
$x0 = 6.5+2;
$y0 = 6.7;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += 52;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);  $y0 = 184; $x0 += 1;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);  $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);

print "<desc>spacers for the B-brace bar, outside</desc>\n";
$ri = $irB + $fuzz; # a little loose
$ro = $orB;
$y0 = 156.3;
$x0 = 130;
$d = 15.4;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 =8.2;   $y0 = 156;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d/2; $y0 += $d*0.86;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d/2; $y0 += $d*0.86;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d/2; $y0 -= $d*0.86;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d/2; $y0 -= $d*0.86;
#&roundSpacer($x0,$y0,$ro,$ri);

print "</g></svg>\n"; # end of drawing
