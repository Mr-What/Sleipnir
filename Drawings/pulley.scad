// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/pulley.scad $
// $Id: pulley.scad 336 2013-12-19 16:41:41Z mrwhat $

layer1bias=.4;  // optional bias from z=0 to form a solid bottom layer for better printing

module Daxle(rad,dRad,height) { difference() {
  cylinder(h=height,r=rad,$fn=96);
  translate([-rad-1,dRad,-1]) cube([2*rad+2,rad,height+2]); }}

module pulleyCore(pr,width) {
nFaces=180;
intersection() { union() {
   cylinder(h=width,r=pr,$fn=nFaces);
   cylinder(h=width,r1=pr+2,r2=pr-3,$fn=nFaces);
   cylinder(h=width*1.05,r1=pr-3,r2=pr+2,$fn=nFaces);
   }
   translate([0,0,-1]) cylinder(h=width+2,r=pr+1.6,$fn=nFaces/3);
}}

module pulleyRing(pr,width) { difference() {
   pulleyCore(pr,width);
   translate([0,0,2*layer1bias+.1]) cylinder(h=width+1,r1=pr-4,r2=pr+1.5,$fn=48);
   //translate([-20,-20,-1])cube([40,20,width+2]); // disgnostic to view cross-section
}}

module thinSpokes(pr,width) {
   for (a=[0,60,120,180,240,300]) {
       hull() { translate([cos(a)*(pr-1.3),sin(a)*(pr-1.3),.1]) {
          cylinder(h=1,r1=1.8,r2=.6,$fn=6);
          translate([0,0,width-0.8]) sphere(r=0.4); }
          cylinder(h=width+0.5,r1=1.5  ,r2=.4,$fn=6); }
       hull() { translate([cos(a)*(pr),sin(a)*(pr),.1])    
          translate([0,0,width-0.8]) scale([.4,.4,0.7]) sphere(r=1,$fn=10);
          translate([0,0,width+0.8]) sphere(r=0.4);  }
   }
}

module pulley(pr,width,Arad,Doff) {
rr=pr-2.5;
difference() { union() {
   pulleyRing(pr,width);
   thinSpokes(pr,width);
   cylinder(h=width+1.3,r1=Arad+2.5,r2=Arad+1.5,$fn=24);
   }
   translate([0,0,-.1]) {
      if (Doff > 0) { Daxle(Arad,Doff,2*width); }
      else          { cylinder(h=2*width,r=Arad,$fn=80);}}
}}

module simplePulley(pr,width,Arad,Drad) { difference() { union() {
   pulleyCore(pr,width);
   cylinder(h=width+1,r1=Arad+3,r2=Arad+2,$fn=24);
   }
   translate([0,0,-.1]) {
      if (Drad >= 0) { Daxle(Arad,Drad,2*width); }
      else           { cylinder(h=2*width,r=Arad,$fn=80);}}
}}

module halfPulleyRing(pr,width) { difference() { intersection() {
   union() {
      cylinder(h=width,r1=pr+width/3+2,r2=pr-width*.6,$fn=180);
      cylinder(h=width,r1=pr+.1,r2=pr-.1,$fn=180); }
   translate([0,0,-.5]) {
      cylinder(h=width+1,r1=pr+width/3+1,r2=pr+width/3+0.8,$fn=180); }
   }
   translate([0,0,2*layer1bias])
      cylinder(h=width,r1=pr-4,r2=pr-3,$fn=48);
}}

module spokes(pr,tabR,width,Arad) { intersection() { union() {
   for (a=[0,60,120,180,240,300]) {
       hull() { translate([cos(a)*pr,sin(a)*pr,0])
          cylinder(h=width,r1=4,r2=3,$fn=6);
          cylinder(h=width,r2=2,r2=1,$fn=6); }
       translate([cos(a)*tabR,sin(a)*tabR,width-1])
          cylinder(h=3,r1=1.2,r2=.9,$fn=6);
   }
   cylinder(h=width,r1=Arad+3,r2=Arad+2,$fn=24);
   }
   translate([0,0,-1]) cylinder(h=width+2.5,r=pr-1,$fn=48);
}}

module halfPulley(pr,width,Arad,Drad) {
tabR = max(pr*.6,pr-5);
difference() { union() {
   halfPulleyRing(pr,width);
   spokes(pr,tabR,width,Arad);
   }
   translate([0,0,-.03]) {
      if (Drad >= 0) { Daxle(Arad,Drad,2*width); }
      else           { cylinder(h=2*width,r=Arad,$fn=80);}

      // knock out holes for alignment tabs
      for (a=[60,180,300]) {
         hull() { translate([cos(a)*tabR,sin(a)*tabR,width-2.5])
            cylinder(h=width*2,r1=1.2,r2=2,$fn=6); }}
   }
}}

// small 60rpm gearhead motor axle is 1.5mm rad, 1mm Doffset
//  (i.e.  3mm diam, diam to flat D is 2.5mm

//union() { color("Cyan") cylinder(h=layer1bias,r=25,$fn=19)
//translate([0,80,0]) 
   pulley(17,4,2);  // like for main axle
translate([30,0,0]) simplePulley(7,4,1.5+.3,1+.3); // like for small gearhead motor drive pulley
//translate([0,0,.1])
//translate([0,35,0]) halfPulley(18,3,1.59+.25,-1);
//halfPulley(8,2.5,1.5+.3,1+.3); // like for small gearhead motor drive pulley
//}
