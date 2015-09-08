// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/JansenMain.scad $
// $Id: JansenMain.scad 442 2015-09-08 02:14:35Z mrwhat $

module mainBar(dBx,dAy) { //------------------------------------------ main
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
                nodeCyl(thick+barSep-.5,BradO); }
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
   for (a=[-1,1]) translate([10*a,-BradO-1.3,0]) 
      rotate([0,0,-30]) cylinder(h=3,r1=4,r2=3,$fn=3);

   //% translate([0,dAy,thick+2.5]) halfPulley(pulleyR,3,Arad,-1);  // diagnostic to compare to bar
   }
   translate([-dBx,0,-.1]) drillHole(BradTight);  // a little less for press-to-fit
   translate([ dBx,0,-.1]) drillHole(BradTight);
   translate([0,dAy, -.1]) drillHole(radA); // a little more for spinning axle
   translate([-dBx+3*BradO,0,3]) {
      cylinder(r1=tr-2.4,r2=tr-1.4,h=barSep+thick+lip+1,$fn=6);
      cylinder(h=22,r=rad4,$fn=18,center=true); }
   translate([ dBx-3*BradO,0,-1]) {
       translate([0,0,15.5-8]) cylinder(h=33,r=.9,$fn=16); // pilot hole for plastic screw
       // hollow area just slows down 3D print, forget it
       cylinder(h=thick+barSep-lip-2,r1=tr-2,r2=tr-2.5,$fn=6); // hallow out tab
       cylinder(h=thick+barSep+2*lip-1.5,r1=2.5,r2=1.8,$fn=6); }
   // look at cross-section of tab to debug
   //#translate([dBx-3*BradO,-10,-1]) cube([15,20,25]);
}}

