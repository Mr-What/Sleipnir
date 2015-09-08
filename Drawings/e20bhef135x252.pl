#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20bhef135x252.pl $
# $Id: e20bhef135x252.pl 419 2014-04-21 16:07:23Z mrwhat $
#
# script to draw Walker parts which can be cut from 2.5mm (0.100") stock
#
#  It appears that the supplier in Tucson has 0.098" stock which is actually 2.2mm thick.
#  (This may be the same thing as the "2mm" stock at Ponoko)
#  This is a good thickness (<~= 4.5mm/2) for cranklinks, EF, BH, D-fork, and gear side plates

$preview = $#ARGV < 0;  # set to 0 for actual size code generation... will generate REAL code if given any argument

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printLaserCutHeader($wPx,$hPx,$preview);

&drawEFgroup( 9.6,10,0); ### EF
&drawBHgroup(80.7, 8,0); ### BH

print "</g></svg>\n"; # end of drawing
