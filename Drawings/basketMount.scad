// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/basketMount.scad $
// $Id: basketMount.scad 440 2015-04-04 14:06:00Z mrwhat $

// Mount to attach to axles and hold motor drive module


Bhole = 2.38+.2;  // for brass tube
include <JansenDefs.scad>; // Bx

thick=4;

module braceBar(axisSep,axisRad) { difference() { union() {
   for (a=[-1,1]) translate([a*axisSep,0,0]) hull() {
     cylinder(h=thick,r=axisRad+3,$fn=24);
     translate([-11*a,-2,0]) cylinder(h=thick,r=1,$fn=6);
   }

   hull() for(a=[-1,1]) translate([a*axisSep,-axisRad,0])
      cylinder(h=thick,r1=3.2,r2=2.4,$fn=8);
 }

 // main axle bar holes
 for (a=[-1,1]) translate([a*axisSep,0,-.1])
   cylinder(h=thick*2,r=axisRad,$fn=80);

 // u-beam groove
 hull() for(a=[-1,1]) translate([a*axisSep*.65,-2.6,7])
   scale([6,2,5]) sphere(r=1,$fn=24);
}}

t2=thick/2;
module ball(r=t2) sphere(r=r,$fn=16); // standard bar-end

module shelfCutOuts() {
  hull() {
    translate([0,0,29]) scale([1,3,1]) ball(1);
    translate([0,0,16]) scale([8,5,3]) ball(1);
    translate([0,0,4]) scale([4.5,4,4]) ball(1);
  }
  for (a=[-1,1]) hull() {
    translate([14*a,0,29]) scale([1,3,1]) ball(1);
    translate([14*a,0,10]) scale([7,4,3]) ball(1);
    translate([14*a,0, 4]) scale([3,4,2]) ball(1);
  }
  for (a=[-1,1]) hull() {
    translate([24*a,0,29]) scale([1,3,1]) ball(1);
    translate([25.5*a,0,20]) scale([6.5,4,3]) ball(1);
    translate([24*a,0, 6]) scale([1,3,1]) ball(1);
  }
  for (a=[-1,1]) hull() {
    translate([7*a,0,7]) scale([1,3,1]) ball(1);
    translate([7.6*a,0,2]) scale([3,3.5,2]) ball(1);
  }

  for (a=[-1,1]) hull() {
    translate([29*a,0,29]) scale([1.5,3,1.5]) ball(1);
    translate([32*a,0,25]) scale([1.5,3,1.5]) ball(1);
  }
  for (a=[-1,1]) hull() {
    translate([10*a,0,29]) scale([1,3,1]) ball(1);
    translate([7.5*a,0,25]) scale([3,3,1]) ball(1);
    translate([ 8*a,0,21.5]) scale([1,3,1]) ball(1);
  }
  for (a=[-1,1]) hull() {
    translate([17.5*a,0,29]) scale([1,3,1]) ball(1);
    translate([19.2*a,0,27]) scale([1,3,1]) ball(1);
    translate([18.6*a,0,25]) scale([1,3,1]) ball(1);
  }
  for (a=[-1,1]) hull() {
    translate([20.5*a,0,5]) scale([1,3,1]) ball(1);
    translate([20.5*a,0,3]) scale([3,3,2]) ball(1);
  }
     //for (a=[-1,1]) hull() {
     //  translate([18*a,0,19]) scale([1,3,1]) ball(1);
     //  translate([21*a,0,14]) scale([2,3,2]) ball(1);
     //}
  for (a=[-1,1]) {
    translate([a*34.5,0,30]) screwHole();
    translate([a*20.5,0,30.3]) screwHole(1.2);
    translate([5*a,0,29]) screwHole();
 }

}


