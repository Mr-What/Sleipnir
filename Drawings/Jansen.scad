// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/Jansen.scad $
// $Id: Jansen.scad 427 2014-08-23 20:42:39Z mrwhat $

// Define PART to one of the following values to generate model for desired part.
//       HipA, HipB, FootA, FootB, CH, CD, EF, BH, AC, pulley, mainBar, drivePulley
// For a 2-leg (half-trotter) :  print (2) CH, CD ; (4) EF, BH ; (1) of the others
// For a production robot, glue a rectangular support/spacer between BH pairs for stiffness
//
// Combined parts with pads, optimized for RepRap :
// Hip, Feet, crankLinks, EFs, BHs    : main, pulley, drivePulley as above (brace)
PART="FootA";
hingeStyle = "spacer"; //6standoff";  // spacer or standoff
echo(str("PART=",PART));

HoleFuzz = 0.2;  // extra radius (mm) to add to holes to account for printer slop

// measured diameter of '3/16"' spacer was 4.74 to 4.76, not 4.7625 as expected.
// Current design:  3/16" axles at B
//                  3/16" long 1/4"  OD standoffs at D, E, F
//                  1/2"  long 3/16" OD standoffs at H, A, C
Bdiam = 4.7625;  // larger brass tube rdiameter, measured on 3/16" tube
Adiam = 4.76;
Hdiam = Adiam;
//Ddiam = 6.35;  // 1/4" OD standoffs
Ddiam = Adiam;  // 3/16" OD standoffs/spacers
diam4 = 2.76;  // diameter of #4-40 screw, OD of thread


// on spacer tests:
//    Brad +.125 mm was snug, but not quite free rotating
//         +.05     turned, but not freely
//         -.025    still turned,  was very close
//    Arad +.125    turned free (good for main, crankLinks)
//         +.05     was press-to-fit (good for crankArm)
//    rad4 + 0.2    allowed a screw to go through snugly but freely
//         +.125    only threaded through
//  1/4"OD + 0.2    was a snug fit, no turn.  almost press-to-fit
//         + 0.275  snug, free turn... good for hinges on standoff

Brad = Bdiam/2 + HoleFuzz/2;    // 4.76mm diam brass tube -- critical fit
Arad = Adiam/2 + HoleFuzz/2.3;  // 3.18mm diam brass tube -- critical fit
rad4 = diam4/2 + HoleFuzz;  // good for screw pass-through
Hrad = Hdiam/2 + HoleFuzz*1.35;  // standoff holes for freely-moving hinges
Drad = Ddiam/2 + HoleFuzz;
AradFree = Adiam/2 + .25;  // loose fit on spindle

BradTight = Brad-0.05;
BradFree  = Brad+0.05;

Frad = 7;  // radius of beefed-up "knee"

LinkRad=3;
BarHeight=3;
//NodeHeight=5.8;  // gives a little room for 6.35 mm (.25 inch) standoffs
layer1bias=0.4;  // shift up for 1 layer of brim/raft

// 9/16" spacer height 14.37mm, not 14.287 as expected
// 3/16" spacer height  4.79mm, not 4.7625 as expected (*3=14.37)
// 1/4" Al standoffs were pretty close, and 3x was 19.02mm high, not 19.05 as expected, pretty close
//TrueNodeHeight = (hingeStyle == "spacer") ? 4.79-.2 : 6.35;
TrueNodeHeight = 4.79-.2;
NodeHeight = TrueNodeHeight - 0.3;  // a little room for hinges
//NodeHeight3 = 25.4*((hingeStyle == "spacer") ? 9/16 : 3/4) - 0.3;
// moving to slightly thinner 1/2" standoffs at H
NodeHeight3 = 25.4/2 - 0.3;

// Forks should be 1 node thick for standoffs...  short screws go into variable length standoff.
// they should be 2 nodes thick for spacers, extra long so that ALL hinges are 5 nodes wide.
//ForkHeight = (hingeStyle == "spacer") ? 2*NodeHeight : NodeHeight;
ForkHeight = NodeHeight;

// definitions of linkage lengths: AC;Ay;Bx;BH;EF;CD;CH;BD;BE;DE;FG;FH;GH
// derived quantities: DEleft;FGleft;DEperp;FGperp
include <JansenDefs.scad>;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//       define some standard part dimensions for re-use in groups, etc.
acH0 = NodeHeight;
acH1 = acH0+2;
acOR = Arad+3;
acIR = rad4;
pulleyR = 17;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

