// unified payload electronics mount

Bhole=2.38+.3;  // for brass tube
PCBhole = (25.4*3/32)/2;//1;  // found that 3/32" drill made good pilot for #4 self-piloting screw
include <JansenDefs.scad>;  // Bx 
PCBholeSep=37;  // hole pattern for L298 module is a square this wide
PCBholeInset=15;  // from hole center to side of mount

thinWall=.35;//0.41;  // width of thinnest wall which will not get culled by slicer

//translate([0,20,0]) L298mount();

%translate([0,0,  7.8])                 payloadPlatform();
//%translate([0,0,-31.5]) rotate([180,0,0]) lowerPlatform();

braceSep = PCBholeInset+PCBholeSep/2;
*for(a=[0,180]) rotate([0,0,a]) translate([0,braceSep,0]) rotate([90,0,0])
      payloadBrace();

translate([0,0,9]) lid();

//translate([0,100,0]) payloadBrace();

//%translate([0,0,-29]) cylinder(r=4,h=31,$fn=4);

// -----------------------------------------------------

module payloadBrace() difference() {
   payloadMount(Bx,Bhole);

   #for(x=[-1,1]) translate([x*Bx,0,-1]) cylinder(r=Bhole,h=44,$fn=25);
   translate([0,0,-4]) cube([200,200,8],center=true);
}


// dovetail tabs for platform
tabZ=4.2;  // offset for tab
module tab(pilotHoleRad=0) difference() {
  cylinder(r1=7,r2=5.5,h=6,$fn=3);

  if (pilotHoleRad > 0.2) {
     translate([0,0,1]) // pilot hole for plastic screw
        #cylinder(r1=pilotHoleRad-.4,r2=pilotHoleRad+.2,h=6,$fn=13);
  }
}
tabCutoutScale = .4/6 + 1;  // want .2 mm space
tabShellScale  =  4/6 + 1;  // want  2 mm space
tabSepUpper=40;
tabSepLower=23;

module payloadPlatform() {
platWidth=100;
  difference() {
    payloadPlatformShell(  platWidth,tabSepUpper); // width, tab seperation
    payloadPlatformCutouts(platWidth,tabSepUpper);
  }
}
module lowerPlatform() {
platWidth=70;
hc=PCBholeSep/2;  // dist for L298N module sqare hole pattern
  difference() {
    payloadPlatformShell(  platWidth,tabSepLower); // width, tab seperation
    difference() {
      payloadPlatformCutouts(platWidth,tabSepLower);
      for(x=[-1,1]) for(y=[-1,1]) translate([x*hc,y*hc,0])
         cylinder(r1=4,r2=3,h=6,$fn=12,center=true);
    }

    // pilot holes for L298N module mount screws
    for(x=[-1,1]) for(y=[-1,1]) translate([x*hc,y*hc,-1])
       cylinder(r1=PCBhole+.3,r2=PCBhole-.2,h=4,$fn=12,center=true);
  }
}

module payloadPlatformCutouts(width=100,tabSep=40) {
  intersection() {
    difference() {
      hull() for(x=[-1,1]) for(y=[-1,1]) 
         translate([x*(width/2-5),y*(braceSep-5),0])
            cylinder(r1=2,r2=3,h=6,$fn=16,center=true);

      // cutouts for dovetail tabs
      for(a=[0,180]) rotate([0,0,a])
         for(x=[-tabSep,0,tabSep]) translate([x,braceSep-tabZ,-3])
            rotate([0,0,-30]) scale(tabShellScale) tab();
    }
    hexGrid();
  }
}


dh=3.1;
c30=cos(30);   dx=3*dh;  dy=2*c30*dh;
module hexGrid() {
  translate([3*dh/2,-c30*dh,0])
    for(j=[-5:6]) for(i=[-5:4]) hex(i*dx,j*dy);
    for(j=[-6:6]) for(i=[-5:5]) hex(i*dx,j*dy);
}
module hex(x,y,s=[1,1,1]) translate([x,y,0]) scale(s)
   cylinder(r1=2,r2=2.7,h=6,$fn=6,center=true); 

