# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/laserCutPartsPrimitives.pl $
# $Id: laserCutPartsPrimitives.pl 420 2014-04-21 16:40:47Z mrwhat $
#
# SVG drawing primitives

$cutColor="rgb(0,0,255)";  # ponoko
#$cutColor="rgb(255,0,0)";  # Xerocraft
$deg2rad = 0.01745329252;
$endPart = "'></path></g>\n";  # endpath and location(translation) group to end each part

sub printHeader() {
    local ($w,$h) = @_;

#always set scale to 10:1 pixels:unit.
#This is convenient for looking with geeqie.  1:1 renders too blurry
    #if ($preview) { $w *= 10; $h *= 10; }

    # make the device scale 10* the virtual size in mm.
    local $w10 = 10*$w;
    local $h10 = 10*$h;

# adding  viewport-fill=\"white\" attribute to <svg> does not seem to help...
    print "<?xml version=\"1.0\" encoding=\"utf-8\"  standalone=\"no\"?>
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\"
\"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">
<svg width=\"$w10\" height=\"$h10\"
viewBox=\"0 0 $w $h\"
preserveAspectRatio=\"xMinYMin meet\"
xmlns=\"http://www.w3.org/2000/svg\"
xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n";
}


# takes full width of desired drawing area in mm.
# draw fiducials (for non-preview) which are inset INSIDE this drawing area by 0.5mm
# parameters should be ACTUAL drawing area OUTSIDE dimensions
#    (Fiducials drawn barely INSIDE this box!)
sub drawCornerFiducials() {
    local ($w,$h) = (@_);

    # should be in a mm scale drawing group before calling this function

# try to set a "background" rectangle that renders better on image viewers as png
#   (viewers don't have a background to show through under transparency)
    print "
<desc>background rectangle
     *** delete this for production drawing ***</desc>
<rect x=\"0\" y=\"0\" width=\"$w\" height=\"$h\" fill=\"#EEEECC\" fill-opacity=\"0.8\" stroke=\"none\"/>
\n"; # if ($preview);

# fiducial in magenta is ponoko code for light engraving

    # GET RID OF PREVIEW MODE.  Just hand-edit for production.  Should be easy.
    #  Just change stroke-width in header.

    local ($xa,$x0,$xb) = ($w-1,$w-.5,$w);
    local ($ya,$y0,$yb) = ($h-1,$h-.5,$h);

    # use actual laser stroke width in drawings.
    # hand edit to 0.01(ponoko) or 0.001(Xerocraft) for production drawings

    # print a little border
    # for some unknown reason, this box seems to show up shifted by 0.5 units.
    # crosses are as expected.  I have no idea why I need the extra translate()
    print "\n<desc>Bounding box/warning strip
        *** delete this for production drawing ***
        I have no idea why it needs the extra translate() to line up</desc>\n";
    print "<path transform='translate(0.5,0.5)' stroke-opacity='0.3' stroke='rgb(200,100,0)' stroke-width='1' d='M.5,.5 l0,$ya l$xa,0 l0,-$ya Z'/>\n";

    # draw 180x180 1x1 mm corner fiducials
    #$Wmm = 180;  $Hmm=180;
    # let fiducial be inset, 0.5mm inside drawing area
    print "\n<desc>Corner crosses, centers inset 0.5mm, tips ON border</desc>\n";
    print "<path stroke='#FF00FF' d='
M0,0.5 l1,0 m-.5,-.5 l0,1
M$x0,0 l0,1 m-.5,-.5 l1,0
M$x0,$ya l0,1  m-.5,-.5 l1,0
M.5,$ya l0,1  m-.5,-.5 l1,0'/>
<!-- ====================================================================== Start Main Drawing -->\n";
}

sub drawPololuFiducial() {
    local ($x0,$y0) = (@_);

    local $mmi = 25.4;
    # fiducial in dark green
    printf("<path stroke='rgb(0,128,0)'
d='M$x0,$y0 L%.2f,$y0 L%.2f,%.2f L$x0,%.2f L$x0,$y0'>
</path>\n",
           $x0+$mmi,$x0+$mmi,$y0+$mmi,$y0+$mmi);
}

## NOTE:  Xerocraft laser cutter has cutting area of 17x28".
#   May want to re-do layouts for Xerocraft.

####### Standard header/container fiducials for Ponoko drawings
sub printPonokoHeader {
    local ($wmm,$hmm,$preview) = @_;

    &printHeader($wmm,$hmm);

    #local $cutPitch = 0.01;   # This is for ponoko
    ##local $cutPitch = 0.001;  # this is for AI at Xerocraft
    #$cutPitch = 4 if ($preview);

## put whole drawing in a group which scales mm to pixels
#    print "<g style=\"fill:none; stroke-width:$cutPitch; stroke-linejoin:miter;
#stroke-linecap:butt; stroke='$cutColor'";
#    # for some reason, when I establish scale group, it gets shifted 0.5 unit.  fix this.
#    print " transform='scale(10) translate(0.5,0.5)'" if ($preview);
#    print "\">\n";

    print "
<desc>Establish main drawing parameters
      set stroke-width to 0.01 or 0.001 for production/DXF</desc>
<g style=\"stroke:rgb(0,0,255); stroke-width:0.2;
fill:none; stroke-linejoin:miter; stroke-linecap:butt\">\n";
#transform='scale(10)'>\n";

    &drawCornerFiducials($wmm,$hmm,$preview);
}