module nodeCyl(nodeHeight,nodeRad)
{ cylinder(h=nodeHeight,r1=nodeRad+.3,r2=nodeRad-.3,$fn=64); }  // set to 20+ for production quality

module drillHole(holeRad) { translate([0,0,-.03])
   cylinder(h=22,r=holeRad,$fn=80); } // set to 80 for production run

module footpad(r) { // pad to help a part stick to plate for 3D printer
   color("Cyan") cylinder(h=layer1bias,r1=r,r2=r-.3,$fn=11); }

// place a point, usually inside a linkage bar, to use in a hull
// with a part connected to a linkage bar
module barAnchor(dx) {
   translate([dx,0,0]) cylinder(h=BarHeight,r1=.8,r2=.6,$fn=6);
}

use <pulley.scad>;

include <JansenMain.scad>
include <JansenFoot.scad>

module monoBracedLinkage(len) {
lro = Drad+1.8;  // outisde link radius
difference() { union() { //------------------------ EF
    difference() { hull() {  // main bar
      translate([ 0 ,0,0])   nodeCyl(BarHeight,Frad);
      translate([len,0,0])   nodeCyl(BarHeight,lro*.5);
      }
      hull() { translate([0,0,-1.5]) { nodeCyl(BarHeight,Frad-1.5);
               translate([len,0 ,0])   nodeCyl(BarHeight,1); }}
    }

    // non-braced (BED side) reinforcement 
    translate(  [len,0,0]) { nodeCyl(BarHeight,lro);
       hull() { translate([0,0,BarHeight-1])
          cylinder(h=ForkHeight-BarHeight+1,r1=lro-.8,r2=rad4+1.2,$fn=64);
          cylinder(h=NodeHeight-1,r1=lro+.1,r2=rad4+1.2,$fn=16);
          //barAnchor(-1.5*lro);
          translate([-2*lro,0,2]) sphere(r=.4,$fn=12);
       }
    }
    hull() { translate([1.3*Frad,0,1.5]) scale([1,1,1]) sphere(r=1,$fn=16);
        translate([0,0,BarHeight-1])
          cylinder(h=ForkHeight-BarHeight+1,r1=Frad-.6,r2=rad4+1.6,$fn=64); }
    cylinder(h=BarHeight-1,r1=rad4+2.2,r2=rad4+3.3,$fn=32);

    hull() { // out-of-plane ridge/brace
        translate([ 0 ,0,2.2]) scale([1,1,2]) sphere(r=1,$fn=16);
        translate([len,0,2.2]) scale([1,1,2]) sphere(r=1,$fn=16); }
    }
    drillHole(rad4);
    translate([len,0,0]) drillHole(rad4);
}}

//------------------------------------------------------------ crankLink
// linkage with thin, wide connection for crank side, full node height on other
module crankLink(len,dFlat,rHole) {
// changing crank spindle to a 3/16 spacer instead of the 1/8" brass tube
radA = AradFree;  // free spinning on 3/16 OD standoff
echo(str("rHole=",rHole));
difference() { union() {
   hull() { cylinder(h=NodeHeight/2,r1=radA+3,r2=radA+2.8,$fn=48);
      translate([dFlat+4,0,0]) cylinder(h=NodeHeight/2,r1=1.2,r2=1,$fn=6); }
   translate([len,0,0]) { hull() {
      cylinder(h=NodeHeight,r1=rHole+2.2,r2=rHole+2,$fn=48);
         translate([-rHole-4,0,0]) cylinder(h=BarHeight,r1=1.2,r2=1,$fn=6); }}
   hull() {                  cylinder(h=NodeHeight/2,r1=LinkRad+.4,r2=LinkRad,$fn=6);
      translate([len/2,0,0]) cylinder(h=NodeHeight/2,r1=LinkRad+.4,r2=LinkRad,$fn=6); }
   hull() { translate([dFlat-2,0,0]) cylinder(h=BarHeight,r1=LinkRad+.4,r2=LinkRad-.2,$fn=6);
            translate([len-2  ,0,0]) cylinder(h=BarHeight,r1=LinkRad+.4,r2=LinkRad-.2,$fn=6); }
   hull() {
      translate([dFlat+2  ,0,BarHeight-1]) scale([1,1,1.5]) sphere(r=1,$fn=12);
      translate([len-rHole,0,BarHeight-1]) scale([1,1,1.5]) sphere(r=1,$fn=12);
      translate([len*0.65 ,0,BarHeight+.5]){scale([0.6,0.6,1.7]) sphere(r=1,$fn=12);
         translate([0,0,-2]) scale([2,2,1]) sphere(r=1,$fn=12);}
      translate([dFlat+15 ,0,BarHeight+.5]){scale([0.6,0.6,1.7]) sphere(r=1,$fn=12);
         translate([0,0,-2]) scale([2,2,1]) sphere(r=1,$fn=12);}
      }
   }
   drillHole(radA);  // a little extra to move freely
   translate([len,0,0]) drillHole(rHole);
}}

