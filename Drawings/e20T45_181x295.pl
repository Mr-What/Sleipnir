#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20T45_181x295.pl $
# $Id: e20T45_181x295.pl 418 2014-04-21 15:59:19Z mrwhat $
#
# script to draw thick Jansen walker hips for laser cutting in SVG
#    This version is for 3/16" standoff hinges, with standoff axle and 20mm crank-arm
# Jansen configuration E
$preview = 0;  # Always a preview now.  Hand edit .svg, make thin pitch, for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printLaserCutHeader($wPx,$hPx,$preview);

&drawBEDoct(63,84,-57);    ### BED
&drawFootOct(121,232,63+83);   ##### feet  -- $FH $GH $FG $FGleft $FGperp 

&drawCrankArms(154,158,0,$AC,4);  ### AC, need only 4, but could use spares
&drawCrankArms( 16,7,0,$AC,1);
&drawCrankArms(149,7,0,$AC,1);

## main pulleys (inside part)
# drive gear (smaller gear, for 30rpm motor), need 2 could use spare
local $rs = $irS - 0.2 * $fuzz;  # make gear hole TIGHT around #4-40 rod
&printGear( 20,230,$gearPitch,$teethDrive,$rs,0,22.5);
&printGear(160.5,134.5,$gearPitch,$teethDrive,$rs,0,22.5);
&printGear(153,260,$gearPitch,$teethDrive,$rs,0,22.5);

# need 8 or 12 total.  could also go with main par cut
print "<desc>spacers for motor mount</desc>\n";
local $ri = $rad4+0.5*$fuzz;
local $ro = 6;  # same radius as fork tyne on main bar
local $x0 = 84;
local $y0 = 7; #6.5;
local $d = 12.5;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d/2; $y0 += 0.85*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0=7;  $y0=89;
&roundSpacer($x0,$y0,$ro,$ri);   $x0+=0.85*$d; $y0+=$d/2;
&roundSpacer($x0,$y0,$ro,$ri);   $y0+=$d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0+=$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0-=0.85*$d; $y0-=3*$d/2;
&roundSpacer($x0,$y0,$ro,$ri);   $y0+=$d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0+=$d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0+=$d;

# might use about 8-16 of these
print "<desc>spacers for the B-brace bar, outside</desc>\n";
$ri = $irB + $fuzz; # a little loose
$ro = $orB;
$y0 = 22;
$x0 = 165;
$d = 15.5;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += 0.8;   $y0 += 2.56*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0+=0.4*$d;  $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 = 140;    $y0 = 172;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 = 165;  $y0 += 1.4*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += 0.4*$d;  $y0 += 0.9*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 +=1;  $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += 0.5;  $y0 += 2.2*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= 0.45*$d;  $y0 += 0.9*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d*2.2;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0=51; $y0=129;
&roundSpacer($x0,$y0,$ro,$ri);   $x0=68; $y0=111;
&roundSpacer($x0,$y0,$ro,$ri);   $x0=50; $y0=90;

print "</g></svg>\n"; # end of drawing
