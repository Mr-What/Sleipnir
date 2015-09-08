#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20feet45_180x158.pl $
# $Id: e20feet45_180x158.pl 414 2014-03-13 16:31:15Z mrwhat $
#
# script to draw thick Jansen walker parts for laser cutting in SVG
#    This version is for 3/16" standoff hinges, with standoff axle and crank-arm
# Jansen configuration E
$preview = 0;  # Always a preview now.  Hand edit .svg, make thin pitch, for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&drawFootOct(121,43,63);   ##### feet  -- $FH $GH $FG $FGleft $FGperp 

#&drawCrankArms(130,13,90,$AC,4);  ### AC, need only 4


## main pulleys (inside part)
# drive gear (smaller gear, for 30rpm motor)
local $rs = $irS - 0.2 * $fuzz;  # make gear hole TIGHT around #4-40 rod
&printGear( 74, 16,$gearPitch,$teethDrive,$rs,0,22.5);
&printGear(107,142,$gearPitch,$teethDrive,$rs,0,22.5);


#&braceB(193,157,0,8);
#&braceBH(172,60,0,8); # try living without this

print "<desc>spacers for motor mount</desc>\n";
local $ri = $rad4+0.5*$fuzz;
local $ro = 6;  # same radius as fork tyne on main bar
local $x0 = 136;
local $y0 = 6.5;
local $d = 12.5;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d/2; $y0 += 0.85*$d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);
&roundSpacer( 16,151,$ro,$ri);

print "<desc>spacers for the B-brace bar, outside</desc>\n";
$ri = $irB + $fuzz; # a little loose
$ro = $orB;
$y0 = 8;
$x0 = 8;
$d = 15.5;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d*2.3;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 = 138.6;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d;
&roundSpacer($x0,$y0,$ro,$ri);   $x0 += $d*1.2;  $y0+=0.7*$d;
&roundSpacer($x0,$y0,$ro,$ri);
$x0 = 172;  $y0=150;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 -= $d*3;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 -= $d;
&roundSpacer($x0,$y0,$ro,$ri);   $y0 -= $d;

print "</g></svg>\n"; # end of drawing