module linkage1(len,h0,r0,d0,h1,r1,d1) { difference() { union() {
   hull() { barAnchor(1.5*r0);
      cylinder(h=h0,r1=r0+.2,r2=r0-0.2,$fn=48); }
   translate([len,0,0]) { hull() { barAnchor(-1.5*r1);
      cylinder(h=h1,r1=r1,r2=0.4*r1+0.6*d1,$fn=48); }}
   hull() {                cylinder(h=BarHeight,r1=LinkRad+.2,r2=LinkRad-.2,$fn=6);
      translate([len,0,0]) cylinder(h=BarHeight,r1=LinkRad+.2,r2=LinkRad-.2,$fn=6); }
   hull() {                   cylinder(h=h0-0.5,r1=2,r2=.6,$fn=6);
      translate([len-d1,0,0]) cylinder(h=h1-0.5,r1=2,r2=.6,$fn=6); }
   }
   drillHole(d0);
   translate([len,0,0]) drillHole(d1);
}}

module linkage(len,h0,r0,d0,h1,r1,d1) { difference() { union() {
echo(str("linkage:",len,",",h0,",",r0,",",d0,",",h1,",",r1,",",d1));
   hull() { barAnchor(2.5*r0);
      cylinder(h=h0,r1=r0+.1,r2=r0-0.2,$fn=48); }
   translate([len,0,0]) { hull() { barAnchor(-2.5*r1);
      cylinder(h=h1,r1=r1+.1,r2=r1-.2,$fn=48); }}
   hull() {                cylinder(h=BarHeight,r1=LinkRad+.2,r2=LinkRad-.2,$fn=6);
      translate([len,0,0]) cylinder(h=BarHeight,r1=LinkRad+.2,r2=LinkRad-.2,$fn=6); }
   hull() {                   cylinder(h=h0-0.5,r1=2,r2=.6,$fn=6);
      translate([len-d1,0,0]) cylinder(h=h1-0.5,r1=2,r2=.6,$fn=6); }
   }
   drillHole(d0);
   translate([len,0,0]) drillHole(d1);
}}

// beefier version of a simple linkage, with same ends on both sides
module brace(len,h0,r0) {
r1=r0+1.7;
difference() { union() {
   difference() { hull() { cylinder(h=3,r1=r1+.1,r2=r1-.1,$fn=48);
      translate([len,0,0]) cylinder(h=3,r1=r1+.1,r2=r1-.1,$fn=48); }
      translate([1.5,0,-1.5]) hull() { cylinder(h=3,r1=r1-1.6,r2=r1-1.4,$fn=6);
             translate([len-1.5,0,0])  cylinder(h=3,r1=r1-1.6,r2=r1-1.4,$fn=6); }}

   translate([len,0,0])
   hull() { cylinder(h=h0,r1=r1+.2,r2=r1-.1,$fn=48);
      translate([-r1-4,0,2]) sphere(r=1,$fn=12); }
   hull() { cylinder(h=h0,r1=r1+.2,r2=r1-.1,$fn=48);
      translate([ r1+4,0,2]) sphere(r=1,$fn=12); }

   translate([0,0,h0/2]) hull() { scale([1,1,h0/2]) sphere(r=1,$fn=12);
            translate([len,0,0])  scale([1,1,h0/2]) sphere(r=1,$fn=12); }
   
   }
   drillHole(r0);
   translate([len,0,0]) drillHole(r0);
}}


module crankArm(len,h0,r0,d0,h1,r1,d1) { difference() {
  linkage(len,h0,r0,d0,h1,r1,d1);

  //// add little hole for "cotter-wire" on crank arm
  //translate([0,0,h0/2]) rotate(a=[90,0,0])
  //   cylinder(h=3*r0,r=.8,$fn=80,center=true);

  // for change to using standoffs as axle, counter sink axle screw
  translate([0,0,h0-1.5]) cylinder(h=2+.2,r1=rad4,r2=3.3,$fn=24);

  // try another countersink for spindle screw.
  translate([len,0,-1]) cylinder(h=2.2,r1=3.3,r2=rad4,$fn=24);
}}

include <JansenBED.scad>;

//============================================ Parts with brim/pads underneath

