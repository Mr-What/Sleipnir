// unified payload electronics mount

Bhole=2.38+.2;  // for brass tube
PCBhole = (25.4*3/32)/2;//1;  // found that 3/32" drill made good pilot for #4 self-piloting screw
include <JansenDefs.scad>;  // Bx 
PCBholeSep=37;  // hole pattern for L298 module is a square this wide
PCBholeInset=15;  // from hole center to side of mount

thinWall=0.41;  // width of thinnest wall which will not get culled by slicer

//translate([0,20,0]) L298mount();

//translate([0,0,7.8]) payloadPlatform();

braceSep = PCBholeInset+PCBholeSep/2;
//for(a=[0,180]) rotate([0,0,a]) translate([0,braceSep,0]) rotate([90,0,0])
      payloadBrace();

// -----------------------------------------------------

module payloadBrace() difference() {
   payloadMount(Bx,Bhole);

   #for(x=[-1,1]) translate([x*Bx,0,-1]) cylinder(r=Bhole,h=44,$fn=25);
   translate([0,0,-4]) cube([200,200,8],center=true);
}


// dovetail tabs for platform
tabZ=3.6;  // offset for tab
tabSep=40; // distance between tab centers
module tab() cylinder(r1=5,r2=4.5,h=6,$fn=3);

module payloadPlatform() difference() {
  payloadPlatformShell();
  payloadPlatformCutouts();
}

module payloadPlatformCutouts() {
  intersection() {
    difference() {
      hull() for(x=[-1,1]) for(y=[-1,1]) translate([x*45,y*(braceSep-5),0])
         cylinder(r1=2,r2=3,h=6,$fn=16,center=true);

      // cutouts for dovetail tabs
      for(a=[0,180]) rotate([0,0,a])
         for(x=[-tabSep,0,tabSep]) translate([x,braceSep-tabZ,-3])
            rotate([0,0,-30]) scale(1.8) tab();
    }
    hexGrid();
  }
}


module hexGrid() {
dh=3.1;
c30=cos(30);  $fn=6;   dx=3*dh;  dy=2*c30*dh;
  translate([3*dh/2,-c30*dh,0])
    for(j=[-5:6]) for(i=[-5:4]) hex(i*dx,j*dy);
    for(j=[-6:6]) for(i=[-5:5]) hex(i*dx,j*dy);
}
module hex(x,y) translate([x,y,0])
   cylinder(r1=2,r2=2.6,h=6,$fn=6,center=true); 



module payloadPlatformShell() {
  intersection() {
    difference() {
      cube([100,2*braceSep,5],center=true);

      // slots for dovetail tabs
      for(a=[0,180]) rotate([0,0,a])
         for(x=[-tabSep,0,tabSep]) translate([x,braceSep-tabZ,-3])
            rotate([0,0,-30]) scale(1.1) tab();
    }

    // round off corners
    hull()for(x=[-1,1])for(y=[-1,1])translate([x*46,y*(braceSep-4),0])
       scale([4.5,4.5,3.5])sphere(1,$fn=36);
  }
}


module L298mount() intersection() { cube([59,99,4],center=true); 
    
  difference() {
    hull() for(x=[-1,1]) for(y=[-1,PCBholeInset-0.5])
       translate([x*(30-4),y,0])
          scale([4,4,3]) sphere(1,$fn=24);

    hull() {
       translate([0,12,0]) scale([ 9,4,6]) sphere(1,$fn=48);
       translate([0,22,0]) scale([18,1,8]) sphere(1,$fn=48);
    }

    difference() {
      union() {
        translate([0,4,0]) scale([ 5,2.5,5]) sphere(1,$fn=24);

        for(x=[-1,1]) {
          translate([x*PCBholeSep/2,PCBholeInset,-4])
            #cylinder(r=PCBhole,h=9,$fn=15);

          for (y=[6,14]) translate([x*26,y,-4]) cylinder(r=1.6,h=9,$fn=15);

          hull() {
            translate([x*21,7,0]) rotate([0,0,40*x])
                scale([5,1,5]) sphere(1,$fn=36);
            translate([x*22,13,0]) scale([1,2,5]) sphere(1,$fn=16);
          }
          hull() {
            translate([x*11,5,0]) rotate([0,0,30*x])
               scale([4,2,5]) sphere(1,$fn=36);
            translate([x*16,12,0]) scale([2,1,5]) sphere(1,$fn=12);
          }

        }
      }

      cube([99,99,thinWall],center=true); // leave support wall
    }
  }
}


module payloadMount(axisSep,axisRad) {
platOff=-34;  // L286 module mount platform offset
    union() {
      for (x=[-1,1]) //hull() {
        translate([x*axisSep,0,0])
           cylinder(r1=axisRad+3,r2=axisRad+2,h=12,$fn=36);
        //translate([x*(axisSep-14),0,0]) cylinder(r=0.4,h=1,$fn=4); }

      hull() { // top bar
        translate([0,5,2]) cube([2*axisSep,.5,4],center=true);
        cube([2*axisSep,1,1],center=true);
      }

      translate([0,platOff,0]) rotate([90,0,0]) L298mount();

      for(x=[-1,1]) {  // main side braces
        hull() {
          translate([x*axisSep,0,2]) scale([1.5,1,9]) sphere(1,$fn=16);
          translate([x*28,platOff,2]) scale([1,2,4]) sphere(1,$fn=16);
        }
        hull() {
          translate([x*axisSep,0 ,0.3]) scale([4,1,1.5]) sphere(1,$fn=16);
          translate([x*25,platOff,0.3]) scale([4,1,1.5]) sphere(1,$fn=16);
        }
      }

      for(x=[-tabSep,0,tabSep]) translate([x,5-1,tabZ])
         rotate([-90,0,0]) rotate([0,0,-30]) difference() {
            tab();
            %translate([0,0,2]) // pilot hole for plastic screw
               cylinder(r1=PCBhole-.5,r2=PCBhole+.2,h=5,$fn=13);
         }
    }
}
