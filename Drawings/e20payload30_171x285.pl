#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/e20payload30_171x285.pl $
# $Id: e20payload30_171x285.pl 417 2014-04-19 14:38:28Z mrwhat $
#
# script to draw payload bay top/bottom/front/back plates
# If I kees some things standard, these might be re-usable
# on configurations other than e20

$preview = 0;  # depricated.  Edit SVG for production

require 'laserCutPartsGroups.pl';
require 'JansenDefs.pl';
require 'payloadBox.pl';

# ponoko laser cutting sheets come in 181x181mm, 384x384mm, 384 wide x 790mm long
($wPx,$hPx) = &parseSizeFromFileName($0);  # get this from file name to make SURE it matches

&printPonokoHeader($wPx,$hPx,$preview);

&printPayloadBox(5.5,3.3,0);  # top/bot/front/back plates

print "</g></svg>\n"; # end of drawing
