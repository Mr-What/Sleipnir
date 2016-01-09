// https://github.com/Mr-What/Sleipnir/blob/master/Drawings/Jansen.scad

// Define PART to one of the following values to generate model for desired part.
//       HipA, HipB, FootA, FootB, CH, CD, EF, BH, AC
//       mainPulley, mainBar, motorPulley, braceBar
//
// For a 2-leg (half-trotter) :  print (2) CH, CD ; (4) EF, BH ; (1) of the others
// For a production robot, glue a rectangular support/spacer between BH pairs for stiffness

// PART="motor" to show motor-mount assembly

// *** DEPRICATED
// Combined parts with pads, optimized for RepRap :
// Hip, Feet, crankLinks, EFs, BHs    : main, pulley, drivePulley as above (brace)
//
// standoffs also DEPRICATED
hingeStyle = "spacer"; //6standoff";  // spacer or standoff
// *****

PART="motor";
echo(str("PART=",PART));

HoleFuzz = 0.1;  // extra radius (mm) to add to holes to account for printer slop
dHoleFuzz = 0.2;  // extra radius (mm) to add to d-shaft holes.  Sometimes not the same as HoleFuzz since it is harder to clean D-shaft holes

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
include <JansenDefs.scad>
include <util.scad>  // some generic utiltiy modules

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//       define some standard part dimensions for re-use in groups, etc.
acH0 = NodeHeight-.2;
acH1 = acH0+1.5;
acOR = Arad+2.4;
acIR = rad4;
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
module linkBH(len)
  linkage1(len,2.5*NodeHeight,Brad+2.5,BradFree+.2,2.6,Hrad+1.6,rad4);

//else if (PART=="BEDa" ) {                 imBED(DEleft,DE,DEperp); }
//else if (PART=="BEDb" ) { mirror([1,0,0]) imBED(DEleft,DE,DEperp); }
if      (PART=="HipA" )                 BED(DEleft,DE,DEperp);
else if (PART=="HipB" ) mirror([1,0,0]) BED(DEleft,DE,DEperp);
else if (PART=="jHipA" ) imBEDj(DEleft,DE,DEperp);
else if (PART=="jHipB" ) mirror([1,0,0]) imBEDj(DEleft,DE,DEperp);
else if (PART=="FootA") bracedFoot(FGleft,FG,FGperp);
else if (PART=="FootB") mirror([1,0,0]) bracedFoot(FGleft,FG,FGperp);
else if (PART=="CH"   ) crankLink(CH,15,Hrad); // build 2
else if (PART=="CD"   ) crankLink(CD,15,Drad); // build 2
else if (PART=="EF"   ) monoBracedLinkage(EF); // build 4
else if (PART=="BH"   ) linkBH(BH);
else if (PART=="AC"   ) crankArmAC(); 
else if (PART=="mainPulley") mainPulley();
else if (PART=="motorPulley") motorPulley();
else if (PART=="mainBar")  mainBar(Bx,Ay);
else if (PART=="braceBar") brace(2*Bx,8,Brad+.1);
else if (PART=="motorMount") motorMount();
//else if (PART=="spacers") { union(){ spacers(NodeHeight/2,Bhole+3,Brad);
//   translate([0,-7.5*LinkRad*1.414+1,0]) spacers(NodeHeight/2,LinkRad,rad4); }}
else if (PART=="motor") motorMountDemo();
//else if (PART=="demo") { //show all unique parts
else demo();

//=============================================================================

use <pulley.scad>;
include <JansenMain.scad>
include <JansenFoot.scad>
include <linkage.scad>
include <crankLink.scad>
include <JansenBED.scad>

module mainPulley() {
ph=5;  // pulley thickness
sr=25.4 * 3/16/2 + 1.5*HoleFuzz;  // standoff countersink radius

  difference() {
    union() {
      pulley2(AC+4,ph,sr,0);  // make with radius for standoff
      translate([0,0,0.17])
        cylinder(r=sr+1,h=ph-0.7,$fn=12);  // fill back in for rod hole
    }

    cylinder(r=rad4,h=ph+4,$fn=17); // drill hole for central rod
    for (y=[-1,1]) translate([0,AC*y,-1])
      cylinder(r=2.4,h=ph,$fn=36);  // screw pass-through for crank arm

    //translate([0,0,-9]) cube([60,60,20]); // diagnostic cut-out
  }
}

//module motorPulley() pulley(10,4,1.5+dHoleFuzz,1+dHoleFuzz);
// let small pulley be polygon to give it some "teeth"
module motorPulley() pulley2(8,4,1.5+dHoleFuzz,1+dHoleFuzz,fn=12,fni=12);

use <motorMount.scad>
module motorMountDemo() {
po=8;  // main pulley offset
//difference() { union() {
  translate([0,-Ay,0]) mainBar(Bx,Ay);
  translate([0,-Ay,22.2]) rotate([0,180,0]) mainBar(Bx,Ay);
  translate([0,-Ay,3.85]) rotate([0,180,0]) motorMount();
  %translate([0,0,po]) mainPulley();
  #translate([0,0,po-12.7  ]) cylinder(r=25.4*3/16/2,h=25.4/2,$fn=18);
  #translate([0,0,po+6.6-.6]) cylinder(r=25.4*3/16/2,h=25.4/2,$fn=18);
  translate([0,-48.5,8]) motorPulley();
  translate([0,0,26.7]) rotate([0,0,90]) crankArmAC();
  translate([0,0,-4.9]) rotate([180,0,-90]) crankArmAC();
}
//translate([-Bx,-Ay,-10]) cube([2*Bx,50,50]);}}

module crankArmAC() {
  //echo("AC:",AC,acH0,acOR,acIR,acH1,acOR,acIR); 
  crankArm(AC,acH0,acOR,acIR,acH1,acOR,acIR); 
}

// demo display of (most of) the linkage parts
module demo() {
   mainBar(Bx,Ay);
   %translate([0,Ay,20]) mainPulley();
   translate([0,-50,0])  motorPulley();
   translate([ 50, 30,0]) BED(DEleft,DE,DEperp);//imBED(DEleft,DE,DEperp);
   translate([-26, 44,0]) rotate([0,0,180]) bracedFoot(FGleft,FG,FGperp);
   translate([-12,-16,0]) crankLink(CD,15,Drad);
   translate([-36,-28,0]) crankLink(CH,15,Hrad);
   translate([-73,-15,0]) monoBracedLinkage(EF);
   translate([-60, 15,0]) crankArmAC(); 
   translate([ 25, 15,0]) linkBH(BH);
   translate([40,-42,0]) rotate([0,0,50]) brace(2*Bx,8,Brad);
   translate([-36,-35,0]) motorMount();
}

//=====================================================
//use <spacers.scad>;
