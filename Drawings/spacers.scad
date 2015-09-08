// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/spacers.scad $
// $Id: spacers.scad 125 2013-06-30 16:07:32Z aaron $

module spacer(h,r,d) { difference() {
   cylinder(h=h,r=r,$fn=48);
   translate([0,0,-.1])cylinder(h=h+.2,r=d,$fn=96);
}}

module spacers(h,r,d) {
rr=r*1.415+.7;
z=.2;
color("Cyan") cube([7*rr,7*rr,0.4]);
for (i=[1:2:5]) {
   for (j=[1:2:5]) {
      translate([   j *rr,   i *rr,z]) spacer(h,r,d);
      translate([(1+j)*rr,(1+i)*rr,z]) spacer(h,r,d);
   }
}}

spacers(4,5.5,2.2);
