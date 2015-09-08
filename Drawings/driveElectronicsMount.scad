// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/driveElectronicsMount.scad $
// $Id: driveElectronicsMount.scad 437 2015-03-02 15:24:02Z mrwhat $

// Mount to attach to axles and hold motor drive module


Bhole=2.38+.2;  // for brass tube
PCBhole = 1;
include <JansenDefs.scad>;  // Bx 
layer1bias = 0.4;
platformHeight = 40;
mountHeight=15;
PCBwidth=43;
HoleInset=3;

thick=5;
t2=thick/2;

sf = 16;  // sphere faces

module braceBar(axisSep,axisRad) { difference() { union() {
   for (a=[-1,1]) translate([a*axisSep,0,0]) {
       //cylinder(h=thick,r1=axisRad+3,r2=axisRad+2,$fn=24);
     hull() {
       intersection() {
          translate([0,0,2]) scale([axisRad+3,axisRad+3,thick*.8]) sphere(r=1,$fn=24);
          translate([0,0,thick/2]) cube([22,22,thick],center=true);
       }
       translate([-a*16,-2,t2]) sphere(t2,$fn=24);
     }
   }

   // main bar
   //%hull() for (a=[-1,1]) translate([a*axisSep,-axisRad+1,0])
   //    cylinder(h=thick,r1=4,r2=3,$fn=6);
   hull() for (a=[-1,1]) translate([a*axisSep,-axisRad+.5,0])
      intersection() {
         #translate([0,0,2.5]) scale([4,3.5,3.5]) sphere(1,$fn=24);
         translate([0,0,t2]) cube([22,22,thick],center=true);
      }

   }

   // holes for main axle bars
   for (a=[-1,1]) translate([axisSep*a,0,-.1])
       cylinder(h=thick*2,r=axisRad,$fn=96);

   // u-groove in main bar
   hull() for (a=[-1,1]) translate([a*axisSep*.8,-axisRad*.8,4.1])
       scale([6,2,2.5]) sphere(r=1,$fn=18);
}}

module braceCutOut1(pw,mh,dh) {
    translate([-pw+dh,mh,0]) hull() {
       translate([0,0,11]) sphere(r=2.2,$fn=22);
       translate([0,0,4]) scale([3.5,3,2]) sphere(r=1,$fn=22);
    }

    for(b=[-1,1]) hull() {
      translate([-pw+dh-4*b,mh,13]) sphere(r=2.2,$fn=22);
      translate([-pw+dh-7.5*b,mh,5]) sphere(r=3,$fn=22);
    }
}

module braceCutOut(pw,mh,dh) {
    translate([-pw+dh,mh,0]) hull() {
       translate([0,0,11]) sphere(r=2.2,$fn=22);
       translate([0,0,4]) scale([3.5,3,2]) sphere(r=1,$fn=22);
    }

    for(b=[-1,1]) hull() {
      translate([-pw+dh-4*b,mh,13]) sphere(r=2.2,$fn=22);
      translate([-pw+dh-7.5*b,mh,5]) sphere(r=3,$fn=22);
    }
}

module mountBrace(pw,mh,dh) {
  union() {
    difference() {
      hull() {
        translate([-pw-10,mh, 2]) sphere(r=2,$fn=sf);
        translate([-4    ,mh, 2]) sphere(r=2,$fn=sf);
        //translate([-pw+dh,mh,16]) rotate([90,0,0])
        //  cylinder(h=4,r=5,$fn=26,center=true);
        translate([-pw+dh,mh,16]) intersection() {
           scale([6,4,6]) sphere(r=1,$fn=24);
           cube([15,4,15],center=true);
        }
      }

      braceCutOut(pw,mh,dh);
    }

    // put a (hopefully) single-layer wall across middle of brace.
    // makes it more stable, easier to print, and can be remioved
    // if desired.
    #hull() {
      translate([-pw+dh,mh,16]) cube([9,.35,2],center=true);
      translate([-pw/2-7,mh,2]) cube([pw+10,.35,1],center=true);
    }
  }
}
module mountBrace1(pw,mh,dh) {
  hull() { translate([-pw+2 ,mh,19]) sphere(r=2,$fn=sf);
           translate([-pw-10,mh, 2]) sphere(r=2,$fn=sf); }
  hull() { translate([-pw+2 ,mh,19]) sphere(r=2,$fn=sf);
           translate([-4    ,mh, 2]) sphere(r=2,$fn=sf); }
  translate([-pw+dh,mh,16]) rotate([90,0,0]) cylinder(h=4,r=6,$fn=6,center=true);
}

module motorDriverStand(axisSep,axisRad,platHeight,platWidth,dHole,rHole)
{
difference() { union() {
   braceBar(axisSep,axisRad);

if(0) {
   hull() { translate([-axisSep+thick, -2,t2]) sphere(r=t2-1,$fn=sf);
            translate([ axisSep-18,-2,22]) sphere(r=t2-1,$fn=sf); } hull() {
            translate([ axisSep-thick, -2,t2]) sphere(r=t2-1,$fn=sf);
            translate([-axisSep+18,-2,22]) sphere(r=t2-1,$fn=sf); } hull() {
            translate([-axisSep+thick, -2,t2]) sphere(r=t2,$fn=sf);
            translate([-axisSep+18,-2,22]) sphere(r=t2,$fn=sf); }
hull() {
            translate([ axisSep-thick, -2,t2]) sphere(r=t2,$fn=sf);
            translate([ axisSep-18,-2,22]) sphere(r=t2,$fn=sf); }
hull() {
            translate([-axisSep+18,-2,22]) sphere(r=t2,$fn=sf);
            translate([ axisSep-18,-2,22]) sphere(r=t2,$fn=sf); }
}

   mirror([1,0,0]) mountBrace(platWidth/2,mountHeight,dHole);
                   mountBrace(platWidth/2,mountHeight,dHole);

   hull() for(a=[-1,1]) translate([a*(platWidth/2+13),mountHeight,2])
      sphere(r=2.4,$fn=sf);

   for (a=[-1,1]) hull() {  // side diag rails
      translate([a*platWidth*.3,platHeight-.5,2]) sphere(r=2.4,$fn=sf);
      translate([a*(axisSep-5) ,    1        ,2]) sphere(r=2.4,$fn=sf); }

   translate([-platWidth*.35,platHeight-2,0]) cube([platWidth*.7,4,8]);
   }

   for (a=[-1,1]) translate([a*(platWidth/2-dHole),mountHeight,16])
      rotate([90,0,0]) cylinder(h=10,r=rHole,$fn=80,center=true);
}}


module footpad(r) { // pad to help a part stick to plate for 3D printer
   cylinder(h=layer1bias,r1=r,r2=r-.3,$fn=11); }

if (WITH_BRIM) {
union() { color("Cyan") hull() {
translate([-Bx,0,0]) footpad(12);
translate([ Bx,0,0]) footpad(12);
translate([-PCBwidth/2, platformHeight-2,0]) footpad(12);
translate([ PCBwidth/2, platformHeight-2,0]) footpad(12);
}
translate([0,0,layer1bias/2])
   motorDriverStand(Bx,Bhole,platformHeight,PCBwidth,HoleInset,PCBhole);
}} else {
  difference() {
    motorDriverStand(Bx,Bhole,platformHeight,PCBwidth,HoleInset,PCBhole);
    translate([0,0,-4]) cube([200,200,8],center=true); }
}