####### Standard header/container fiducials for drawings to be converted to DXF for LaserCut
sub printLaserCutHeader {
    local ($wmm,$hmm) = @_;

    &printHeader($wmm,$hmm);

    print "
<desc>Establish main drawing parameters
      set stroke-width to 0.01 or 0.001 for production/DXF</desc>
<g style=\"stroke:#FF0000; stroke-width:0.2;
fill:none; stroke-linejoin:miter; stroke-linecap:butt\">\n";

    &drawCornerFiducials($wmm,$hmm,$preview);
}

### Assuming that a file name is like *WxH.*, where W is drawing width, and H
# is drawing height (usually mm, but could be pixels), parse these numbers from file name and use them.
sub parseSizeFromFileName() {
    local ($fNam) = @_;

    local ($w,$h) = (384,384);
    $_ = $fNam;
    chomp;
print STDERR "FileName : $_\n";
    s/^[\.\/\\]+//;
    s/\..*$//;
    local @a = split /x/;
    if ($#a < 1) { return($w,$h); } 
    $h = $a[$#a];
    $_ = $a[$#a-1];
print STDERR "before h=$_ h=$h\n";
    @a = split /[a-zA-Z_\+\-\s\.]/;
    if ($#a < 0) { return($w,$h); } 
    $w = $a[$#a];
#print STDERR "w=$w\t";
#if ($#a > 0) { $_ = $a[$#a-1]; print STDERR "before w=$_\n"; }
    return($w,$h);
}

sub startPart() {
    local ($cx, $cy, $rot) = (@_,0);

    print "<g transform=\"translate($cx,$cy)"; # origin for link drawing
    print " rotate($rot)" if ($rot != 0); # optional rotation
    print "\">\n";
    # moved to a setting for the whole cut group:
    #print "<path stroke='$cutColor' d='"; # start path definition
    print "<path d='"; # start path definition
}

sub vScale() {
    local($scale,@v) = @_;
    for (local $i=0; $i <= $#v; $i++) { $v[$i] *= $scale; }
    return(@v);
}

sub drawForks() {
    local ($dHole,$rHole,$lr,$edgeFlags,$initialSpace) = (@_,0,0);
    $initialSpace = 1 if ($initialSpace <= 0);  # default, same as spacers
    local $topless    = $edgeFlags & 1;
    local $bottomless = $edgeFlags & 2;

    local $bevelRad = 2; # radius of back-side bevel
    local $len = (3+2*$initialSpace)*$dHole;
    local $xm = $len/2;

    # draw holes first, since their relative placement is most critical
    &drawCircle(0,0,$rHole,18);
    &drawCircle( $initialSpace   *$dHole,0,$irS,10);
    &drawCircle(($initialSpace+1)*$dHole,0,$irS,10);
    &drawCircle(      $len            ,0,$rHole,18);
    &drawCircle(($initialSpace+3)*$dHole,0,$irS,10);
    &drawCircle(($initialSpace+2)*$dHole,0,$irS,10); # end near middle for edges

    # figure-8 for outside of forks, with beveled back corners
    &drawArc('M',$xm-$bevelRad,$lr-$bevelRad,$bevelRad,0,90,20);
    &drawArc(   $topless?'M':'L',0,0,$lr,90,270,15);
    &drawArc($bottomless?'M':'L',$xm-$bevelRad,-$lr+$bevelRad,$bevelRad,-90,0,20);
    &drawArc('L',$xm+$bevelRad,$lr-$bevelRad,$bevelRad,-180,-270,-20);
    &drawArc(   $topless?'M':'L',$len,0,$lr,90,-90,-15);
    &drawArc($bottomless?'M':'L',$xm+$bevelRad,-$lr+$bevelRad,$bevelRad,-90,-180,-20);
}

# use this for either regular spacer, or pulley part
sub roundSpacer() {
    local ($x0,$y0,$ro,$ri,$rd) = (@_,0);

    &startPart($x0,$y0);
    # if $rd is supplied, inside bore is actually a D
    &drawDhole($ri,$rd);
    &drawCircle(0,0,$ro,48);
    print $endPart;
}

sub drawCircle() { # centerX, centerY, radius, numberOfFacets
    local ($x0,$y0,$r,$nf) = (@_,9);  # default to 9 facets
    &drawArc('M',$x0,$y0,$r,0,360,360/$nf);
}
sub plotCircle() { # centerX, centerY, radius, numberOfFacets
    local ($x0,$y0,$r,$nf) = (@_,9);  # default to 9 facets
    &startPart($x0,$y0);
    &drawCircle(0,0,$r,$nf);
    print $endPart;
}

sub drawDhole() {
    local ($ri,$rd,$x0,$y0) = (@_,0,0,0);

    local $facetLen = .5;  # target facet length (mm)
    local $dang = $facetLen * 60 / $ri;
    $dang = 36 if ($dang > 36); # limit to 10-sided poly for a hole

    if ($rd <= 0) { # just draw a circle
        &drawCircle($x0,$y0,$ri,360/$dang);
    } else {
        local $theta = atan2(sqrt($ri*$ri-$rd*$rd),$rd);
        $theta /= $deg2rad;
#print STDERR "D-axle theta=$theta\n";
        &drawArc('M',$x0,$y0,$ri,$theta,360-$theta,$dang);
        printf(" L%.2f,%.2f\n",$x0+$ri*cos($theta*$deg2rad),
                               $y0+$ri*sin($theta*$deg2rad));
    }
}

sub printGearSide() { # axle hole radius
    local ($x0,$y0,$rAxle,$rIngrave,$rO) = @_;
print "\n<desc>Outer plate for drive gear</desc>\n";

    # make some light-engraved guide lines for bevel
    # motor gear outer radius is 15.9
    local $engraveColor = "#FF00FF";  # light engrave at Ponoko

    local $engrave = 1;  # enable engraved circle for bevel guide
    local $Xerocraft = 0;
    if ($Xerocraft) {
	$engraveColor = "rgb(0,0,0)"; # engrave color for Xerocraft
	$engrave = 0;  # disable engrave at Xerocraft until we can get depth and width smaller
    }
    if ($engrave) { 
	print "<g transform=\"translate($x0,$y0)\">
<path stroke='$engraveColor' d='";
	&drawCircle(0,0,$rIngrave,38);
	print "'></path></g>\n";
    }

    &roundSpacer($x0,$y0,$rO,$rAxle);
}

# this one has a draw prefix, since it does not include the startPart
sub drawSquareSpacer() {
    local ($x0,$y0,$ri,$ro,$flags) = @_;
    local $topless = $flags & 1;
    local $bottomless = ($flags & 2) ? 1 : 0;
    local $leftless = ($flags & 4) ? 1 : 0;
    local $rightless = ($flags & 8) ? 1 : 0;

    &drawCircle($x0,$y0,$ri,24);
    printf(" M%.2f,%.2f",$x0-$ro,$y0-$ro) if (!$topless);
    printf(" %s%.2f,%.2f",$topless?'M':'L',$x0+$ro,$y0-$ro);
    printf(" %s%.2f,%.2f",$rightless?'M':'L',$x0+$ro,$y0+$ro);
    printf(" %s%.2f,%.2f",$bottomless?'M':'L',$x0-$ro,$y0+$ro);
    printf(" %s%.2f,%.2f",$leftless?'M':'L',$x0-$ro,$y0-$ro);
}
sub drawSquareSpacerRow() {
    local ($x0,$y0,$ri,$ro,$n,$flags) = @_;
    local $topless = $flags & 1;
    local $bottomless = ($flags & 2) ? 1 : 0;
    local $leftless = ($flags & 4) ? 1 : 0;
    local $rightless = ($flags & 8) ? 1 : 0;

    for (local $i=0; $i< $n; $i++) {
	&drawSquareSpacer($x0+2*$i*$ro,$y0,$ri,$ro, $topless + 2*$bottomless
			  + ((($i>0)||(($i==0) && $leftless))?4:0)
			  + ((($i==$n-1) && $rightless)?8:0) );
    }
}
			  
sub spacer() {
    local ($edgeFlags) = (@_,0);

    local $d0=$dHole/2;
    local $d2=1.5*$dHole;
    local $rr = $rad4+$fuzz*0.5;
    print "<path d='"; # start path definition
    &drawCircle(  0   ,0,$rr,12);
    &drawCircle($dHole,0,$rr,12);
    print " M-$d0,-$d0 L$d2,-$d0 L$d2,$d0 L-$d0,$d0 L-$d0,-$d0";
    print "'></path>\n";  # endpath and location(translation) group to end each part
}
sub stackerRowV() {  # variable dist spacer row
    local ($n,$y0,$dh,$edgeFlags) = (@_,0);

    local $x0 = 0.25;
    local $rr = $rad4+$fuzz*0.5;
    local $dx = $dHole/2;
    &startPart($x0,$y0);
    local $xx;
    for (local $i=0; $i<$n; $i++) {
        $xx = $x0 + ($dHole+$dh)*$i;
        print " M$xx,-$dx L$xx,$dx" if ( ($i>0) || (!($edgeFlags&4)) );
        &drawCircle($x0+$dHole*0.5+$i*($dh+$dHole)    ,0,$rr,12);
        &drawCircle($x0+$dHole*0.5+$i*($dh+$dHole)+$dh,0,$rr,12);
    }
    $xx = $x0 + ($dHole+$dh)*$n;
    print " M$xx,-$dx L$xx,$dx" if (($i==$n) && (!($edgeFlags&8)));
    local $xn = $x0 + $n*($dh+$dHole);
    print " M$xn,$dx L$x0,$dx "   if (!($edgeFlags & 2));
    print " M$x0,-$dx L$xn,-$dx " if (!($edgeFlags & 1));
    print $endPart;
}
sub stackerRow() {
    local ($n,$y0,$edgeFlags) = (@_,0);
    &stackerRowV($n,$y0,$dHole,$edgeFlags);
}
    
sub drawLink() {
  local ($len,$w,$r0,$r1,$w1,$edgeFlags,$nFacets) = (@_,0,0,0);
  &drawLinkY($len,$w,0,$r0,$r1,$w1,$edgeFlags,$nFacets);
}
sub drawLinkY() {
  local ($len,$w,$y0,$r0,$r1,$w1,$edgeFlags,$nFacets) = (@_,0,0,0);
  $w1 = $w if ($w1 <= 0);
  local $topless = $edgeFlags & 1;
  local $bottomless = $edgeFlags & 2;
  $nFacets = 18 if ($nFacets <= 0);  # default 18 facets on link holes
  local $dang = 360 / $nFacets;

  # draw holes first, might be more accurate before part cut loose
  &drawCircle($len,$y0,$r1,360/$dang);
  &drawCircle( 0  ,$y0,$r0,360/$dang);

  &drawArc('M',0,$y0,$w/2,90,270,12);
  &drawArc($bottomless ? 'M' : 'L',$len,$y0,$w1/2,-90,90,12);
  printf(" L0,%.2f ",$y0+$w/2) if (!$topless);  # connect back to start
}

=begin comment
# moved to motorMount.pl
sub drawMainFlat() {
    local ($bx,$rx,$ay,$ry,$flags) = (@_,0);
    #local $doveTails  = $flags&2;
    local $bottomless = $flags&1;
    local $topless = $flags&2;
    local $motorTab   = $flags&4;
    #local $edgeLess   = $flags&8;
    local $partTab    = $flags&16;

    local $tabRad = 2;
    local $dY = 7.5;#8.3;#1.5*$lr;
    local $hr = $irS;  # alignment/spacer hole radius
    local $hrd = 10; # alignment/spacer hole resolution, facets

    # move mounts to BELOW motor, to avoid getting in way of crank-links
    local $dYtab = $ay-$dA_Motor-$motorRad-$dHole/2;

    &drawCircle(-$bx,0,$rx,360/24);
    &drawCircle(-$bx+1.5*$dHole,0,$hr,$hrd);
    &drawCircle(0, $ay,$ry,360/12);
    &drawCircle( $bx-1.5*$dHole,0,$hr,$hrd);
    &drawCircle( $bx,0,$rx,360/24);
    if ($motorTab) {
        &drawCircle(-$dHole/2,$dYtab,$hr,$hrd);
        &drawCircle( $dHole/2,$dYtab,$hr,$hrd);
#print STDERR "Ay=$ay, tab holes at $dYtab\n";
        # use motor-cut-out as a hub for the gear
        &drawDhole($rShaft,$dShaft,0,$ay-$dA_Motor);
        &drawCircle(0,$ay-$dA_Motor,$motorRad,360/8);
    }

    local $startX = $bx;
    local $tabWidth = 22;
    local $startCode = $bottomless ? ($motorTab?'L':'M') : 'L';
    if ($motorTab) {
        print " M-$tabWidth,-$dY ";
    } else {
        print "\nM$startX,-$dY " if (!$bottomless);
    }

    local $lc = 0.5 * (-$dY + ($ay+$dY-($rx-$ry)));
    $lc = 0 if ($lc<0);  # never main main THINNER to accomodate a low $ay
    &drawArc($startCode,-$bx,$lc,$dY+$lc,-90,-270,-12);
    &drawArc($topless?'M':'L',$bx,$lc,$dY+$lc,90,-90,-12);

    if ($motorTab) {
        &drawArc('L',$tabWidth,-$dY-$tabRad,$tabRad,90,160,12);

        local $tabEdge = $dYtab - $dHole/2;
        &drawArc('L', 9,$tabEdge,$tabRad,-10, -90,-15);
        &drawArc('L',-9,$tabEdge,$tabRad,-90,-170,-15);

        &drawArc('L',-$tabWidth,-$dY-$tabRad,$tabRad,20,90,12);
    }
}
=end
=cut

sub drawArc() {
  local ($startCode,$cx,$cy,$r,$startDeg,$stopDeg,$step) = @_;

  local $a=$startDeg;
  local $ar = $a * $deg2rad;
  local $x = $cx + $r * cos($ar);
  local $y = $cy + $r * sin($ar);
  printf("\n %s%.2f,%.2f",$startCode,$x,$y);
  $a += $step;
  while( ($step < 0) ? ($a > $stopDeg) : ($a < $stopDeg) ) {
      $ar = $a * $deg2rad;
      $x = $cx + $r * cos($ar);
      $y = $cy + $r * sin($ar);
      printf(" L%.2f,%.2f",$x,$y);
      $a += $step;
  }
  $ar = $stopDeg * $deg2rad;
  $x = $cx + $r * cos($ar);
  $y = $cy + $r * sin($ar);
  printf(" L%.2f,%.2f\n",$x,$y);
}

sub tabEdge() {
    local ($x0,$y0,$dx,$dy,$n) = @_;

    for (local $i=0;$i<$n;$i++) {
        local $xi = $x0 + 2*$i*$dx;
        printf(" L%.2f,%.2f L%.2f,%.2f L%.2f,%.2f L%.2f,%.2f\n",
               $xi    , $y0,
               $xi    , $y0+$dy,
               $xi+$dx, $y0+$dy,
               $xi+$dx, $y0);
    }
}
sub tabEdgeV() { # same as above, but vertical
    local ($x0,$y0,$dx,$dy,$n) = @_;

    for (local $i=0;$i<$n;$i++) {
        local $yi = $y0 + 2*$i*$dy;
        local $x1 = $x0+$dx;
        local $y1 = $yi + $dy;
        local $y2 = $y1 + $dy;
        print " L$x0,$yi L$x0,$y1 L$x1,$y1 L$x1,$y2\n",
    }
}
sub tabHole() {
    local ($x0,$y0,$w,$h) = @_;
    printf(" M$x0,$y0 L%.2f,$y0 L%.2f,%.2f L$x0,%.2f L$x0,$y0\n",
           $x0+$w,$x0+$w,$y0+$h,$y0+$h);
}
sub tabHoleRow() {
    local ($x0,$y0,$dx,$dy,$n) = @_;

    for (local $i=0; $i < $n; $i++) {
        &tabHole($x0 + 2*$i*$dx-.15,$y0,$dx+.3,$dy+.1);
    }
}


sub BED() {
    local ($dLeft,$dPerp,$dRight,$rPerp,$rLeft,$edgeFlags) = (@_,0);
    local $bottomless = $edgeFlags & 1;
    local $noBD       = $edgeFlags & 2;
    local $halfBE     = $edgeFlags & 4;
    local $halfBD     = $edgeFlags & 8;

    # drill holes first, might help for more accurate placement if before cutting outside
    local $hrd = 9;   # alignment/spacer hole resolution, facets
    &drawCircle(-$dLeft,0,$rLeft,30);
    &drawCircle( 0,$dPerp,$rPerp,30);
    &drawCircle( $dRight-1.5*$dHole,0,$irS,$hrd);
    &drawCircle( $dRight-2.5*$dHole,0,$irS,$hrd);
    &drawCircle(0,$dPerp-1.5*$dHole  ,$irS,$hrd);
    &drawCircle(0,$dPerp-2.5*$dHole  ,$irS,$hrd);

    local $s = 'M';
    if (!$bottomless) { printf(" M%.2f,%.2f\n", -$dLeft,-$orE); $s = 'L'; }
    &drawArc($s,$dRight-1.5*$dHole,0,6,270,440,12);
    &drawArc('L',20,16.5,10,-100,-175,-8);     # extra arc to curve it in a bit

    &drawArc(($noBD|$halfBD)?'M':'L',0,$dPerp,$orB,3,170,8); # more smooth triangle tip
    &drawArc('L',-21,20,10,-10,-82,-8);  # extra arc to curve in leg a bit, again
    &drawArc($halfBE?'M':'L',-$dLeft,0,$orE,100,270,8);
}

sub drawFoot() {
    local ($dLeft,$dRight,$dPerp,$flags) = (@_,0);
  local $closeLoop = $flags & 1;
    local $shinless  = ($flags & 2) ? 1 : 0;
    local $hipless  = ($flags & 4) ? 1 : 0;

    local $hrd = 10;  # alignment hole resoltion in facets
    &drawCircle(-$dLeft,0,$irF,30);
    &drawCircle(0,$dPerp ,$irH,30);
    &drawCircle(0,$dPerp-1.5*$dHole,$irS,$hrd);
    &drawCircle(0,$dPerp-2.5*$dHole,$irS,$hrd);

    &drawArc('M',$dRight-$orG+$fuzz,0,$orG,-90,81,7);
    &drawArc($shinless?'M':'L',25,25,15,-100,-170,-7);
    &drawArc('L',0,$dPerp,$orH,10,165,8);
    &drawArc($hipless?'M':'L',-26,25.5,15,-23,-88,-8);
    &drawArc('L',-$dLeft,0,$orF,105,270,6);

    # close loop to foot
    printf(" L%.2f,%.2f\n",$dRight-$orG,-$orG) if ($closeLoop);
}

# holes to match cheap motor driver mount, from above.
# has cutouts for heatsink and control wires.
#   control wires may not be necessary, but it might be
#   hard to get a 90 deg. female 6-pin header for them,
#   so be open to the possibility of connecting control wires from
#   the top and/or leaving room to loop them back.
sub motorDriverModuleMountHoles() {
    local ($x0,$y0,$rot,$flags) = (@_,0,0);
    local $topCutOuts = $flags&1;

    local $w = 37;  # mm between mount holes
    &startPart($x0,$y0,$rot);
    $hr = $rad4; $hrd = 12;
    &drawCircle( 0, 0,$hr,$hrd);
    &drawCircle($w, 0,$hr,$hrd);
    &drawCircle($w,$w,$hr,$hrd);
    &drawCircle( 0,$w,$hr,$hrd);

    if ($topCutOuts) {
        local $h1 = $w-3.5;  # edge of headers
        local $hw = 11; # actual width of headers is 10mm
        local $hh = 5;
        local $ho = 1;  # offset from center of header line to center of screws
        &tabHole($h1-$hw-1,-$ho-2,$hw+2,$hh+3);

        # hole to allow heatsink to protrude
        &tabHole(7-1,$w+3.5-16-1,$w-12,16+2);
    }

    print $endPart;
}

sub raspPiMountHoles() {
    local ($x0,$y0,$rot) = (@_,0,0,0);

    local ($w,$h) = (85,56);  # total board width and height
    local $hr = 2.9/2;  # hole radius

    &startPart($x0,$y0,$rot);
    #$hr = $rad4;
    local $hrd = 12;
    &drawCircle( 5,$h-12.5,$hr,$hrd);
    &drawCircle($w-25.5,18,$hr,$hrd);
    print $endPart;
}

sub ArduinoUnoMountHoles() {
    local ($x0,$y0,$rot) = (@_,0,0,0);

    &startPart($x0,$y0,$rot);
    local $hrd = 12;
    local $hr = $rad4 + $fuzz;  # override global, which may not be set
    &drawCircle(14         ,53.3-2.5              ,$hr,$hrd);
    &drawCircle(14+1.3     ,53.3-2.5-5.1-27.9-15.2,$hr,$hrd);
    &drawCircle(14+1.3+50.8,53.3-2.5-5.1          ,$hr,$hrd);
    &drawCircle(14+1.3+50.8,53.3-2.5-5.1-27.9     ,$hr,$hrd);
    print $endPart;
}

# draw an oval slot, with the center of one edge semicircle at given point
sub drawSlot() {
    local ($x0,$y0,$dx,$dy) = @_;

    local $rd=30;
    if (abs($dx)>abs($dy)) {
        &drawArc('M',$x0    ,$y0,$dy/2, 90,270,$rd);
        &drawArc('L',$x0+$dx,$y0,$dy/2,-90, 90,$rd);
        printf(" L$x0,%.2f ",$y0+$dy/2);
    } else {
        &drawArc('M',$x0,$y0    ,$dx/2,180,360,$rd);
        &drawArc('L',$x0,$y0+$dy,$dx/2,  0,180,$rd);
        printf(" L%.2f,$y0 ",$x0-$dx/2);
    }
}

# draw a little spring tab catch, hooks a tab
sub drawSpringTabCatch() {
    local ($w,$len) = @_;

    local $l2 = $len/2;
    local $delta = $w/2;  # assume $w is material width, this is good flexible stem width
    local $x1 = $l2 - $delta/2;
    local $x2 = $l2 + $delta/2;
    local $cr = 1; # corner radius
    printf("\nM%.2f,0 L%.2f,0\n",-$x1-$x2/2,-$x2/2-$delta-.2);
    &drawArc('L',-$x1,5.6*$w,$x2/2-1,-180,-360,-12);
    &drawArc('L',-$x1,2*$w+$cr,$cr,0,-38,-6);
    &drawArc('L',-$x1+$cr,2*$w-2*$cr,$cr,145,180,6);
    &drawArc('L',-$x1+$cr,0,$cr,-180,-90,9);
    &drawArc('L',0,0,$cr,-90,0,9);
    print "\nL0,0 L0,$w L$x1,$w\n";
    &drawArc('L',$x1-$cr,$w+$w-$cr,$cr,0,45,9);
    &drawArc('L',$cr,3*$w,$cr,-135,-180,-9);
    &drawArc('L',$l2,6*$w,$l2,-180,-360,-12);
    &drawArc('L',$len-$cr,3*$w,$cr,0,-45,-9);
    &drawArc('L',$x2+$cr,$w+$w-$cr,$cr,135,180,9);
    print " L$x2,$w L$len,$w L$len,0\n";
    &drawArc('L',$len,0,$cr,-180,-90,9);
    &drawArc('L',$len+$x1-$cr,0,$cr,-90,0,9);
    &drawArc('L',$len+$x1-$cr,2*($w-$cr),$cr,0,38,6);
    &drawArc('L',$len+$delta+$cr,2.4*$w,$cr,-145,-180,-6);
    &drawArc('L',1.5*$len+$delta-$x1/2-1,5.6*$w,$x2/2-1,-180,-360,-12);
    printf(" L%.2f,0\n",$len+$x2);
}

sub printSpringTab() {
    local ($w,$len,$x0,$y0,$rot) = (@_,0,0,0);
    &startPart($x0,$y0,$rot);
    &drawSpringTab($w,$len);
    print "$endPart\n";
}

# draw a little spring tab, a tab that hooks
sub drawSpringTab() {
    local ($w,$len) = @_;

    local $l2 = $len/2;
    local $delta = $w/2;  # assume $w is material width, this is good flexible stem width
    local $cr = 1; # corner/catch radius
    local $x1 = $l2 - $cr -.3;  # each side should >~ $cr
    local $x2 = $l2 + $cr +.3;
    local $sw = $w/2; # spring slot width
    local $r0 = $cr;#4*$fuzz;  # very small circle radius
    printf("\nM0,%.2f\n",5*$w-3*$r0);
    &drawArc('L',-$r0,5*$w,$r0,-130,-360,-15);
    print "\nL0,0\n";
    &drawArc('L',         $cr,  0   ,2*$cr, 180, 290,12);
    &drawArc('L',$x1    - $cr,  0   ,  $cr, 300, 360,12);
    &drawArc('L',$x1    - $cr,$w-1  ,  $cr,   0,  30, 6);
    &drawArc('L',$sw    + $cr,$w*1.7,  $cr,-140,-180,-9);

    &drawArc('L',$len/2,5.4*$w,($len-2*$sw)/2,-180,-360,-12);

    &drawArc('L',$len-$sw-$cr,$w*1.7,  $cr,  0 , -40,-9);
    &drawArc('L',$x2     +$cr,$w-1  ,  $cr,-210,-180, 6);
    &drawArc('L',$x2     +$cr,  0   ,  $cr,-180,-115,12);
    &drawArc('L',$len    -$cr,  0   ,2*$cr,-110,   0,12);
    print "\nL$len,0\n";
    &drawArc('L',$len+$r0,5*$w,$r0,-180,-360-50,-15);
    printf("\nL$len,%.2f\n",5*$w-3*$r0);
}

# TEMPORARY:  For protoboards I have, if I drill out corner lead holes
# for #4 screws
sub protoboardHoles() {
    local ($x0,$y0,$rot) = @_;

    local $w = 37;  # mm between mount holes
    &startPart($x0,$y0,$rot);
    local $w = 2.54*9;
    local $h = 2.54*23;
    local $hr = $rad4;  local $hrd = 12;
    &drawCircle( 0, 0,$hr,$hrd);
    &drawCircle( 0,$h,$hr,$hrd);
    &drawCircle($w,$h,$hr,$hrd);
    &drawCircle($w, 0,$hr,$hrd);
    print $endPart;
}

=begin comment
#### moved to motorMount.pl ###
# this motor has a 10x12mm rectangular section on the front, where behind
# is a 6mm radius cylander, 12mm width one way, but truncated to 10mm width
# to match the front section the other way.
# Mounting holes on tab are centered $dHole/2 up from the bottom edge of the mounting tab
sub drawSmallGearheadMotorMount(){
    local ($flags) = (@_,0);
    local $edgeless = $flags & 1;
    local $rCorner = $dHole/3;

    &drawCircle(-$dHole/2,0,$rad4,12);
    &drawCircle( $dHole/2,0,$rad4,12);

    local $motorRad = 6-.07;  # with fuzz for laser cut width
    local $arcLim = 56.443; # arc part of motor can is +- $arcLim degrees
    #&drawArc('M',0,$dHole/2+5,$radQ,0,360,15); # make a convient spacer
    &drawArc('M',0,$dHole/2+5,$motorRad,-$arcLim+3,$arcLim,12);
    &drawArc('L',0,$dHole/2+5,$motorRad,180-$arcLim,180+$arcLim,12);
    &drawArc('L',0,$dHole/2+5,$motorRad,-$arcLim,-$arcLim+3,12);

    &drawArc('M',-$dHole+$rCorner,-$dHole/2   +$rCorner,$rCorner,-180,-90,12);
    &drawArc('L', $dHole-$rCorner,-$dHole/2   +$rCorner,$rCorner, -90,  0,12);
    &drawArc('L', $dHole-$rCorner, $dHole/2+15-$rCorner,$rCorner,   0, 90,12);
    &drawArc('L',-$dHole+$rCorner, $dHole/2+15-$rCorner,$rCorner,  90,180,12);
    printf(" L-$dHole,%.2f\n",-$dHole/2+$rCorner) if !($edgeless);
}

# this motor has a 15.5mm diameter cylander gearhead
# with a 15.5mm diameter motor housing behind, flattened to 12mm wide on the flat side
sub drawGA16gearheadMotorMount(){
    local ($flags) = (@_,0);
    local $edgeless = $flags & 1;
    local $round    = $flags & 2 ? 1 : 0;
    local $topless = $flags & 4;

    local $rCorner = $dHole/3;

    &drawCircle(-$dHole/2,0,$irS,12);
    &drawCircle( $dHole/2,0,$irS,12);

    # move to JansenDefs: local $motorRad = 7.75;  # no fuzz needed on Acrylic
    local $yc = $dHole/2+$motorRad;
    #&drawArc('M',0,$yc,$irB,0,360,15); # make a convient spacer
    &drawDhole($rShaft,$dShaft,0,$yc); # make a convient drive axle spacer
    if ($round) { &drawCircle(0,$yc,$motorRad,30); }
    else {
        local $arcLim = 90-37.747; # arc part of motor can is +- $arcLim degrees
        local $mr = $motorRad - $fuzz*.4;  # previous cut was a little tight on this side, the circular part was just about perfect.
        &drawArc('M',0,$yc,$mr,  3-$arcLim,    $arcLim,12);
        &drawArc('L',0,$yc,$mr,180-$arcLim,180+$arcLim,12);
        &drawArc('L',0,$yc,$mr,   -$arcLim,  3-$arcLim,2); # close the loop
    }
print STDERR "less small motor axis $yc below tab holes\n";

    local $dx = 13;
    &drawArc('M',-$dx+$rCorner,-$dHole/2   +$rCorner,$rCorner,-180,-90,12);
    &drawArc($topless?'M':'L', $dx-$rCorner,-$dHole/2   +$rCorner,$rCorner, -90,  0,12);
    &drawArc('L', 0, $yc,$dx,   0, 180,12);
    printf(" L-$dx,%.2f\n",-$dHole/2+$rCorner) if !($edgeless);
}
=end
=cut

=begin comment
### depricated for new spring-latched payload cover
sub payloadCover() {
    local ($x0,$y0,$rot,$flags) = @_;
    local $PCBmounts = $flags&1; # usually on bottom only
    local $edgeless  = $flags&2;
    local $leftless  = $flags&4;
    local $rightless = $flags&8;

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";

    local $mTabLen = 10;  # length of tabs into payload mount sides
    local $tabLen = 5; # length of tabs to other thin pannels.
    local $wTabs = 9;
    local $hTabs = 3;
    local $iw = 2*$mTabLen*$wTabs - $mTabLen;
    local $ih = 2*$mTabLen*$hTabs + $mTabLen/2;


    local $sw = 3; # nominal slot width
    local $td = 5; # depth of tabs into side plates
    if ($PCBmounts) {
        &protoboardHoles(20,40,-90);
        &motorDriverModuleMountHoles(114,$ih-$tabLen+.75,-90);
        &raspPiMountHoles(15,15,0);
    }

&startPart(30,20);&drawSpringTabCatch(3,7);print "$endPart\n";
&startPart(50,30);&drawSpringTab(3,7);print "$endPart\n";

    &startPart(0,0);

    # mid-side holes, motor wires can exit, AND can be for optional cable ties
    local $y1=85; # width of payload bay
    local ($s1,$s2) = (8,2); # slot dimensions
    local $inset = 8;  # how far in from edge are slots
    &drawSlot($iw/2-$s1/2,    $inset,$s1,$s2);
    &drawSlot($iw/2-$s1/2,$y1-$inset,$s1,$s2);

    # ventillation and tie-downs
    &drawSlot($iw*.2-$s1/2,    $inset,$s1,$s2);
    &drawSlot($iw*.2-$s1/2,$y1-$inset,$s1,$s2);
    &drawSlot($iw*.8-$s1/2,    $inset,$s1,$s2);
    &drawSlot($iw*.8-$s1/2,$y1-$inset,$s1,$s2);

    &drawSlot(    $inset,         10,$s2,$s1);
    &drawSlot(    $inset,($y1-$s1)/2,$s2,$s1);
    &drawSlot(    $inset, $y1-$s1-10,$s2,$s1);
    &drawSlot($iw-$inset,         10,$s2,$s1);
    &drawSlot($iw-$inset,($y1-$s1)/2,$s2,$s1);
    &drawSlot($iw-$inset, $y1-$s1-10,$s2,$s1);

    local $bTabs = 8;
    printf("M%.2f,%.2f ",-$sw-.5,0);
    &tabEdge(0,0,$mTabLen,-$td,$wTabs);
    local $x2 = $wTabs*$mTabLen*2-$mTabLen;
    local $x1 = $x2+$sw;

    if ($rightless) { printf(" L%.2f,0",$x1+1);
    } else {                  &tabEdgeV($x1+1,0,-$sw-1,$tabLen,$bTabs); }
    printf(" %s%.2f,%.2f L%.2f,$y1 ",$rightless?'M':'L',
           $x1+1.5,$y1-5,$x1+1.5); # extra half-tab pair

    if ($edgeless) {
        printf(" M%.2f,%.2f ",$mTabLen-$sw-1,$y1+$td);
    } else {
        &tabEdge($x2,$y1,-$mTabLen,$td,$wTabs);
    }
    &tabEdgeV(0,$y1+$td,-$sw-1,-$td,$bTabs+1);

    &drawSlot(-$ih/2-5-$sw ,      5 + $s2,$s1,$s2);
    &drawSlot(-$ih/2-5-$sw ,  $y1-5 - $s2,$s1,$s2);
    &drawSlot(          -12,      5 + $s2,$s2,$s1);
    &drawSlot(          -12,$y1/2 - $s1/2,$s2,$s1);
    &drawSlot(          -12,$y1-$s1-5-$s2,$s2,$s1);
    &drawSlot(-$ih-2*$sw+10,$y1-$s1-5-$s2,$s2,$s1);
    &drawSlot(-$ih-2*$sw+10,$y1/2 - $s1/2,$s2,$s1);
    &drawSlot(-$ih-2*$sw+10,      5 + $s2,$s2,$s1);
    print " M-$sw,0 ";
    &tabEdge(2.5-$sw-1-$mTabLen,0,-$mTabLen,-$td,$hTabs);
    if ($leftless) { printf(" L%.2f,0",-$ih-$sw-1);
    } else {        &tabEdgeV(-$ih-$sw-1,0,-$sw-1,$td,$bTabs); }
    printf(" %s%.2f,%.2f L%.2f,$y1 ",$leftless?'M':'L',-$ih-$sw-1,$y1-$tabLen,-$ih-$sw-1);

    if (!$leftless) {
        &tabEdge(-$ih-$sw-1+7.5,$y1,$mTabLen,$td,$hTabs);
        print " L-$sw,$y1 ";
    }

    print "$endPart </g>\n";
}

sub sidePannel() {
    local ($x0,$y0,$rot,$flags) = @_;
    local $USBport = $flags&1;

    local $sw = 2; # nominal slot width
    local $td = 5; # depth of tabs into side plates

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    &startPart(0,0);
    print " M-$sw,-$sw ";
    &tabEdgeV(0,0,-$sw,5,9);


    print "$endPart </g>\n";
}
=end comment
=cut

# standard motor gear, open-bottom motor mount design.
# has D-hole for GA16 axle, and access hole for mount screw heads
sub printMotorGear() {
    local ($x0,$y0) = @_;

    local $dAccessHole = sqrt(13.7*13.7 + 3*3);
#&printGear(67,108.1,$gearPitch,$teethMotor,$rShaft,$dShaft);
#&plotCircle(67+13.7,108.1+3,3,15);

    &printGear($x0,$y0,$gearPitch,$teethMotor,$rShaft,$dShaft);

    # can print after rest of gear, since not a high-precision hole
    &plotCircle($x0+$dAccessHole,$y0,4.2,15);

    # for mounting on bobbin/hub.  Let user delete what they DON'T want
    # in production
    &plotCircle($x0,$y0,8.08/2,32);
    &plotCircle($x0-5.4,$y0,1,9);
}

require 'involuteGear.pl';

sub printGear() {
    local ($x0,$y0,$pitch,$nTeeth,$holeRad,$flatRad,$rot) = (@_,0,0,0);
#print STDERR "holeRad=$holeRad  flatRad=$flatRad\n";

    local %p = &defaultGearParams();
    $p{'pressure_angle' } = 25; # higher than default 20 degrees might be good for plastic
    $p{'involute_facets'} = 16;

    $p{'pitch' }          = $pitch;  # distance of tooth period along pitch circle
    $p{'number_of_teeth'} = $nTeeth;

    print "<desc>Gear : $nTeeth teeth, $pitch pitch</desc>
<g transform=\"translate($x0,$y0) rotate($rot)\">\n";

    &startPart(0,0);
    &drawDhole($holeRad,$flatRad);  # will draw circle if $flatRad <= 0
    print $endPart;

    &drawInvoluteGear(%p);
    print "</g>\n";
}
1;
