// unified payload electronics mount

Bhole=2.38+.2;  // for brass tube
PCBhole = (25.4*3/32)/2;//1;  // found that 3/32" drill made good pilot for #4 self-piloting screw
include <JansenDefs.scad>;  // Bx 
layer1bias = 0.4;
platformHeight = 45; // from bar to top platform
mountHeight=15; // from bar to electronics platform
PCBwidth=43;
HoleInset=3;

thick=5;
t2=thick/2;

sf = 16;  // sphere faces

difference() {
   payloadMount(Bx,Bhole,PCBwidth,HoleInset,PCBhole);

   #for(x=[-1,1]) translate([x*Bx,0,-1]) cylinder(r=Bhole,h=44,$fn=25);
   translate([0,0,-4]) cube([200,200,8],center=true);
}

//translate([0,20,0]) L298mount();

thinWall=0.41;  // width of thinnest wall which will not get culled by slicer

module L298mount() intersection() { cube([99,99,4],center=true); 
    
  difference() {
    union() {
      hull() {
        cube([36,1,4],center=true);
        for(x=[-1,1]) translate([x*27,17,0])
          scale([5,5,3]) sphere(1,$fn=24);
      }
    }

    translate([0,20,0]) scale([16,11,4]) sphere(1,$fn=60);

    difference() {
      union() {
        //%scale([6,3,4]) sphere(1,$fn=36);

        for(x=[-1,1]) {
          translate([x*(PCBwidth/2-HoleInset),18,-4])
            #cylinder(r=PCBhole,h=9,$fn=15);

          translate([x*27,17,-4]) cylinder(r=1.6,h=9,$fn=15);
          translate([x*16,8,-4]) rotate([0,0,30]) cylinder(r=1.5,h=9,$fn=6);
          translate([x*23,10,-4]) rotate([0,0,30]) cylinder(r=2,h=9,$fn=6);
          translate([x*20.5,6,-4]) rotate([0,0,30]) cylinder(r=1.5,h=9,$fn=6);
          translate([x*17,4,-4]) rotate([0,0,30]) cylinder(r=1.5,h=9,$fn=6);
          translate([x*13,5,-4]) rotate([0,0,30]) cylinder(r=1.5,h=9,$fn=6);
          translate([x*9,4,-4]) rotate([0,0,30]) cylinder(r=2,h=9,$fn=6);
          translate([x*5,4,-4]) rotate([0,0,30]) cylinder(r=1.5,h=9,$fn=6);
        }
      }
      %cube([99,99,thinWall],center=true); // leave support wall
    }
  }
}






module payloadMount(axisSep,axisRad,platWidth,dHole,rHole) {
  //difference() {
    union() {
      //%braceBar(axisSep,axisRad);
      for (x=[-1,1]) hull() {
        translate([x*axisSep,0,0])
           cylinder(r1=axisRad+3,r2=axisRad+2,h=12,$fn=36);
        translate([x*(axisSep-14),0,0]) cylinder(r=0.4,h=1,$fn=4);
      }
      hull() {
        translate([0,5,2]) cube([2*axisSep,.5,4],center=true);
        cube([2*axisSep,1,1],center=true);
      }

      translate([0,-34,0]) rotate([90,0,0]) L298mount();

      for(x=[-1,1]) hull() {  // main side braces
        translate([x*axisSep,0,5]) scale([.6,.6,4]) sphere(1,$fn=16);
        translate([x*axisSep,0,0]) cube([2,2,1],center=true);
        translate([x*18,-34,0]) cube([4,4,1],center=true);
        translate([x*27,-34,8]) sphere(0.6,$fn=12);
      }

      *for(x=[-1,1]) hull() {  // secondary supports
        translate([x*1 , 4 ,0.5]) scale([3,1,1]) sphere(1,$fn=16);
        translate([x*16,-34,0.5]) scale([2,1,1]) sphere(1,$fn=16);
      }

    }
  //}
}
