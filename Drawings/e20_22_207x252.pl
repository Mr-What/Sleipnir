#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20_22_207x252.pl $
# $Id: e20_22_207x252.pl 416 2014-04-19 14:36:01Z mrwhat $
#
# script to draw Walker parts which can be cut from 2.5mm (0.100") stock
#
#  It appears that the supplier in Tucson has 0.098" stock which is actually 2.2mm thick.
#  (This may be the same thing as the "2mm" stock at Ponoko)
#  This is a good thickness (<~= 4.5mm/2) for cranklinks, EF, BH, D-fork, and gear side plates

$preview = $#ARGV < 0;  # set to 0 for actual size code generation... will generate REAL code if given any argument

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';
#require 'payloadBox.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&drawEFgroup( 9.6,10,0); ### EF
&drawBHgroup(80.7, 8,0); ### BH
&drawBEDforkGroup(140.5,7,0,8); ### forks for CD on BED, need a total of 8

print "\n<desc>Outer plates for drive gear</desc>\n";
local $x = 153.5;
local $y = 116;
local $ra = $irA-$fuzz*.3; # let plates be tight on A-axle standoffs
local $rGear=16;
local $dy = 2*($drivePlateOR+.15);
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);   $y+=$dy;
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);   $y+=$dy;
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);   $y+=$dy;
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);   $y-=$dy/2; $x+=$dy*.87;
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);   $y-=$dy;
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);   $y-=$dy;
&printGearSide($x,$y,$ra,$rGear,$drivePlateOR);

print "</g></svg>\n"; # end of drawing