module BED_pad(left,base,perp) { union() { color("Cyan") hull() {
  translate([-left,0,0]) footpad(11);
  translate([base-left,0,0]) footpad(11);
  translate([0,perp,0]) footpad(13);}
  translate([0,0,.2]) imBED(left,base,perp);
}}
module bracedFoot_pad(left,base,perp) { union() { color("Cyan") hull() {
  translate([-left,0,0]) footpad(17);
  translate([0,perp,0]) footpad(11);
  translate([base-left,0,0]) footpad(13); }
  translate([0,0,.2]) bracedFoot(left,base,perp);
}}
module crankLink_pad(len,dFlat,rHole) { union() { color("Cyan") hull() {
   footpad(13);
   translate([len,0,0]) footpad(13); }
   translate([0,0,.2]) crankLink(len,dFlat,rHole);
}}
module monoBracedLinkage_pad(len) { union() { color("Cyan") hull() {
   footpad(15);
   translate([len,0,0]) footpad(13); }
   translate([0,0,.2]) monoBracedLinkage(len);
}}
module linkage_pad(len,h0,r0,d0,h1,r1,d1) { union() { color("Cyan") hull() {
   footpad(11);
   translate([len,0,0]) footpad(11); }
   translate([0,0,.2]) linkage(len,h0,r0,d0,h1,r1,d1);
}}
module brace_pad(len,h0,r0) { union() { color("Cyan") hull() { translate([len,0,0])
   footpad(r0+7);
   footpad(r0+7); }
   translate([0,0,.2]) brace(len,h0,r0);
}}
module linkage1_pad(len,h0,r0,d0,h1,r1,d1) { union() { color("Cyan") hull() {
   footpad(11);
   translate([len,0,0]) footpad(11); }
   translate([0,0,.2]) linkage1(len,h0,r0,d0,h1,r1,d1);
}}
module crankArm_pad(len,h0,r0,d0,h1,r1,d1) { union() { color("Cyan") hull() {
   footpad(11);
   translate([len,0,0]) footpad(11); }
   translate([0,0,.2]) crankArm(len,h0,r0,d0,h1,r1,d1);
}}
module mainBar_pad(x,y) { union() { color("Cyan") hull() {
  translate([-x,0,0]) footpad(12);
  translate([ x,0,0]) footpad(12);
  }
  translate([0,0,.2]) mainBar(x,y);
}}

//---------------------
module BED(dLeft,dBase,dPerp) { union() { rotate([0,0,50]) {
   translate([dBase*0.2,-3*Drad,0]) rotate([0,0,180]) mirror([1,0,0])
   BED_pad(dLeft,dBase,dPerp);
   BED_pad(dLeft,dBase,dPerp);
}}}
module feet(dLeft,dBase,dPerp) { union() { 
   translate([dBase*0.15,-0.5*dPerp,0]) rotate([0,0,190]) mirror([1,0,0])
   bracedFoot_pad(dLeft,dBase,dPerp);
   bracedFoot_pad(dLeft,dBase,dPerp);
}}
module crankLinks() {
spc=6;
union() {
   translate([0,spc*3.2,0]) 
     crankLink_pad(CH,15,Hrad);
     crankLink_pad(CH,15,Hrad);
   rotate([0,0,180]) { 
     translate([-CD-1.5*spc, spc*1.6,0]) crankLink_pad(CD,15,Drad);
     translate([-CD-1.5*spc,-spc*1.6,0]) crankLink_pad(CD,15,Drad); }

   // tight holes to glue to axle, not spin
   translate([5*spc,-3.2*spc,0])
     crankArm_pad(AC,acH0,acOR,acIR,acH1,acOR,acIR); 
}}
module EFs(len) {
spc=6;
union() {
  translate([len-spc, 1.9*spc,0]) rotate([0,0,180]) monoBracedLinkage_pad(len);
  translate([len-spc,-1.9*spc,0]) rotate([0,0,180]) monoBracedLinkage_pad(len);
  translate([0,-3.8*spc,0]) monoBracedLinkage_pad(len);
  monoBracedLinkage_pad(len);
}}
module BHs(len,h0,r0,d0,h1,r1,d1) {
spc = 2*Brad;
union() {
  translate([spc*1.1, 1.6*spc,0]) linkage1_pad(len,h0,r0,d0,h1,r1,d1);
  translate([spc*1.1,-1.6*spc,0]) linkage1_pad(len,h0,r0,d0,h1,r1,d1);
  translate([ 0     ,-3.2*spc,0]) linkage1_pad(len,h0,r0,d0,h1,r1,d1);
                                  linkage1_pad(len,h0,r0,d0,h1,r1,d1);
}}

