// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/spacerTest.scad $
// $Id: spacerTest.scad 160 2013-08-16 13:20:33Z aaron $

// Design a bunch of spacers, for use in testing
// how much extra needs to be added to hole radiuses
// to account for printer slop

HoleSlop = 0.2;
HoleDelta = 0.075;

module spacer(thick,hr) { difference() {
cylinder(h=thick,r1=hr+2.2,r2=hr+2,$fn=48);
cylinder(h=3*thick,r=hr+HoleSlop,$fn=96,center=true);}}

module spacerBracket(thick,hr,delta) {
spacer(thick,hr);
translate([-2*(hr+2.5),0,0]) spacer(thick,hr-delta  );
translate([-4*(hr+2.5),0,0]) spacer(thick,hr-delta*2);
translate([-6*(hr+2.5),0,0]) spacer(thick,hr-delta*3);
translate([ 2*(hr+2.5),0,0]) spacer(thick,hr+delta  );
translate([ 4*(hr+2.5),0,0]) spacer(thick,hr+delta*2);
translate([ 6*(hr+2.5),0,0]) spacer(thick,hr+delta*3);}

Brad = 2.38;  // larger brass tube radius (3/16"? OD)
Arad = 1.59;  // smaller brass tube radius
rad4 = 1.38;  // radius of #4 screw, OD of thread
radS = 3.175; // radius of standoff for 4-40 screw (1/4" OD)
union(){
color("Cyan") hull() {
    translate([-38,  0,0]) cylinder(h=.4,r=6,$fn=7);
    translate([ 38,  0,0]) cylinder(h=.4,r=6,$fn=8);
    translate([-30,-12,0]) cylinder(h=.4,r=8,$fn=6);
    translate([ 30,-12,0]) cylinder(h=.4,r=8,$fn=6);
    translate([-24, 18,0]) cylinder(h=.4,r=8,$fn=6);
    translate([ 24, 18,0]) cylinder(h=.4,r=8,$fn=6);
}
translate([0,0,.2]) { spacerBracket(4,radS,HoleDelta);
translate([0,-11,0])  spacerBracket(4,Brad,HoleDelta);
translate([0, 10,0])  spacerBracket(4,Arad,HoleDelta); 
translate([0, 18,0])  spacerBracket(4,rad4,HoleDelta); }
}