module shelfCutOuts1() {
     for (a=[-1,1]) hull() {
       translate([31*a,0,27]) rotate([0,25*a,0])
         scale([1,3,2]) ball(1);
       translate([24*a,0,19])
         scale([4,3,2]) ball(1);
     }
     for (a=[-1,1]) hull() {
       translate([23*a,0,28]) scale([1,3,1]) ball(1);
       translate([19*a,0,23]) scale([3,3,2]) ball(1);
     }
     for (a=[-1,1]) hull() {
       translate([15*a,0,28]) scale([1,3,1]) ball(1);
       translate([14*a,0,26]) scale([2,3,2]) ball(1);
     }
     for (a=[-1,1]) hull() {
       translate([9*a,0,28]) scale([1,3,1]) ball(1);
       translate([9*a,0,24]) scale([2,3,2]) ball(1);
     }
     hull() {
       translate([0,0,28]) scale([1,3,1]) ball(1);
       translate([0,0,15]) scale([8,5,3]) ball(1);
       translate([0,0,4]) scale([3,3,2]) ball(1);
     }    
     for (a=[-1,1]) hull() {
       translate([14*a,0,20]) scale([1,3,1]) ball(1);
       translate([14*a,0,10]) scale([7,4,3]) ball(1);
       translate([14*a,0, 4]) scale([2,3,2]) ball(1);
     }
     for (a=[-1,1]) hull() {
       translate([7*a,0,8]) scale([1,3,1]) ball(1);
       translate([7.6*a,0,3]) scale([4,3.5,2]) ball(1);
     }
     for (a=[-1,1]) hull() {
       translate([30*a,0,18]) scale([1,3,1]) ball(1);
       translate([21*a,0,4]) scale([4,3.5,2]) ball(1);
     }
     //for (a=[-1,1]) hull() {
     //  translate([18*a,0,19]) scale([1,3,1]) ball(1);
     //  translate([21*a,0,14]) scale([2,3,2]) ball(1);
     //}
     for (a=[-1,1]) {
        translate([a*34.5,0,30]) screwHole();
        translate([a*27,0,29]) screwHole();
        translate([a*19,0,29]) screwHole();
        translate([5*a,0,28]) screwHole();
        translate([9*a,0,19]) screwHole();
        translate([a*18,0,19]) screwHole(1.2);
        translate([a*22,0,15]) screwHole();
     }
     for (a=[-1,1]) translate([12*a,0,34])
        scale([8,4,4]) ball(1);

}

module basketMount(axisSep,h) {
trapW = 0.8*Bx;
union() {
   braceBar(axisSep,Bhole);
   translate([-9,h,0]) cube([18,4,15]);

   // middle shelf
   translate([0,h/2,t2]) union() {
     difference() {
       hull() for (a=[-1,1]) {
         translate([ 24*a,0, 0]) ball(t2+.4);
         translate([ 38*a,0,32]) ball(); 
       }

       shelfCutOuts();
     }
     #hull() {
       translate([0,0,31]) cube([75,0.35,1],center=true);
       cube([47,0.35,1],center=true);
     }
   }

   for (a=[-1,1]) hull() {  // side rails
      translate([  8*a  ,h,t2]) ball(t2+.4);
      translate([trapW*a,0,t2]) ball(t2+.4); }

   for (a=[-1,1]) {  // corner braces
     translate([26.8*a,h/2-2,3]) rotate([0,0,-60*a]) 
       rotate([72,0,0]) {
         translate([ 1,0,0]) shelfBrace();
         translate([-.5,0,-.5]) mirror([1,0,0]) shelfBrace();
         rotate([-90,0,0]) translate([0,0,-1])
           cylinder(r1=2.5,r2=1.3,$fn=18,h=16);
       }

     //translate([-7*a,h+2,2]) rotate([0,0,60*a+(a+1)*90]) 
       //rotate([90,0,0]) scale([1,.7,1]) shelfBrace();
     hull() {
       translate([8*a,h+1,7]) ball(t2-.1);
       translate([8*a,h+1,t2]) ball(t2-.1);
       translate([12*a,h-7,t2]) ball(t2-.1);
     }

   }
}}

module screwHole(r=1.5,h=10,fn=13) {
  rotate([90,0,0])
    cylinder(r=r,h=h,$fn=fn,center=true);
}

module shelfBrace() {
  difference() {
    translate([0,0,-1.5]) cube([15,20,3]);
    translate([16,20,0]) scale([17,21,6]) sphere(1,$fn=36);
  }
}

WITH_BRIM=0;
if (WITH_BRIM) {
union() {
color("Cyan") hull() {
   translate([-Bx,0,0]) cylinder(h=.4,r=10,$fn=8);
   translate([ Bx,0,0]) cylinder(h=.4,r=10,$fn=8);
   translate([0,53,0])  cylinder(h=.4,r=22,$fn=6);
}
translate([0,0,.2]) basketMount(Bx,60);
}} else {
  difference() {
    basketMount(Bx,60);
    translate([0,0,-4]) cube([200,200,8],center=true);  }
}

