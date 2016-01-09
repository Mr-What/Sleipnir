// https://github.com/Mr-What/Sleipnir/blob/master/Drawings/JansenMain.scad

// for testing
//include <util.scad>
//mainBar(54,3.4);Brad=2.4;BradFree=Brad+.2;BradTight=Brad-.1;rad4=1.5;AradFree=BradFree;Arad=Brad;

lip=1.5;

// parameters for dovetails and main rail that need to match motor mount
tabX=15;
tabY=6.2;
module doveTail(fuzz=0) rotate([0,0,-30])
    cylinder(h=3+3*fuzz,r1=4+fuzz,r2=3+fuzz,$fn=3);

module mainBarBlade(dBx,radA,fuzz=0) {
  blade([-dBx,0,.4],radA+2.5+fuzz,3+fuzz,
        [ dBx,0,.4],radA+2.5+fuzz,3+fuzz,fn=64);

   // horizontal rib
   //for(x=[-1,1]) blade([x*dBx,0,4],1,4,  [0,0,2],1,3,fn=17);

  // add tab to help guide/mount small gearhead motor glue-on mount
  for (a=[-1,1]) translate([tabX*a,-tabY,0]) doveTail(fuzz);
}

module mainBar(dBx,dAy) { //------------------------------------------ main
echo("mainBar:",dBx,dAy);
//%mainBar1(dBx,dAy);
thick=4;  // bar thickness
barSep = 7.2;  // seperation between bars
//lip=1.5;
BradO = Brad + 2.5;
//echo(str("Outer diameter, B axle links : ",BradO));
tr = BradO/cos(30); // tab radius, for hex
radA = Arad+.2;//AradFree;  // Use 3/16"OD standoff for main axle
dConX = dBx-3*BradO;  // x offset to connector sockets
conZ = barSep+thick;  // main connector thickness
difference() {
  union() {

    // Main nodes
    for (a=[-1,1]) translate([dBx*a,0,0])
       linkNode(radA+2.8,thick+barSep-.2,ar=2.3,off=-.1,
          dx=-3*a*BradO,dz=thick+1);
    translate([0,dAy,0]) sphereSection(radA+2.6,thick+2.7,ar=1.7,off=-.1);
                             *linkNode(radA+2.6,thick+2.7,ar=1.7,off=-.1,
            dx=0,dy=-dAy-radA-2,dz=1.6);

    mainBarBlade(dBx,radA);   // main bar

    //support blades
    for(x=[-1,1]) {
      blade([x*(dConX-2),-radA-1,0],1,thick+1,  [2*x,dAy+radA,1],1.5,thick+1,fn=17);
      blade([x*(dConX-2), radA+1,0],1,thick+1,  [0,-2,-1],2,thick+3,fn=22);
      
    }

    // connection tabs
    translate([-dConX,0,1]) cylinder(r1=tr    ,r2=tr-.2 ,h=conZ+lip-1      ,$fn=6);
    translate([ dConX,0,1]) cylinder(r1=tr    ,r2=tr-.1 ,h=conZ-lip-1.5    ,$fn=6);
    translate([ dConX,0,2]) cylinder(r1=tr-1.3,r2=tr-2.4,h=conZ+2.5*lip-2.5,$fn=6);


   //% translate([0,dAy,thick+2.5]) halfPulley(pulleyR,3,Arad,-1);  // diagnostic to compare to bar
  }

  for(x=[-1,1]) translate([dBx*x,0,-.1])
      drillHole(BradTight+.1);  // a little less for press-to-fit

  translate([0,dAy, -.1]) drillHole(radA); // a little more for spinning axle
  translate([-dConX,0,0]) {
    cylinder(h=22,r=rad4,$fn=18,center=true);
    translate([0,0,6.5]) cylinder(r1=tr-2.4,r2=tr-1.4,h=conZ,$fn=6);
    translate([0,0,-1 ]) cylinder(r1=4,r2=3,h=5,$fn=6);  
  }
  translate([ dConX,0,-1]) {
     cylinder(h=33,r=.9,$fn=16); // pilot hole for plastic screw
     // { // hollow area just slows down 3D print, forget it
       //cylinder(h=thick+barSep-lip-2,r1=tr-2,r2=tr-2.5,$fn=6); // hallow out tab
       //cylinder(h=thick+barSep+2*lip-1.5,r1=2.5,r2=1.8,$fn=6);
     translate([0,0,3]) scale([3,3,8]) sphere(1,$fn=12);
  }

//translate([64,0,0]) cube([50,30,80],center=true);

// look at cross-section of tab to debug
//#translate([dBx-3*BradO,-10,-1]) cube([15,20,25]);
//translate([-dBx,0,-1]) cube([2*dBx,20,20]);
  translate([-dBx-20,-20,-20]) cube([2*dBx+40,40,20]);
}}







