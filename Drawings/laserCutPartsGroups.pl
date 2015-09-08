#!/usr/bin/perl -w
# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/laserCutPartsGroups.pl $
# $Id: laserCutPartsGroups.pl 413 2014-02-28 16:44:50Z mrwhat $
#
# Groups of parts for laser-cut walker

require 'laserCutPartsPrimitives.pl';
require 'motorMount.pl';

# re-done just for GA16 (standard selected motor) pairs
sub drawMotorMountPair() {
    local ($x0,$y0,$rot) = (@_,0,0,0);
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";

    &startPart(0,0);
    &drawGA16gearheadMotorMount(0);
    print $endPart;
    print "<g transform=\"scale(1,-1) translate(0,$dHole)\">\n";
    &startPart(0,0);
    &drawGA16gearheadMotorMount(4);
    print $endPart;
    print "</g></g>\n"; # end of group translation
}


sub drawMotorMountSet() {
    local ($x0,$y0,$rot,$n,$flags) = (@_,0,0,0);
    local $lessSmall = $flags&1;

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    # feet not straight in x, reflect does not align, continue to rotate
    for (local $i=0; $i<$n; $i++) {
        &startPart($i*($lessSmall?26:2*$dHole),0);
        if ($lessSmall) {
            local $backBrace = 0; # New design only uses back tabs: $i % 2;
            &drawGA16gearheadMotorMount(($i?1:0)+2*$backBrace);
        }
        else { &drawSmallGearheadMotorMount($i?1:0); }
        print $endPart;
    }
    print "</g>\n"; # end of group translation
}

sub drawWideForkGroup() {
    local ($x0,$y0,$rot,$rr,$n) = @_;

    print "\n<desc>B-axle and foot forks</desc>\n";
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $fw = 14;#$dHole+3;
    local $dy = $fw;# + 1; # add extra space for testing to check for double cuts
    for(local $i=0;$i<$n;$i++) {
        &startPart(0,$i*$dy);
        &drawForks($dHole,$rr,$fw/2,$i?2:0,1.5);
        print $endPart;
    }
    print "</g>\n";
}

sub printPayloadCovers() {
    local ($x0,$y0,$rot,$flags) = (@_,0,0);
    local $leftless = $flags & 1;

    print "<desc>Payload top, bottom, front, and back</desc>\n";
    local $x=5.5;
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    &payloadCover($x,0,0,1+2+4*$leftless);
    print "<g transform=\"scale(-1,1)\">\n";
      &payloadCover(-180-$x,90,0,8*$leftless);
    print "</g></g>\n";
}

sub drawPayloadMountSet() {
    local ($x0,$y0,$rot) = (@_,0);

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    drawPayloadMount(0,0,0);
    drawPayloadMount(0,81,0,1);
    print "</g>\n"; # end of group translation
}

sub drawPayloadMount() {
    local ($x0,$y0,$rot,$flags) = (@_,0,0);
    local $edgeless = $flags&1;

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $sl = 10;  # slot length
    local $slv = 10; #5;  # vertical slot length
    local $xLo = $sl*int($Bx/$sl)+2.5*$sl;
    local $nx = int($xLo/$sl)+2;
    $xLo = $sl * ($nx - (($nx % 2)*0.5));
    local $top = 25; # bottom of TOP plate, from axis centerline
    local $bot = 40; # top of BOTTOM plate, from axis centerline
    local $sw = 3;  # slot width
    local $ny = int(($top+$bot+$slv)/(2*$slv));
    local $yMid = ($top-$bot/2);
    local $yLo = $yMid - ($ny+0.75)*$slv;

    &startPart(-$xLo-.5,$yLo,90); &tabHoleRow(0,0,$slv, $sw,$ny); print $endPart;
    &startPart( $xLo+.5,$yLo,90); &tabHoleRow(0,0,$slv,-$sw,$ny); print $endPart;

    &startPart(0,0);
    local $bHole = $irB - 0.5*$fuzz; # a little tight, non-spinning
    local $eRad = 6;  # radius of edge corners
    &drawCircle(-$Bx,0,$bHole,18);
    &drawCircle( $Bx,0,$bHole,18);

    &tabHoleRow(-$xLo, $top,$sl, $sw,$nx);
    &tabHoleRow(-$xLo,-$bot,$sl,-$sw,$nx);

    # add some slots for wire pass-through, tie-downs, and ventillation
    &drawSlot(      -4,-$bot+5,8,2);
    &drawSlot(      -4, $top-5,8,2);
    &drawSlot(-$xLo+11, $top-5,8,2);
    &drawSlot(-$xLo+11,-$bot+5,8,2);
    &drawSlot( $xLo-19, $top-5,8,2);
    &drawSlot( $xLo-19,-$bot+5,8,2);
    &drawSlot( $xLo- 5,  -11.5,2,8);
    &drawSlot(-$xLo+ 5,  -11.5,2,8);

    $top+=$eRad;
    $bot+=$eRad;
    local $dx = $eRad/2 - .5;
    local $dy = $eRad-$sw+1;
    &drawArc('M', $xLo+$dx,-$bot+$dy,$eRad,270,360,6);
    &drawArc('L', $xLo+$dx, $top-$dy,$eRad,  0, 90,6);
    &drawArc('L',-$xLo-$dx, $top-$dy,$eRad, 90,180,6);
    &drawArc('L',-$xLo-$dx,-$bot+$dy,$eRad,180,270,6);
    printf("L%.2f,%.2lf ",$xLo+$dx,-$bot+$dy-$eRad) if (!$edgeless);
    print $endPart;
    print "</g>\n";
}