//=====================================================
use <spacers.scad>;

if      (PART=="BED"  ) {                   BED(DEleft,DE,DEperp); }
//else if (PART=="BEDa" ) {                 imBED(DEleft,DE,DEperp); }
//else if (PART=="BEDb" ) { mirror([1,0,0]) imBED(DEleft,DE,DEperp); }
else if (PART=="HipA" ) {                 BED1(DEleft,DE,DEperp); }
else if (PART=="HipB" ) { mirror([1,0,0]) BED1(DEleft,DE,DEperp); }
else if (PART=="jHipA" ) { imBEDj(DEleft,DE,DEperp); }
else if (PART=="jHipB" ) { mirror([1,0,0]) imBEDj(DEleft,DE,DEperp); }
else if (PART=="Feet" )                         feet(FGleft,FG,FGperp);
else if (PART=="FootA") 
//difference() {
                  bracedFoot(FGleft,FG,FGperp);
  //  translate([0,0,18]) cube([200,200,20],center=true); }
else if (PART=="FootB") { mirror([1,0,0]) bracedFoot(FGleft,FG,FGperp); }
else if (PART=="crankLinks") crankLinks();
else if (PART=="CH"   ) crankLink(CH,15,Hrad); // build 2
else if (PART=="CD"   ) crankLink(CD,15,Drad); // build 2
else if (PART=="EF"   ) monoBracedLinkage(EF); // build 4
else if (PART=="EFs"  ) EFs(EF);
else if (PART=="BHs"  ) BHs(BH,2.5*NodeHeight,Brad+1.8,BradFree,ForkHeight,Hrad+2,rad4);
else if (PART=="BH"   ) linkage1(BH,2.5*NodeHeight,Brad+1.8,BradFree,ForkHeight,Hrad+2,rad4); // build 4, glue them together with a rectangle if desired
else if (PART=="AC"   ) crankArm(AC,acH0,acOR,acIR,acH1,acOR,acIR); 
else if (PART=="halfPulley") { union() { color("Cyan") footpad(pulleyR+7);
       translate([0,0,.2]) halfPulley(pulleyR,2.5,AradTight,-1); }}
else if (PART=="halfDrivePulley") { union() { color("Cyan") footpad(15);
       translate([0,0,.1]) halfPulley(8,2.5,1.5+.3,1+.3); }}
else if (PART=="pulley_pad") { union() { footpad(23); translate([0,0,.2])
                            pulley(18,5,rad4,0); }}
else if (PART=="pulley") {  pulley(18,5,rad4,0); }
else if (PART=="drivePulley_pad") { union() { footpad(15); translate([0,0,.2])
                                pulley(10,4,1.5+.3,1+.3); }}
else if (PART=="drivePulley") { pulley(10,4,1.5+.3,1+.3); }
else if (PART=="mainBar") {  mainBar(Bx,Ay); }
else if (PART=="main") { mainBar_pad(Bx,Ay); }
else if (PART=="braceBar") {  brace(2*Bx,8,Brad); }
else if (PART=="brace") { brace_pad(2*Bx,8,Brad); }
else if (PART=="spacers") { union(){ spacers(NodeHeight/2,Bhole+3,Brad);
   translate([0,-7.5*LinkRad*1.414+1,0]) spacers(NodeHeight/2,LinkRad,rad4); }}
//else if (PART=="demo") { //show all unique parts
else {
   mainBar(Bx,Ay);
   #translate([0,Ay,20]) pulley(18,5,rad4,0);
   translate([0,-50,0])  pulley(10,4,1.5+.3,1+.3);
   translate([ 50, 30,0]) BED1(DEleft,DE,DEperp);//imBED(DEleft,DE,DEperp);
   translate([-26, 44,0]) rotate([0,0,180]) bracedFoot(FGleft,FG,FGperp);
   translate([-12,-16,0]) crankLink(CD,15,Drad);
   translate([-36,-28,0]) crankLink(CH,15,Hrad);
   translate([-73,-15,0]) monoBracedLinkage(EF);
   translate([-60, 15,0]) crankArm(AC,acH0,acOR,acIR,acH1,acOR,acIR); 

   translate([ 25, 15,0]) linkage1(BH,2.5*NodeHeight,Brad+1.8,BradFree,ForkHeight,Hrad+2,rad4);
   translate([40,-42,0]) rotate([0,0,50]) brace(2*Bx,8,Brad);
}
