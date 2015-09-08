#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20mainGear45_59x59.pl $
# $Id: e20mainGear45_59x59.pl 414 2014-03-13 16:31:15Z mrwhat $
#
# script to draw main bar drive gear
#    This version is for standoff axle and 40mm main axle to motor axle spacing
# Jansen configuration E
$preview = 0;  # Always a preview now.  Hand edit .svg, make thin pitch, for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';
require 'payloadBox.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

## main pulleys (inside part)
# drive gear (smaller gear, for 30rpm motor)
local $rs = $irS - 0.2 * $fuzz;  # make gear hole TIGHT around #4-40 rod
local ($x0,$x1) = (16.4,42.7);
&printGear($x0,$x0,$gearPitch,$teethDrive,$rs);  # only need 2, but cutting spares
print "<g transform='translate($x1,$x0) rotate(22.5)'>\n";
&printGear(0,0,$gearPitch,$teethDrive,$rs); print "</g>\n";
&printGear($x1,$x1,$gearPitch,$teethDrive,$rs);
print "<g transform='translate($x0,$x1) rotate(22.5)'>\n";
&printGear(0,0,$gearPitch,$teethDrive,$rs); print "</g>\n";

print "</g></svg>\n"; # end of drawing