sub braceB() {
    local($x0,$y0,$rot,$n) = @_;
    print "\n<desc>Main bar spacer/braces</desc>\n";
    &startPart($x0,$y0,$rot);
    #print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $orb = 6;
    local $ors = 4.5;
    local $dy = $orb+$ors;
    local $da = 20;  # angular spacing for drill holes
    local $hs = $dHole * 1.5; # spacing to alignment hole
    for (local $j=0; $j < $n; $j++) {
        local $a = $j % 2;
        local $y = $j * $dy;
        &drawCircle( 0 ,$y,$a?$irB:$irS,360/($a?$da:2*$da));
        &drawCircle($hs,$y,$a?$irS:$irB,360/($a?2*$da:$da));
        printf("M0,-$ors ") if ($j==0);
        &drawArc($j?'M':'L',$hs,$y,$a?$ors:$orb,270,450,8);
        &drawArc('L',0,$y,$a?$orb:$ors,90,270,8);
    }
    print $endPart;#"</g>\n";
}
my $braceBHdist = 1.6;  # space (mult of $dHole) to brace on BH links
sub braceBH() {
    local($x0,$y0,$rot,$n) = @_;
    print "\n<desc>BH link braces</desc>\n";
    &startPart($x0,$y0,$rot);
    #print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $orb = $orB-1.5;
    local $ora = 3.5;
    local $dy = $orb+$ora;
    local $hs = $dHole * $braceBHdist; # spacing to alignment hole
    local $len = 1.3 * $hs;
    local $irb = $irB + 0.6*$fuzz;  # let this be a little sloppier, hard to algn perfectly
    for (local $j=0; $j < $n; $j++) {
        local $a = $j % 2;
        local $y = $j * $dy;
        if ($a==0) {
            &drawCircle(     0  ,$y,$irb,18);
            &drawCircle(     $hs,$y,$irS,10);
        } else {
            &drawCircle($len    ,$y,$irb,18);
            &drawCircle($len-$hs,$y,$irS,10);
        }
        printf("M0,-$orb ") if ($j==0);
        &drawArc($j?'M':'L',$len,$y,$a?$orb:$ora,270,450,8);
        &drawArc('L',0,$y,$a?$ora:$orb,90,270,8);
    }
    print $endPart;#"</g>\n";
}

#----------------------------feet
sub drawFootPair() {
    local ($x0,$y0,$flags) = @_;
    local $shinless = $flags & 1;
    local $hipless = ($flags & 2) ? 1 : 0;

    print "<g transform=\"translate($x0,$y0)\">\n";
    # feet not straight in x, reflect does not align, continue to rotate
    # rFoot=3: &startPart($FG-2*$FGleft-3,-3-$Frad,180);
    &startPart($FG-2*$FGleft-6,-6-$orF,180);
         &drawFoot($FGleft,$FG-$FGleft,$FGperp,$shinless*2+$hipless*4);
    print $endPart;
    &startPart(0,0); &drawFoot($FGleft,$FG-$FGleft,$FGperp,1); print $endPart;
    print "</g>\n"; # end of group translation
}
sub drawFootQuad() {
    local ($x0,$y0,$flags,$rot) = (@_,0);
    local $hipless = $flags&1;

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    #D &drawFootPair($FGleft+23.5,$FGperp-1.2,1+$hipless*2);
    &drawFootPair($FGleft+23,$FGperp-2.3,1+$hipless*2);
    &drawFootPair(0,0,$hipless*2);  print "</g>\n";
}
sub drawFootOct() {
    local ($x0,$y0,$rot) = @_;

    print "\n<desc>Feet</desc>\n";
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    #D &drawFootQuad(-$FG+$FGleft+21.6,2*$FGperp+4.8,1);
    &drawFootQuad(-$FG+$FGleft+19.3,2*$FGperp+4,1);
    &drawFootQuad(0,0,0);  print "</g>\n";
}

