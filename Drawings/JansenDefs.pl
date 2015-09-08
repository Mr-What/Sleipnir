# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/JansenDefs.pl $
# $Id: JansenDefs.pl 427 2014-08-23 20:42:39Z mrwhat $
#
# Definitions for a Jansen linkage, with parameter settings to include
# in a perl script to generate laser-cut drawings
########################################################################
# (A) This one had longer, rounder steps, but not quite as wide(stable) of a stance.
#  This yielded the initial 3D printed prototype robot.
#     Althogh a locked linkage was found about .6mm from this one, this did
#     not exhibit much stiff-near-locked issues when initially built
#      circa June 2103
#$AC = 17.5;
#$Ay=6.1;  $Bx=48; 
#$BH=43.2;  $EF=46.35;
#$CD=59;   $CH=73.2;
#$BD=48.6; $BE=46.7; $DE=65.4;
#$FG=77;   $FH=41.3; $GH=56.2;

# configuration (B) circa August 2013.  Although my optimizer code
# ranked this as farther from "lock" than (A), it exhibited locking
# behavior when printed
$AC = 17.5;
#$Ay =  5.53;  $Bx =  51.17;
#$BD = 48.41;  $BE =  45.76;  $BH = 42.87;
#$CD = 59.19;  $CH =  74.37;  $DE = 65.34;
#$EF = 46.13;  $FG =  77.29;
#$FH = 41.77;  $GH =  54.44;

$config = 'E';
# configuration (D) circa 130909.  Added factor to favor configurations
# where the CH linkage stays away from the B axle.
# smoother motion.  Seems likely to be more robust to small manufacturing errors
#  Opt17 run, plot 237:
# 1.38 -51.33 48 46.23 44.2 59.79 73.6 67.47 47.47 77.51 41.63 54.86
# had a little bit of a bump when cranks were vertical, and feet were a mm or two
# high on the step cycle (robot dropped down a mm or 2), point of low PE that needed
# to be lifted up as cranks went past vertical.
if ($config eq 'D') {
    print STDERR "setting Jansen configuration D\n";
    $Ay =  1.38; $Bx = 51.33;
    $BD = 48   ; $BE = 46.23; $BH = 44.2 ;
    $CD = 59.79; $CH = 73.6 ; $DE = 67.47;
    $EF = 47.47; $FG = 77.51;
    $FH = 41.63; $GH = 54.86;
} else { #if ($config == 'E') {
# configuration (E) circa 140227.  Tried to flatten stride, in the hopes
# that the little dip when cranks are vertical will be less pronounced than
# in cofiguration (D).
#3.318 -53.833 48.020 46.977 40.359 59.635 71.441 66.437 47.467 75.792 40.843 55.790
    print STDERR "setting Jansen configuration E\n";
    $Ay =  3.318; $Bx = 53.833;
    $BD = 48.020; $BE = 46.977; $BH = 40.359;
    $CD = 59.635; $CH = 71.441; $DE = 66.437;
    $EF = 47.467; $FG = 75.792;
    $FH = 40.843; $GH = 55.790;
}

$cutWidth=$preview?.2:.01;  # suggested .01 for real (ponoko) laser cut, but we can't see that in pixel display

# hardware size definitions
$mmi = 25.4;  # millimeters/inch (I think this is EXACT.  Actually 25.40000)
$diamQ = $mmi/4;  # 1/4"
$diam316 = $mmi*3/16;

#$Bdiam = 4.76;  # diameter of B axle 3/16" .. ideal 4.7625
$Bdiam = 6.35;  # move to 1/4" OD axle, same as standoff?
$Adiam = 3.18;  # diam of A (crank) axle, 1/8" ... ideal 3.175
#$diamS = 4.744; # 3/16" OD nylon spacer, measured
$diamS = $diamQ;  # 1/4"  OD Al  standoff, measured
$diam4 = 2.76;  #4-40 screw, OD of thread
$diam2 = 2.2;   #2-56 screw, OD of thread
# hole radii, with fuzz for laser width

#$fuzz = 0.1; # subtract fuzz from holes in wood.  In plastic, fuzz seems much smaller due to melt filling
# Quelab's laser seems to have a slightly larger kerf.
$fuzz = 0.15;

