// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/Klann.scad $
// $Id: Klann.scad 76 2013-05-18 16:47:22Z aaron $

//   Round Stock       diam(mm)
//=================    ========
// round toothpic         2.2
// Bamboo skewer          3.6      (max 3.8)
// smiths skewer             4             4.17 to 4.29, 3.96 to 4.1, 3.56 to 3.73
// smaller skewer         2.86     2.81-2.96
// even smaller skewer    2.24     2.2-2.28
// Wire Hanger            2.0      (max 2.1)
// Thin paperclip         0.77
// Thick paperclip        1.44

HoleRad=.75+.1;  // extra to compensate for extruded filament spill-over
LinkRad=3;
BarHeight=3;
NodeHeight=BarHeight+1;

LargeHole=1.4+.2;  // radius (mm)
XLargeHole=2;  // for larger diameter bamboo skewers from kroger

// Define PART to one of the following values to generate model for desired part.
// Simple, NON-BRACED version:
//    main,pulley,AC, rocker(2), BH(2), DE(2), leg(2)
//         just flip rocker, foot over for left vs. right one
PART="spacer";

/// Original, default linkage, reversed from patent:
//MainScale=67.829;  // scale crank from .268 to 17.5, for 10:1 scale for use with 175mm bicycle crankset
//
//B =  [-.599, -.176] * MainScale;
//D = B + [.366,.792] * MainScale;
//AC = .268 * MainScale;
//BH = .3204 * MainScale;
//CH = .59  * MainScale;
//CF = 1.1051 * MainScale;
//DE = .5176 * MainScale;
//EF = .89656 * MainScale;
//FG = .89654 * MainScale;
//EG = 1.732 * MainScale;
//FH = .52205 * MainScale;

/// Favorite optimization, 5/17/2013
MainScale=1;
AC=17.5*MainScale;
B =  [-38.8, -12.5] * MainScale;
D = [-14.6, 41.9] * MainScale;
BH = 23.7 * MainScale;
CH = 38.8  * MainScale;
CF = 73.4 * MainScale;
DE = 34.1 * MainScale;
EF = 57.7 * MainScale;
FG = 59 * MainScale;
EG = 111.7 * MainScale;
FH = 35.2 * MainScale;

CHproj = (CF*CF + CH*CH - FH*FH) / (2*CF);
Hperp = sqrt(CH*CH - CHproj*CHproj);  // for rocker bar
Hx = (EG*EG - EF*EF - FG*FG)/(2*FG);
Hip = [Hx,sqrt(EF*EF - Hx*Hx)];

module cyl(nodeHeight,nodeRad,nFace)
{ cylinder(h=nodeHeight,r=nodeRad,$fn=nFace); }

module hole(holeHeight,holeRad,nFace)
{ translate([0,0,-.1]) cyl(holeHeight+.2,holeRad,nFace); }

module linkage(length,h1,h2) {
r1=(h1>LinkRad-2)?h1+2:LinkRad;
r2=(h2>LinkRad-2)?h2+2:LinkRad;
echo("linkage ",length," r1=",r1," r2=",r2);
difference() { union() {
   translate([0,-LinkRad,0]) cube([length,2*LinkRad,BarHeight]);
   cyl(NodeHeight,r1,48);
   translate([length,0,0]) cyl(NodeHeight,r2,48);
   }
   hole(NodeHeight,h1,80);
   translate([length,0,0]) hole(NodeHeight,h2,80);
}}

module rockerBar(dLeft,dPerp,dRight,holeLeft,holePerp,holeRight) {
rLeft=(holeLeft>LinkRad-2)?holeLeft+2:LinkRad;
rPerp=(holePerp>LinkRad-2)?holePerp+2:LinkRad;
rRight=(holeRight>LinkRad-2)?holeRight+2:LinkRad;
difference() { union() {
  translate([-dLeft,0,0]) cyl(NodeHeight,rLeft,48);
  translate([0,dPerp,0]) cyl(NodeHeight,rPerp,48);
  translate([dRight,0,0])cyl(NodeHeight,rRight,48);
  hull(){
     translate([-dLeft,0,0]) cyl(NodeHeight,LinkRad,48);
     translate([0,dPerp,0]) cyl(NodeHeight,LinkRad,48);
     translate([dRight,0,0])cyl(NodeHeight,LinkRad,48); }
  }
  translate([-dLeft,0,0]) hole(NodeHeight,holeLeft,80);
  translate([0,dPerp,0]) hole(NodeHeight,holePerp,80);
  translate([dRight,0,0])hole(NodeHeight,holeRight,80);
}}

