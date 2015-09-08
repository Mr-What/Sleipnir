// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/motorMount.scad $
// $Id: motorMount.scad 427 2014-08-23 20:42:39Z mrwhat $

// Mount to attach to axles and hold motor drive module


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

bh=5;
br1=2.2;
br2=2;

module ulc(dx,dy) { translate([-20+dx,-1.5+dy,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
module urc(dx,dy) { translate([ 20+dx,-1.5+dy,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
module llc() { translate([ -6, -30,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
module lrc() { translate([  6, -30,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }

module motorMount() { difference() { union() {
//hull() { translate([-22,-1.5,0]) cube([44,2,5]);
//          translate([ -8,-32 ,0]) cube([16,1,5]); }
hull() { ulc(0,0); urc(0,0); }
hull() { ulc(2,-2); urc(-2,-2); }
//hull() { llc(); lrc(); }
hull() { ulc(0,0); llc(); }
hull() { urc(0,0); lrc(); }
hull() { translate([ 0, -3,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6);
         translate([-7,-22,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
hull() { translate([ 0, -3,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6);
         translate([ 7,-22,0]) cylinder(h=bh,r1=br1,r2=br2,$fn=6); }
//translate([-17,-5,0]) cylinder(h=bh,r1=4.2,r2=4,$fn=6);

//translate([-8,-30,0]) cube([16,13,5]);
hull() {
   translate([-5,-24,0]) cylinder(h=bh*2,r1=3.2,r2=3,$fn=6);
   translate([-4,-32,0]) cylinder(h=20  ,r1=4.6,r2=4,$fn=6);

   translate([ 5,-24,0]) cylinder(h=bh*2,r1=3.2,r2=3,$fn=6);
   translate([ 4,-32,0]) cylinder(h=20  ,r1=4.6,r2=4,$fn=6);
}}
#translate([0,-30,3.9]) gearheadMotorProxyGA12(0.4);
translate([ 10,0,0.8]) rotate([0,0,-30]) cylinder(h=4.4,r2=4+.4,r1=3+.2,$fn=3);
translate([-10,0,0.8]) rotate([0,0,-30]) cylinder(h=4.4,r2=4+.4,r1=3+.2,$fn=3);
}}

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