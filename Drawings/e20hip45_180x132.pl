#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20hip45_180x132.pl $
# $Id: e20hip45_180x132.pl 414 2014-03-13 16:31:15Z mrwhat $
#
# script to draw thick Jansen walker hips for laser cutting in SVG
#    This version is for 3/16" standoff hinges, with standoff axle and 20mm crank-arm
# Jansen configuration E
$preview = 0;  # Always a preview now.  Hand edit .svg, make thin pitch, for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&drawBEDoct(63,84,-57);    ### BED

&drawCrankArms(84,6.5,0,$AC,1);  ### AC, need only 4, but cutting spares

#&braceB(300,155,10,12);
#&braceBH(72,120,0,8); # try living without this

print "<desc>spacers for motor mount</desc>\n";
local $ri = $rad4+0.5*$fuzz;
local $ro = 6;  # same radius as fork tyne on main bar
local $x0 = 19;
local $y0 = 6.6;
local $d = 12.5;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;

print "<desc>spacers for the B-brace bar, outside</desc>\n";
$ri = $irB + $fuzz; # a little loose
$ro = $orB;
$y0 = 90;
$x0 = 8;
$d = 15.5;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;

print "</g></svg>\n"; # end of drawing
