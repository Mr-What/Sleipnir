#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20_30_116x174.pl $
# $Id: e20_30_116x174.pl 417 2014-04-19 14:38:28Z mrwhat $
#
# script to draw thin-ish Jansen walker parts for laser cutting in SVG
# There might not be anything e20 specific here.
# as long as the motor and motor mount don't change, and the motor
# is 40mm from the A axle, and we like this gear ratio, this could remain the same

$preview = 0;  # depricated, edit SVG for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&drawWideForkGroup(7.5,7.5,0,$irB,8); ### B-forks for BED, and H-forks for foot

# back brace tabs for motor mounts
local $ri = $rad4 + 0.5*$fuzz;
local $x0 = 93;
local $y0 = 14;
local $d = 28;
&printMotorTabGA16($x0,$y0,0,3,$ri,6);   $y0 += $d;
&printMotorTabGA16($x0,$y0,0,3,$ri,6);   $x0 -=7.5;  $y0+=35.6;
&printMotorStacker($x0,$y0, 90,$ri);     $x0 +=1.5;  $y0+=14;
&printMotorStacker($x0,$y0,-90,$ri);     $x0 += 13.4;  $y0-=8.5;
&printMotorStacker($x0,$y0,-105,$ri);

### motor gears, at least two, perhaps some spares?
$y0=143;
$x0=30.4;
$d=55;
&printMotorGear($x0,$y0);  $x0 += $d;
&printMotorGear($x0,$y0);

# move to 4.5mm ? --> &braceBH(250,288,0,8);

# current design might need 16 3mm stackers. One on each BED and foot
#print "<g transform=\"translate(219,151) rotate(90)\">";
#&stackerRow(5,0,0);
#for (local $i=1; $i<5;$i++) { &stackerRow(3,10*$i,1); }
#print "</g>\n";

print "</g></svg>\n"; # end of drawing
