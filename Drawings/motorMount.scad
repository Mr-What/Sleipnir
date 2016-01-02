// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/motorMount.scad $
// $Id: motorMount.scad 427 2014-08-23 20:42:39Z mrwhat $

// Mount to attach to axles and hold motor drive module

// Distance from top edge of mount to center of motor axle:
// at 30mm offset, belts were not as tight as I'd like.
// ?? try 40?
motorOffset=40;

// shape of small gearhead motor GA12YN20 from fasttech.com
module gearheadMotorProxyGA12(pad) { union() {
cube([10+pad,12+pad,9.2+pad],center=true);
translate([0,0,-(9.2+pad)/2-7.9]) difference() {
   cylinder(h=10,r=1.5,$fn=36);
   translate([1,-2,-.1]) cube([2,4,7.7]); }
intersection() {
   translate([0,0,9.2/2-1])cylinder(h=15+pad+1,r=(12+pad)/2,$fn=48);
   cube([10+pad,12+pad,66],center=true); }
}}

// Slightly larger 60RPM gearhead motor.
// same size?  35RPM GA16Y030 fasttech
module gearheadMotorProxyGA16(pad) {
difference() { union(){
translate([0,0,10-29]) cylinder(h=29,r=7.75+pad,$fn=64);
cylinder(h=10+5,r=1.5,$fn=36);
}
translate([ 6  ,-10,10-29-1]) cube([5,20,29-10+1]);
translate([-6-5,-10,10-29-1]) cube([5,20,29-10+1]);
translate([1.5-(3-2.44),-2,1+10]) cube([2,4,5]);
}}

// larger 30RPM gearhead (as delivered) motor GA25Y310 fasttech
// photo and specs on site do not match delivered product.
// drawing is of delivered product, marked 25GA370-98, 30RPM
module gearheadMotorProxyGA25(pad) {
difference() { union(){
translate([0,0,-31]) cylinder(h=32,r=12.2+pad,$fn=64);
cylinder(h=23.5,r=12.6+pad,$fn=64);
translate([0,0,24]) cylinder(h=10,r=2,$fn=36);
translate([0,0,23]) cylinder(h=2.5,r=3.5,$fn=36);
}
translate([1.5,-3,23.5+3]) cube([2,6,8]);
}}

bh=4;
br1=2;
br2=1.5;

module ulc(dx,dy) { translate([-20+dx,-1.5+dy,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
module urc(dx,dy) { translate([ 20+dx,-1.5+dy,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
module llc() { translate([-6,-motorOffset-2,0]) cylinder(h=bh+2,r1=br1,r2=.5,$fn=6); }
module lrc() { translate([ 6,-motorOffset-2,0]) cylinder(h=bh+2,r1=br1,r2=.5,$fn=6); }

dtFuzz = 0.08;  // fuzz to add to dove tail slots

module motorMount() {
  difference() {
    union() {
      hull() { ulc(0,0); urc(0,0); }
      hull() { ulc(2,-1); urc(-2,-1); }
      hull() { ulc(0,0); llc(); }
      hull() { urc(0,0); lrc(); }
      for (a=[-1,1]) hull() { 
        translate([.6*a, -2,0]) cylinder(h=bh  ,r1=2,r2=0.5,$fn=6);
        translate([ 7*a,-motorOffset+2,0]) cylinder(h=bh+2,r1=2,r2=0.5,$fn=6);
      }

      hull() for (a=[-1,1]) {
        translate([5*a,-motorOffset+6,0]) cylinder(h=bh*2,r1=3.2,r2=3,$fn=6);
        translate([4*a,-motorOffset-2,0]) cylinder(h=20  ,r1=4.6,r2=4,$fn=6);
      }
    }

    // dove-tail receivers, 2x as high as actual, with 2x radius reduction
    // so they have the same wall slope, but are extra long to make
    // sure they cut all the way through the top brace bar
    for (a=[-1,1]) translate([10*a,-1,1-0.1]) rotate([0,0,-30])
       cylinder(h=6,r2=5+dtFuzz,r1=3+dtFuzz,$fn=3);

    // at 30mm offset, belts were not as tight as I'd like.
    // ?? try 40?
    #translate([0,-motorOffset,3.9]) gearheadMotorProxyGA12(0.4);
  }
}

if (WITH_BRIM) {
union() { color("Cyan") hull() {
  translate([-30,0,0]) cube([60,7,.4]);
  translate([-13,-42,0]) cube([26,.1,.4]); }
translate([0,0,.2]) motorMount();
}}
else { motorMount(); }

//%translate([0,30,0])  gearheadMotorProxyGA16(0);
//%translate([30,0,0])  gearheadMotorProxyGA12(0.2);
//%translate([-40,0,0]) gearheadMotorProxyGA25(0.2);