module mainBar1(dBx,dAy) { //------------------------------------------ main
echo("mainBar1:",dBx,dAy);
thick=4;  // bar thickness
barSep = 7.2;  // seperation between bars
lip=1.5;
BradO = Brad + 2.5;
radA = AradFree;  // Use 3/16"OD standoff for main axle
echo(str("Outer diameter, B axle links : ",BradO));
tr = BradO/cos(30); // tab radius, for hex
difference() { union() {

   // Main nodes
   for (a=[-1,1]) translate([dBx*a,0,0]) hull() { 
            translate([-2*a*BradO-a,0,3.5]) sphere(r=.1,$fn=6);
                nodeCyl(thick+barSep-.3,BradO); }
   hull() { translate([0,dAy,0]) nodeCyl(thick+2.5,radA+2.6);
            translate([0,-BradO+0.5,4.5]) sphere(r=.1,$fn=6); }

   // main bar
   difference() { hull() {
      for (a=[-1,1]) translate([dBx*a,0,0])
         cylinder(h=thick,r1=BradO+.5,r2=BradO,$fn=32);
      translate([0, dAy,0]) cylinder(h=thick,r1=2.5,r2=2);}
      // for 3D print, hollow understructure only slows print
      hull() {
         for (a=[-1,1]) translate([dBx*a,0,-1.5]) cylinder(h=thick,r1=BradO-1.5,r2=BradO-2,$fn=32);
         translate([0, dAy-2,-1.5]) cylinder(h=thick,r1=2.5,r2=2);}
   }
   // horizontal rib
   hull() for (a=[-1,1]) translate([dBx*a,0,3])
           scale([1,1,2.5]) sphere(r=1,$fn=22);

   /* don't need these on configuration D, which has very small dAy
   hull() { // triangular rib, supporting crank axis
      translate([-dBx*.8,0,4]) scale([1,1,2.5]) sphere(r=1,$fn=22);
      translate([0,    dAy,4]) scale([1,1,2.5]) sphere(r=1,$fn=22); }
   hull() {
      translate([dBx*.8,0,4])  scale([1,1,2.5]) sphere(r=1,$fn=22);
      translate([ 0 , dAy,4])  scale([1,1,2.5]) sphere(r=1,$fn=22); } */

   // connection tabs
   translate([-dBx+3*BradO,0,1]) cylinder(r1=tr-.2 ,r2=tr-.1 ,h=barSep+thick+lip-1  ,$fn=6);
   translate([ dBx-3*BradO,0,1]) cylinder(r1=tr-.2 ,r2=tr    ,h=barSep+thick-lip-1.5,$fn=6);
   translate([ dBx-3*BradO,0,2]) cylinder(r1=tr-1.4,r2=tr-2.6,h=barSep+thick+2.5*lip-2.5,$fn=6);

   // add tab to help guide/mount small gearhead motor glue-on mount
   for (a=[-1,1]) translate([tabX*a,-tabY,0]) doveTail();

   //% translate([0,dAy,thick+2.5]) halfPulley(pulleyR,3,Arad,-1);  // diagnostic to compare to bar
   }

   for(x=[-1,1]) translate([dBx*x,0,-.1])
      drillHole(BradTight+.1);  // a little less for press-to-fit

   translate([0,dAy, -.1]) drillHole(radA); // a little more for spinning axle
   translate([-dBx+3*BradO,0,3]) {
      cylinder(r1=tr-2.4,r2=tr-1.4,h=barSep+thick+lip+1,$fn=6);
      cylinder(h=22,r=rad4,$fn=18,center=true); }
   translate([ dBx-3*BradO,0,-1]) {
       #cylinder(h=333,r=.9,$fn=16); // pilot hole for plastic screw
       // hollow area just slows down 3D print, forget it
       //cylinder(h=thick+barSep-lip-2,r1=tr-2,r2=tr-2.5,$fn=6); // hallow out tab
       //cylinder(h=thick+barSep+2*lip-1.5,r1=2.5,r2=1.8,$fn=6);
   }
   // look at cross-section of tab to debug
   //#translate([dBx-3*BradO,-10,-1]) cube([15,20,25]);
}}