$Brad = $Bdiam/2 - $fuzz;  # snug, critical fit
$Arad = $Adiam/2 - $fuzz/1.15; # tight, for press-fit
$rad2 = $diam2/2 - $fuzz; # sufficient for screw pass-through (NOT for tapping)
$radS = $diamS/2 + $fuzz*0.35;  # loose, for free-moving hinges
# try to standardize, all 1/4" standoff, axles, no. 4 screws
$rad4 = $diam4/2 - $fuzz*0.01; # sufficient for screw pass-through (NOT for tapping) on acrylic
$radQ = $diamS/2 + $fuzz*0.5;  # loose, for free-moving hinges

$dHole = 10;  # mm between holes on braces
#$Frad = 7;  # braced knee joint radius
$Frad = 9;#10;  #  7 is actually thinner than default for 1/4" standoffs
$linkWidth = $dHole;

#$deg2rad = 0.01745329252;
$endPart = "'></path></g>\n";  # endpath and location(translation) group to end each part

############ Set standard parameters for node hole radii (ir ... inner radius)
#                                         and node radii (or ... outer radius)
$irS = $diam4  /2 - 0*$fuzz;  # free passthrough, #4-40 screws

$irA = $diam316/2 + 0.2*$fuzz;  # for free main-bar bearing surface
$irB = $irA;  # free rotating for BED, BH -- moved to 3/16 steel main bar
$irC = $irA;  # for C-side of crankLinks, CD, CH
#$irD = $diamQ  /2 + 0.2*$fuzz;  # for D side of CD
$irD = $irC;  # using 3/16" OD standoffs, for D side of CD
$irE = $irD;  # for BED E hole, free rotating over 1/4" standoff, for now
$irF = $irD;
$irH = $irC;  # using 3/16" OD 1/2" long standoff

$orA = 6; # for crank-arms
$orB = 7.5; # B of BED and BH
$orC = 7; # C-side of CD, CH
$orD = 6; # D-forks on BED
$orE = 7;
$orF = 9; 
$orG = 6; # foot (Ground)
$orH = 7.5; # for around 3/16 standoff hinge # 7.5 seems good for thick foot, forks could be smaller

################################################## Final re-scale for drawings
$DesiredCrankLen = 20; # I think I'll try this size for an eventual 384mm sq full robot print

#scale things up a bit for a "standard" 20mm crank
($AC,$Ay,$Bx,$BD,$BE,$BH,$CD,$CH,$DE,$EF,$FG,$FH,$GH) = &vScale($DesiredCrankLen/$AC,
 $AC,$Ay,$Bx,$BD,$BE,$BH,$CD,$CH,$DE,$EF,$FG,$FH,$GH);

# derived Jansen linkage dimensions
$DEleft = ($DE*$DE + $BD*$BD - $BE*$BE)/(2*$DE);
$FGleft = ($FG*$FG + $FH*$FH - $GH*$GH)/(2*$FG);
$DEperp = sqrt($BD*$BD - $DEleft*$DEleft);
$FGperp = sqrt($FH*$FH - $FGleft*$FGleft);

### This distance varies with each configuration, and various hard to analyse
# factors like linkage widths, motor size...
# It is too hard for me to compute, so I'm just setting it by hand.
$dA_Motor = 40;# 40 OK if spacers/braces BELOW motor 45;  # distance from A axis to drive motor axis
# At this seperation, here is a gear pair for a slow motor (feet period FASTER than motor axle) :
$gearPitch = 10.01;#8.54;
$teethDrive = 8; # OD=16*2 ##13;  # OD = 2*20.377
$teethMotor = 17;#20;
$drivePlateOR = 18.5;# <-- smaller for 2mm plates20; #25;  # gear radius, 20.377 
$rShaft = 1.5 - 0.10*$fuzz; # motor drive shaft dimensions
$dShaft = 1   - 0.05*$fuzz;

# Assuming circular head on gearhead motor
$motorRad = 7.75;  # no fuzz needed on Acrylic
$motorType = "16GA1627";  # isreali motor slightly bigger/longer
#$motorType = "mitsumi";  # fasttech 16GA motor
$gearHeadRad = ($motorType eq "16GA1627") ? 8 : $motorRad;

1;