module lid() {
  difference() {
    union() {
      for (i=[-1,1]) {
        for (j=[-1,1]) translate([2*dx*i,5*dy*j,0]) {
           hull() {
             translate([0,  0 ,1.7]) cylinder(r=2.2,h=1.4,$fn=6);
             translate([0,1.5*j,3]) cylinder(r=.1 ,h=5,$fn=6); }
                              hex(0,0,[.9,.9,1]); }
        hull() {                hex(5*dx*i,  0   ,[.9,.9,1]);
           translate([(5*dx-0.6)*i,0,8]) sphere(0.1); }
      }
      difference() {
        lidShell();
        translate([0,0,0.3]) scale([.982,.976,.97]) lidShell();

        //trim off thin edges of shell
        translate([0,0,2.4]) cube([89,53,2],center=true);
      }
    }

    // trim off severe overhanging parts of tabs
    *hull() {
       translate([0,0,3.5]) cube([70,55,.1],center=true);
       cube([70,50,7],center=true);
    }

    // trim off part of tab in partial hex hole
    for(x=[-1,1]) translate([49.7*x,0,0]) rotate([0,10*x,0])
       cube([6,6,20],center=true);

    // pass through for cable ties to attach platform to sides
    for(x=[-1,1]) translate([x*28,0,2.7]) rotate([90,0,0])
       scale([3,2,1]) cylinder(r=1,h=77,$fn=16,center=true);

    //translate([0,0,-99]) cube([200,200,200]);
  }

}

module lidShell()
  hull() {
    for (x=[-1,1]) for(y=[-1,1]) {
      translate([44*x,26*y,4.6]) sphere(3,$fn=24);
      translate([40*x,23  *y,30 ]) sphere(3,$fn=24);
    }
}

// width of platform along axes  (Y width fixed)
// tabSep  -- seperation between tab centers
module payloadPlatformShell(width=100,tabSep=40) {
  intersection() {
    difference() {
      cube([width,2*braceSep,5],center=true);

      // slots for dovetail tabs
      for(a=[0,180]) rotate([0,0,a])
         for(x=[-tabSep,0,tabSep]) translate([x,braceSep-tabZ,-3])
            rotate([0,0,-30]) scale(tabCutoutScale) tab();
    }

    // round off corners
    hull()for(x=[-1,1])for(y=[-1,1])translate([x*(width/2-4),y*(braceSep-4),0])
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
platOff=-30+2;  // L286 module mount platform offset
    union() {

      for (x=[-1,1]) translate([x*axisSep,0,0])    // axle hubs
           cylinder(r1=axisRad+3,r2=axisRad+2,h=12,$fn=36);

      hull() { // top bar
        translate([0,4.7,4]) cube([2*axisSep,.7,8],center=true);
        translate([0,1.5,0]) cube([2*axisSep,1 ,1],center=true);
      }
      hull() for(x=[-1,1]) translate([axisSep*x,1.1,0.5])
            scale([1,4,1.5]) sphere(1,$fn=16);

      hull() { // lower bar
        translate([0,platOff-.7,4]) cube([60,.6,8],center=true);
        translate([0,platOff+1 ,0]) cube([60,1 ,1],center=true);
      }
      hull() for(x=[-1,1]) translate([31*x,platOff+3,0.3])
            rotate([0,0,-x*40]) scale([1,3.5,1.5]) sphere(1,$fn=16);

      //%translate([0,platOff,0]) rotate([90,0,0]) L298mount();

      for(x=[-1,1]) {  // main side braces
        hull() {
          translate([x*(axisSep+2),-2,2]) scale([1.5,1,9]) sphere(1,$fn=16);
          translate([x*29,platOff ,3]) scale([.5,1,4]) sphere(1,$fn=16);
        }
        hull() {
          translate([x*(axisSep-1),0 ,0.3]) scale([4,1,1.5]) sphere(1,$fn=16);
          translate([x*26,platOff,0.3]) scale([3,1,1.5]) sphere(1,$fn=16);
        }
      }

      // upper platform tabs
      for(x=[-tabSepUpper,0,tabSepUpper]) translate([x,5-1,tabZ])
         rotate([-90,0,0]) rotate([0,0,-30]) tab(PCBhole);

      // lower platform tabs
      for(x=[-tabSepLower,0,tabSepLower]) translate([x,platOff+0.3,tabZ])
         rotate([90,0,0]) rotate([0,0,30]) tab(PCBhole);
    }
}