#--------------------------- BED

sub drawBEDpair() {
    local ($x0,$y0,$flags) = @_;
    local $halfBE = $flags & 1;
    local $halfBD =($flags & 8)?1:0;

    print "<g transform=\"translate($x0,$y0)\">\n";
#D  &startPart(-1.75*$dHole-1,-(6+$orE),180);
    &startPart(-1.75*$dHole,-(6+$orE),180);
                     &BED($DEleft,$DEperp,$DE-$DEleft,$irB,$irD,1); print $endPart;
    &startPart(0,0); &BED($DEleft,$DEperp,$DE-$DEleft,$irB,$irD,$halfBE*4+$halfBD*8); print $endPart;
    print "</g>\n"; # end of BED group translation
}
sub drawBEDquad() {
    local ($x0,$y0,$flags,$rot) = (@_,0);
    local $halfBD = $flags & 1;

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    &drawBEDpair(0,0,8*$halfBD);
    #D &drawBEDpair($DE-$DEleft+5,-30.1,1+8*$halfBD);
    &drawBEDpair($DE-$DEleft+5,-30,1+8*$halfBD);
    print "</g>\n";
}
sub drawBEDoct() {
    local ($x0,$y0,$rot) = @_;
    local $DEright = $DE-$DEleft;

    print "\n<desc>BED triangles</desc>\n";
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    #D &drawBEDquad($DEright-1.7+.5,2*$DEperp-7.6,0);
    &drawBEDquad($DEright-2.2,2*$DEperp-9,0);
    &drawBEDquad(0,0,1);  print "</g>\n";
}
###---

# -- newer version(1401), motor mount from below
sub printMainPairFlat() {
    local ($x0,$y0,$rot,$Bx,$Brad,$Ay,$Arad,$flags) = (@_,0);
    local $topless = $flags & 1;

    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    # for main, a pair will be one bar with motor tab and a straight bar
    #D local $dY = 16.6;
    local $dY = 18.8;
    &printMainFlat(0,  0,0,$Bx,$Brad,$Ay,$Arad,4);
    &printMainFlat(0,$dY,0,$Bx,$Brad,$Ay,$Arad,3);

    $Brad += 0.1*$fuzz;  # brace need not be all that tight
    &startPart(-$Bx,2*$dY);
       &drawLink($Bx*2,15,$Brad,$Brad,15,$topless,15);  print $endPart;
  
    print "</g>\n";
}

sub printMainQuadFlat() {
    local ($x0,$y0,$rot) = @_;

    local $rb = $irB - 0.3 * $fuzz;  # make B-axle connection a little tight
    local $ra = $irA;

    print "<desc>main bars</desc>
<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    &printMainPairFlat(0, 0  , 0 ,$Bx,$rb,$Ay,$ra,1);
    #D &printMainPairFlat(0,81.4,180,$Bx,$rb,$Ay,$ra);
    &printMainPairFlat(0,90.2,180,$Bx,$rb,$Ay,$ra);
    print "</g>\n"; # end of group translation
}


sub drawCrankArms() { 
    local ($x0,$y0,$rot,$len,$n,$flags) = (@_,0,0,0,0);
    local $topless = $flags&1;

    $len = $AC if ($len <= 0);  # custom length, mostly for helping 3D printed models
    $n = 4 if ($n <= 0);  # default, all 4 crank arms

    print "\n<desc>crank arms</desc>
<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $lw = 2 * $orA;  # width of crank-arm link
    local $dy = $lw + 0;#+1; # space for checking double cuts
    local $rS = $irS - 0.2*$fuzz;  # slightly tighter than typical alignment hole
    for ($i=0; $i<$n; $i++) {
        &startPart(0,$i*$dy);
        &drawLink($len,$lw,$rS,$rS,$lw,$i?2:$topless*2);
        print $endPart;
    }
    print "</g>\n"; # end of group translation
}

