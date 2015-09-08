// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/grid.scad $
// $Id: grid.scad 84 2013-06-05 14:18:07Z aaron $

// Grid to underlay small/thin parts to help them stick to base plate
// when printing.

BarHeight = 0.5;  // mm
BarWidth = 1.5;
BarSpacing = 5;
BarLen = 177;

union(){
for (x=[BarSpacing/2:BarSpacing:BarLen]) {
   translate([x,0,0]) cube([BarWidth,BarLen,BarHeight]);
   translate([0,x,0]) cube([BarLen,BarWidth,BarHeight]);
}}


