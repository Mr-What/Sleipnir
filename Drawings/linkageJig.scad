// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/linkageJig.scad $
// $Id: linkageJig.scad 96 2013-06-13 13:09:19Z aaron $

// if we are trying to use 1/4" (20 tpi) pegs in the linkage,
// that is around a 6mm hole (tapping will add a bit)

HoleRad=.3;  // for tapping 1/4", 20tpi
BaseWidth = 6;
BaseHeight = 4;
WallThick = .5;
BaseLen = 30;

BarHeight = BaseHeight + 1;
BarLen = 2*BaseLen;

SlotHoleRad = HoleRad + 0.15;

// Define PART to one of the following values to generate model for desired part.
//       Base , Bar    (default is slat to help printing)
PART="Bar";


// Scale some things up for 3D printing.  At 10:1, some things are too small to print
HoleRad = .6;  SlotHoleRad = .7; WallThick = 1.4;

module tapHole () { cylinder(h=BaseHeight*1.2,r=HoleRad,$fn=96); }
module drillHole () { cylinder(h=BaseHeight*1.2,r=SlotHoleRad,$fn=96); }
module slotHole () { cylinder(h=BaseHeight*1.2,r=SlotHoleRad,$fn=16); }

module TriLinkageJigBase()
{ difference() { union() {
   translate([-BaseLen,-BaseWidth/2,0])
      cube([2.2*BaseLen,BaseWidth,BaseHeight]);
   translate([-BaseWidth/2,0,0])
      cube([BaseWidth,BaseLen*0.9,BaseHeight]);
   }
   translate([-1.1*BaseLen,-BaseWidth/2+WallThick,WallThick])
      cube([2.4*BaseLen,BaseWidth-2*WallThick,BaseHeight]);
   translate([-BaseWidth/2+WallThick,0,WallThick])
      cube([BaseWidth-2*WallThick,BaseLen,BaseHeight]);
   translate([-BaseLen+BaseWidth/2,0,-.1]) drillHole();
   translate([-BaseWidth*.9,0,-.1]) drillHole();
   translate([BaseWidth*.9,0,-.1])  drillHole();
   translate([BaseLen*1.2-BaseWidth*.5,0,-.1]) drillHole();
   translate([-BaseLen/2,0,-.1]) drillHole();
   translate([.6*BaseLen,0,-.1]) drillHole();
   translate([0,BaseWidth,-.1]) drillHole();
   translate([0,BaseLen*.9-BaseWidth*.5,-.1]) drillHole();
   translate([0,BaseLen*.4,-.1]) drillHole();
   hull () {
     translate([-BaseLen+BaseWidth,0,-.1]) slotHole();
     translate([-BaseLen/2-0.4*BaseWidth,0,-.1]) slotHole(); }
   hull () {
     translate([BaseLen*1.2-BaseWidth,0,-.1]) slotHole();
     translate([.6*BaseLen+0.4*BaseWidth,0,-.1]) slotHole(); }
   hull () {
     translate([1.4*BaseWidth,0,-.1]) slotHole();
     translate([.6*BaseLen-0.4*BaseWidth,0,-.1]) slotHole(); }
   hull () {
     translate([-1.4*BaseWidth,0,-.1]) slotHole();
     translate([-.5*BaseLen+0.4*BaseWidth,0,-.1]) slotHole(); }
   hull () {
     translate([0,1.4*BaseWidth,-.1]) slotHole();
     translate([0,0.4*BaseLen-0.4*BaseWidth,-.1]) slotHole(); }
   hull () {
     translate([0,0.8*BaseLen-0.4*BaseWidth,-.1]) slotHole();
     translate([0,0.4*BaseLen+0.4*BaseWidth,-.1]) slotHole(); }
   }
}


module LinkageBar() {
BarWidth = BaseWidth+2.2*WallThick;
difference(){
    translate([0,-BarWidth/2,0]) cube([BarLen,BarWidth,BarHeight]);

  translate([-.1,-BaseWidth/2-.1*WallThick,WallThick])
     cube([BarLen*1.1,BaseWidth+.2*WallThick,BarHeight]);
  translate([BaseWidth/2,0,-.1]) tapHole();
  translate([BarLen-BaseWidth/2,0,-.1]) drillHole();
  translate([0.4*BarLen,0,-.1]) drillHole();
  translate([0.4*BarLen+BaseWidth/2,0,-.1]) tapHole();
  hull() {
     translate([BarWidth*.9,0,-.1]) slotHole();
     translate([0.4*BarLen-0.4*BarWidth,0,-.1]) slotHole(); }
  hull() {
     translate([BarLen-BarWidth,0,-.1]) slotHole();
     translate([0.4*BarLen+0.9*BarWidth,0,-.1]) slotHole(); }
  }
}

//=====================================================

if (PART=="Bar" ) { LinkageBar(); }
else {TriLinkageJigBase(); }
