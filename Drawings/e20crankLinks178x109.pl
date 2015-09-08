#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20crankLinks178x109.pl $
# $Id: e20crankLinks178x109.pl 416 2014-04-19 14:36:01Z mrwhat $
#
# script to draw Walker parts which can be cut from 1.5mm stock
#
#  In case the 0.098" is too thick for the cranklinks, or payload lid tabs,
#  here's a drawing to cut them from the small pieces of 1.5 stock that Karl got.

$preview = $#ARGV < 0;  # set to 0 for actual size code generation... will generate REAL code if given any argument

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';
require 'payloadBox.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&drawCrankLinkGroup(  7.2,7.2,0,$CH);
&drawCrankLinkGroup(102.7,7.2,0,$CD);

print "</g></svg>\n";  # end of mm scale and drawing