# foot forks have extra space after spacer
sub drawFootForkGroup() {
    local ($x0,$y0,$rot,$rr,$n) = @_;
    local $initialSpace = 1.4;

    print "\n<desc>Foot forks</desc>\n";
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $fw = 15;#$dHole+3;
    local $dy = $fw;# + 1; # add extra space for testing to check for double cuts
    for(local $i=0;$i<$n;$i++) {
        &startPart(0,$i*$dy);
        #&drawArc('M',5*$dHole,0,$rad4,0,360,10); # more spacers
        #&drawArc('M',   0    ,0,$rad4,0,360,10);
        #local $rr = ($i<4) ? $radS : $Brad+0.5*$fuzz;
        &drawForks($dHole,$rr,$fw/2,$i?2:0,$initialSpace);
        print $endPart;
    }
    print "</g>\n";
}


sub drawEFgroup() {
    local ($x0,$y0,$rot,$n) = (@_,16);

    print "\n<desc>EF, what used to be wide-braced knee.</desc>\n";
    local $wF = 2*$orF; # width of link at F node
    local $wE = 2*$orE-1; # width of EF link at E node
    local $dy = ($wF+$wE)/2;
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $dsh = 40;  # make screw hole fairly coarse in attempt to make it "tighter" around screw, but where we just need to "scratch" the facets to widen a bit
    local $r = $irS; # radius of screw holes
    for (local $i=0; $i < $n; $i+=2) {
        &startPart(0, $i   *$dy);
           &drawCircle(1.5*$dHole,0,$r,360/$dsh);
           &drawLink($EF,$wF,$r,$r,$wE,$i?2:0,10);
        print $endPart;
        next if ($i+1>=$n);
        &startPart(0,($i+1)*$dy);
           &drawCircle($EF-1.5*$dHole,0,$r,360/$dsh);
           &drawLink($EF,$wE,$r,$r,$wF,   2  ,10);
        print $endPart;
    }
    print "</g>\n"; # end of group translation
}

sub drawCrankLinkGroup() {
    local ($x0,$y0,$rot,$len,$dra,$drs) = (@_,0,0);

    print "\n<desc>$len mm crank-link group</desc>\n";
    local $wS = 13.5;#2*6;# width of link at hinge
    local $wA = 13.5;#2*6;#7;# width of link at crank
    local $dy = ($wA+$wS)/2;
    local $rs = $irH + $drs;
    local $ra = $irA + $dra; # change to all 3/16" $Arad+$fuzz/2;  # $Arad is for critically tight
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    for (local $i=0; $i < 8; $i+=2) {
        &startPart(0, $i   *$dy); &drawLink($len,$wS,$rs,$ra,$wA,$i?2:0); print $endPart;
        &startPart(0,($i+1)*$dy); &drawLink($len,$wA,$ra,$rs,$wS,   2  ); print $endPart;
    }
    print "</g>\n"; # end of group translation
}

sub drawBHgroup() {
    local ($x0,$y0,$rot,$n) = (@_,16);

    print "\n<desc>BH, from axle to edge of foot, double brace on outside</desc>";
    local $wH = 2*$orH-1;
    local $wB = 2*$orB;
    local $dx = ($wB+$wH)/2;
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    &startPart(0,0);
    for(local $j=0;$j<$n;$j++) { # also anchor holes for possible BH braces
        local $xx = $braceBHdist*$dHole; $xx = $BH-$xx if (($j % 2)==1);
        &drawCircle($xx,$j*$dx,$irS,12);
    }
    print $endPart;
    local $rh = $irS; # radius of screw used for H hinge
    local $rb = $irB; # radius for hole at B axis
    for ($i=0;$i<$n;$i+=2) {
        &startPart(0,$i*$dx);     &drawLink($BH,$wB,$rb,$rh,$wH,$i?2:0); print $endPart;
        next if ($i+1 >= $n);
        &startPart(0,($i+1)*$dx); &drawLink($BH,$wH,$rh,$rb,$wB,2); print $endPart;
    }
    print "</g>\n"; # end of group translation
}

sub drawBEDforkGroup() { # need a total of 8 of these
    local ($x0, $y0, $rot, $n, $flags) = (@_,0);
    local $topless = $flags & 1;

    print "\n<desc>BED D-link fork tynes</desc>\n";
    print "<g transform=\"translate($x0,$y0) rotate($rot)\">\n";
    local $dy = $orD;#6;
    for (local $i=0; $i<$n; $i++) {
        &startPart(0,$i*$dy*2);
        &drawForks($dHole,$irS,$orD,$i?2:($topless?2:0),1.5);
        print $endPart;
    }
    print "</g>\n";
}

1;
