# $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/involuteGear.pl $
# $Id: involuteGear.pl 302 2013-11-02 20:31:05Z mrwhat $
#
# Conversion of core parts of scad script:
#
# Parametric Involute Bevel and Spur Gears by GregFrost
# It is licensed under the Creative Commons - GNU GPL license.
# © 2010 by GregFrost
# http://www.thingiverse.com/thing:3575
#
# To perl script to draw gear in SVG

sub defaultGearParams() {
    local %a;
    $a{'number_of_teeth'} = 15;
    $a{'pitch' } = 5;
    $a{'pressure_angle' } = 20; # degrees
    $a{'clearance'      } = 0.2;
    $a{'backlash'} = 0;
    $a{'involute_facets'} = 6;
    return(%a);
}

$pi=3.1415926535897932384626433832795;
$deg2rad = $pi / 180;

# find the pitch for 2 gears, $dist apart, with given desired no. of teeth
sub scalePitch() {
  local ($dist,$n1,$n2)=@_;
  return(2*$pi*$dist/($n1+$n2));
}

# this definition of diameteral pitch seems odd to me, so I removed it from 
# the base routines.  I'm including the conversion here for completeness,
# in case there are some machinist's texts that use it.
#
# convert diameteral pitch (in degrees/distance?) to circular pitch (disance)
sub diameteralPitch2circular() { return (180/$_); }

#number_of_teeth=15,
#pitch
#pressure_angle=28,
#clearance = 0.2,
#backlash=0,
#involute_facets
sub drawInvoluteGear () {
    local %p = @_;

    local $pitch = $p{'pitch'};
    ($pitch > 0) or die("need to define pitch, the tooth period distance");

    # Pitch diameter: Diameter of pitch circle.
    local $number_of_teeth =  $p{'number_of_teeth'};
    local $pitch_diameter  =  $number_of_teeth * $pitch / $pi;
    local $pitch_radius = $pitch_diameter/2;
    printf STDERR ("\n=== %d Teeth\n", $number_of_teeth);

    # Base Circle
    local $base_radius = $pitch_radius * cos($p{'pressure_angle'} * $deg2rad);

    # Diametrial pitch: Number of teeth per unit length.
    local $pitch_diametrial = $number_of_teeth / $pitch_diameter;

    # Addendum: Radial distance from pitch circle to outside circle.
    local $addendum = 1/$pitch_diametrial;

    #Outer Circle
    local $outer_radius = $pitch_radius + $addendum;

    # Dedendum: Radial distance from pitch circle to root diameter
    local $dedendum = $addendum + $p{'clearance'};

    # Root diameter: Diameter of bottom of tooth spaces.
    local $root_radius = $pitch_radius - $dedendum;
    local $backlash_angle = ($p{'backlash'} / $pitch_radius) * $deg2rad;
    local $half_thick_angle = (360 / $number_of_teeth - $backlash_angle) / 4;
    &drawGearShape ($number_of_teeth,$pitch_radius,$root_radius,
		$base_radius,$outer_radius,$half_thick_angle,
		$p{'involute_facets'});
}


sub drawGearShape () {
    local ($number_of_teeth,
	   $pitch_radius,
	   $root_radius,
	   $base_radius,
	   $outer_radius,
	   $half_thick_angle,
	   $involute_facets) = @_;

    print "<desc>Involute gear, $number_of_teeth teeth, pitch radius $pitch_radius,
root radius $root_radius, base radius $base_radius, outer radius $outer_radius,
half thich angle $half_thick_angle, $involute_facets facets</desc>\n";

    local @gearPath = &involuteGearTooth($pitch_radius,	$root_radius, $base_radius, $outer_radius,
				$half_thick_angle, $involute_facets);
    &startPart(0,0);
    &printPath('M',@gearPath);
    for (local $i=1; $i < $number_of_teeth; $i++) {
        local @rp = &rotatePath($i*360/$number_of_teeth,@gearPath);
        &printPath('L',@rp);
    }
    printf(" L%.2f,%.2f $endPart\n",$gearPath[0],$gearPath[1]);
}

sub rotatePath() {
    local ($rot,@p) = @_;

    $rot *= $deg2rad;
    local $c = cos($rot);
    local $s = sin($rot);
    for(local $i=0; $i < $#p; $i+=2) {
        local $x = $p[$i  ];
        local $y = $p[$i+1];
        $p[$i  ] = $c*$x - $s*$y;
        $p[$i+1] = $c*$y + $s*$x;
    }
    return(@p);
}

sub printPath() {
    local ($firstSym,@p) = @_;

    printf(" $firstSym%.2f,%.2f",$p[0],$p[1]);
    for(local $i=2; $i < $#p; $i+=2) {
        printf("\nL%.2f,%.2f",$p[$i],$p[$i+1]); }
}