module leg(shin,hipLoc) {
//kneeThick = 0.3;
//kneeCap = [hipLoc[1]*kneeThick,-hipLoc[0]*kneeThick];
//kneeCap = [0,-hipLoc[1]*.5];
kneeCap = [0,-LinkRad*7];
hip0 = [hipLoc[0],hipLoc[1],0];
cap0 = [kneeCap[0],kneeCap[1],0];
difference() { union() {
   cyl(NodeHeight,2.5*LinkRad,24);
   hull() { translate([0,-3.5*LinkRad,0]) cyl(NodeHeight,LinkRad,48);
      translate([-shin,0,0]) cyl(NodeHeight,LinkRad,48);}
   hull() { cyl(NodeHeight,LinkRad,48);
      translate(hip0) cyl(NodeHeight,LinkRad,48);}
   hull() {
      translate([-shin,0,0]) cyl(NodeHeight,LinkRad,48);
      translate(cap0) cyl(NodeHeight,LinkRad,48); }
   hull() {
      translate(hip0) cyl(NodeHeight,LinkRad,48);
      translate(cap0) cyl(NodeHeight,LinkRad,48); }
   linear_extrude(height=BarHeight) polygon(points=[
         [-.8*shin,-LinkRad],kneeCap,hipLoc,[0,-1.1*LinkRad]], paths=[[0,1,2,3]]);
   }
   hole(NodeHeight,HoleRad,80);
   translate([hipLoc[0],hipLoc[1],0]) hole(NodeHeight,HoleRad,80);

   // optional bulk-reduction holes. they mostly just look neat.
   translate([-.4*LinkRad,-4.3*LinkRad,0]) hole(NodeHeight,1.2*LinkRad,64);
   translate([-4*LinkRad,-4*LinkRad,0]) hole(NodeHeight,.8*LinkRad,64);
   translate([-6.5*LinkRad,-3.5*LinkRad,0]) hole(NodeHeight,.6*LinkRad,64);
   translate([2.3*LinkRad,-2.2*LinkRad,0]) hole(NodeHeight,.8*LinkRad,64);
   translate([4*LinkRad,-.6*LinkRad,0]) hole(NodeHeight,.6*LinkRad,64);
   translate([5.5*LinkRad,.8*LinkRad,0]) hole(NodeHeight,.4*LinkRad,64);
}}



module pulley(pr,lip) {
//pr=Bx/3; // pulley radius, outside
//lip = 2;
nFaces=180;
hr=2.5; // hole rad
cr=pr*0.45;
tr=pr*0.7;
difference() { union() {
   cylinder(h=lip,r=pr,$fn=nFaces);
   cylinder(h=1.5*lip,r=pr-lip,$fn=nFaces);
   for (a=[90,210,330]) {
      translate([cos(a)*tr,sin(a)*tr,1.3*lip]) cylinder(h=lip,r=hr*0.3,$fn=80); }
   }
   translate([0,0,-1]) cylinder(h=1.5*lip+2,r=LargeHole,$fn=80);
   for (a=[0,60,120,180,240,300]) {
      translate([cos(a)*cr,sin(a)*cr,-1]) cylinder(h=1.5*lip+2,r=hr,$fn=80); }
   for (a=[30,150,270]) {
      translate([cos(a)*tr,sin(a)*tr,-1]) cylinder(h=1.5*lip+2,r=hr*0.5,$fn=80); }
}}


module mainKlann(pB,pD) {
thick=4;  // bar thickness
hr = LargeHole;  // hole radius
nr = hr * 2.5;  // node radius around hole
sep = 5;  // 1/2 seperation distance between main bars
lip=3;
fixedPoint = [[0,0,0],[pB[0],pB[1],0],[-pB[0],pB[1],0],[pD[0],pD[1],0],[-pD[0],pD[1],0]];
difference() { union() {
   for (i=[0:4]) { translate(fixedPoint[i]) cyl(thick+sep,nr,48); }
   hull() { for (i=[1:2]) { translate(fixedPoint[i]) cyl(thick,LinkRad,48); }}
   hull() { for (i=[1,3]) { translate(fixedPoint[i]) cyl(thick,LinkRad,48); }}
   hull() { for (i=[0,3]) { translate(fixedPoint[i]) cyl(thick,LinkRad,48); }}
   hull() { for (i=[2,4]) { translate(fixedPoint[i]) cyl(thick,LinkRad,48); }}
   hull() { for (i=[0,4]) { translate(fixedPoint[i]) cyl(thick,LinkRad,48); }}
   hull() { cyl(thick,LinkRad,48); translate([0,pB[1],0]) cyl(thick,LinkRad,48);}
   translate([pD[0],pD[1]+hr,0]) cube([-2*pD[0],nr-hr,thick+sep]);
   linear_extrude(height=2) polygon(points=[pB,[pD[0],pD[1]+nr-.1],
             [-pD[0],pD[1]+nr-.1],[-pB[0],pB[1]]],paths=[[0,1,2,3]]);
   translate([pB[0]+2.4*nr,pB[1]+nr,0]) cyl(thick+sep+lip,2*nr,6);
   translate([-pB[0]-2.4*nr,pB[1]+nr,0]) {cyl(thick+sep,2*nr,6); cyl(thick+sep+lip,2*nr-3,6); }

   // show pulley over main support for size comparison, diagnostic only
   //translate([0,0,15]) {assign(lenB=sqrt(pB[0]*pB[0]+pB[1]*pB[1])){pulley(0.8*(lenB-10*LargeHole),2);}}
   }
   translate([pB[0]+2.4*nr,pB[1]+nr,thick+sep-.75]) cyl(lip+2,2*nr-2,6);
   for (i=[0:4]) { translate(fixedPoint[i]) hole(thick+sep,hr,80); }
}}




//=====================================================

if      (PART=="AC") { linkage(AC,HoleRad, LargeHole); }
else if (PART=="BH") { linkage(BH,HoleRad,XLargeHole); }
else if (PART=="DE") { linkage(DE,HoleRad,XLargeHole); }
else if (PART=="rocker") { rockerBar(CHproj,Hperp,CF-CHproj,LargeHole,HoleRad,HoleRad); }
else if (PART=="leg") { leg(FG-LinkRad,Hip); }
else if (PART=="main") { mainKlann(B,D); }
else if (PART=="pulley") { assign(lenB=sqrt(B[0]*B[0]+B[1]*B[1])){pulley(0.8*(lenB-10*LargeHole),2);}}
else { difference() {cyl(BarHeight,LargeHole+2,64); hole(BarHeight,LargeHole,80); }} // spacer
