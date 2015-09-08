#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20payloadSides45_186x219.pl $
# $Id: e20payloadSides45_186x219.pl 414 2014-03-13 16:31:15Z mrwhat $
#
# Smaller drawing of just payload sides.
#    This version is for 3/16" standoff hinges, with standoff axle and crank-arm
# Jansen configuration E, 20mm crank-arm
$preview = 0;  # Always a preview now.  Hand edit .svg, make thin pitch, for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';
require 'payloadBox.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&printPayloadSides(101,9.4,0);

print "</g></svg>\n"; # end of drawing