# return a list of points tracing the outline of a gear tooth
sub involuteGearTooth () {
    local ($pitch_radius, $root_radius, $base_radius, $outer_radius,
	   $half_thick_angle, $involute_facets) = @_;

print STDERR "\tpitch radius\t$pitch_radius
\troot radius\t$root_radius
\tbase radius\t$base_radius
\touter radius\t$outer_radius
\thalf angle\t$half_thick_angle
\tfacets\t\t$involute_facets\n\n";
    local $min_radius = ($base_radius > $root_radius) ? $base_radius : $root_radius;
#print STDERR "min radius : $min_radius\n";
    local $a = &involute_intersect_angle ($base_radius, $pitch_radius);
    local @pitch_point= &involute($base_radius,$a);
#printf STDERR ("pitch point : %.2f %.2f\n",$pitch_point[0],$pitch_point[1]);
    local $pitch_angle = atan2 ($pitch_point[1], $pitch_point[0]) / $deg2rad;
#print STDERR "pitch angle : $pitch_angle\n";
    local $centre_angle = $pitch_angle + $half_thick_angle;

    local $start_angle = &involute_intersect_angle($base_radius,   $min_radius);
    local $stop_angle  = &involute_intersect_angle($base_radius, $outer_radius);

    local $res=$involute_facets;

    local @x;
    local @y;
    for (local $i=0; $i <= $res; $i++) {
	$a = ($stop_angle - $start_angle) / $res;
	$a = $start_angle + $a * $i;
	local @p = &involute($base_radius, $a);
	@p = &rotate_point($centre_angle, @p);
        push(@x,$p[0]);
        push(@y,$p[1]);
    }
    local $scale0 = sqrt( ($x[0] * $x[0]) + ($y[0] * $y[0]) );
#print STDERR "root_radius=$root_radius \t scale0=$scale0\n";
    $scale0 = $root_radius / $scale0;
#print STDERR "scale0=$scale0\n";
    local @gearPath = ($scale0 * $x[0], $scale0 * $y[0]);
    for (local $i=0; $i <= $res; $i++) { push(@gearPath,$x[$i], $y[$i]); }
    @gearPath = &bevelGearEdge(@gearPath); # add little bevels to ends of gear edge
    local $n = ($#gearPath+1)/2;
    push(@gearPath,$x[$#x],0); # center point on tooth
    for (local $i=$n; $i > 0; $i--) { 
        local $k = ($i-1)*2;
        push(@gearPath,$gearPath[$k],-$gearPath[$k+1]);
    }
    return(@gearPath);
}

# add bevels to sharp corners at start and end of gear edge path
# ONLY WORKS on relatively large teeth with > 1mm flat areas at tip and base
sub bevelGearEdge() {
    #local @a + @_;
    local $n = ($#_+1)/2;
    local ($x0,$y0) = @_[0..1];
    local $r0 = sqrt($x0*$x0 + $y0*$y0);
    local $dx1 = $_[2] - $_[0]; # vector of first facet
    local $dy1 = $_[3] - $_[1];
    local $d1 = sqrt($dx1*$dx1 + $dy1*$dy1);
    local $del = .23; # standard small "radius" bevel?
    local @p = &rotate_point($del/($r0*$deg2rad),$x0,$y0);
    #push(@p,$x0+$del*$dx1/$d1,$y0+$del*$dy1/$d1,@_[2..$#_],$_[2*$n-2],0);
    if ($d1 > $del) {
        push(@p,$x0+$del*$dx1/$d1,$y0+$del*$dy1/$d1,@_[2..$#_]);
    } else { # first facet is closer than bevel dist, just drop it
        push(@p,@_[4..$#_]);
    }

    # bevel the tip, too...
    $n = ($#p-1)/2;
    local ($x1,$y1,$xn,$yn) = @p[2*($n-1)..2*$n+1];
    ($dx1,$dy1) = ($xn-$x1,$yn-$y1); # vector of last facet
    local $rn = sqrt($xn*$xn + $yn*$yn);
    $d1 = sqrt($dx1*$dx1 + $dy1*$dy1);
    local @pn = &rotate_point(-$del/($rn*$deg2rad),$xn,$yn);
    if ($d1 > $del) { # add a partial/bevel facet
        $p[2*$n  ] = $x1 + $del*$dx1/$d1;
        $p[2*$n+1] = $y1 + $del*$dy1/$d1;
        push(@p,@pn);
    } else { # replace last facet with a slightly beveled one
        $p[2*$n  ] = $pn[0];
        $p[2*$n+1] = $pn[1];
    }
    return(@p);
}

# =============== Mathematical Functions

### Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
#source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

sub involute_intersect_angle () {
    local ($base_radius, $radius) = @_;

    local $a = $radius / $base_radius;
    return (sqrt ($a*$a - 1) / $deg2rad);
}

#sub mirror_point() { return($_[0],-$_[1]); }

sub rotate_point() {
    local ($rotate, @coord) = @_;

    local $a = $rotate * $deg2rad;
    local $c = cos($a);
    local $s = sin($a);
    return($c * $coord[0] + $s * $coord[1],
           $c * $coord[1] - $s * $coord[0]);
}

sub involute() {
    local ($base_radius, $involute_angle) = @_;

    local  $a = $involute_angle * $deg2rad;
    local $c = cos($a);
    local $s = sin($a);
    return($base_radius*($c + $a*$s),
           $base_radius*($s - $a*$c));
}
1;
