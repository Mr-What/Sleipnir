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

PART="assembly";
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
else if (PART=="assembly") assembly($t*360);
else demo();

//=============================================================================

use <pulley.scad>;
include <JansenMain.scad>
include <JansenFoot.scad>
include <linkage.scad>
include <crankLink.scad>
include <JansenBED.scad>

// Show whole assembly at given phase angle
module assembly(phase=0) {
  translate([0,Ay,-11]) mirror([0,0,1]) motorMountDemo(phase);
  legAssembly(phase);
  mirror([1,0,0]) legAssembly(180-phase,4.4);
  %translate([0,-93,0]) cube([200,2,2],center=true);
}

// plot a link shadow, a different way, to check kinematic correctness
module checkLink(xa,ya,xb,yb,ab) {
  *translate([(xa+xb)/2,(ya+yb)/2,-9])
    rotate([0,0,atan2(yb-ya,xb-xa)]) cube([ab,1,1],center=true);
}
function triK1(ax,ay,ca,bx,by,cb) = (cb*cb - ca*ca + ax*ax -bx*bx +ay*ay -by*by)/(2*(ax-bx));

module legAssembly(ang=0,linkOffset=0) {
echo("Phase",ang);

// solve kinematics for given crank angle
xC = AC*cos(ang);
yC = AC*sin(ang)+Ay;
echo("C",xC,yC);

k1=(yC*yC - Bx*Bx + BD*BD - CD*CD + xC*xC)/(2*yC);
k2=(xC+Bx)/yC;
c=k1*k1-BD*BD+Bx*Bx;
b=2*(Bx-k1*k2);
a=k2*k2+1;
sgnD=(yC<0)?1:-1;
xD=(-b+sgnD*sqrt(b*b-4*a*c))/(2*a);
yD=sqrt(BD*BD - pow(xD+Bx,2));
echo("D",xD,yD,"CD err",sqrt(pow(xC-xD,2)+pow(yC-yD,2))-CD);

hipRot = atan2(yD,Bx+xD)-atan2(DEperp,DEleft);
echo("hipRot",hipRot);
xE = cos(hipRot) * (DEleft-DE) - sin(hipRot) * DEperp - Bx;
yE = sin(hipRot) * (DEleft-DE) + cos(hipRot) * DEperp;
echo("E",xE,yE);

// this initial soln. seems wrong.
k1h=(xC*xC + yC*yC + BH*BH - CH*CH - Bx*Bx)/(2*yC);
k2h=-(xC+Bx)/yC;
ah=k2h*k2h+1;
bh=2*(k1h*k2h + Bx);
ch=k1h*k1h + Bx*Bx - BH*BH;
sgnH=(yC>0)?1:-1;
xH=(-bh+sgnH*sqrt(bh*bh-4*ah*ch))/(2*ah);
yH=-sqrt(BH*BH - pow(xH+Bx,2));
bhRot=atan2(yH,xH+Bx);
echo("H",xH,yH,"rot",bhRot,"CH err",sqrt(pow(xH-xC,2)+pow(yH-yC,2))-CH);

k2f = (yE-yH)/(xE-xH);
k1f = triK1(xE,yE,EF,xH,yH,FH);
af=k2f*k2f+1;
bf=2*(k2f*xE - k1f*k2f -yE);
cf=k1f*k1f - 2*k1f*xE + xE*xE + yE*yE - EF*EF;
yF=(-bf-sqrt(bf*bf - 4*af*cf))/(2*af);
xF=k1f-k2f*yF;
echo("F",xF,yF,"EF err",sqrt(pow(xF-xE,2)+pow(yF-yE,2))-EF);
echo("FH err",sqrt(pow(xF-xH,2)+pow(yF-yH,2))-FH);

//  -------------------------- 

// draw the hip so that the main "plane", the ED centerline plane, is at z=0
translate([-Bx,0,0])
  rotate([0,0,180+hipRot])
     translate([0,-DEperp,0]) BED(DEleft,DE,DEperp);
checkLink(-Bx,0,xD,yD,BD);
checkLink(-Bx,0,xE,yE,BE);
checkLink(xD,yD,xE,yE,DE);

translate([-Bx,0,0]) rotate([0,0,bhRot])
   BHlinks();
checkLink(-Bx,0,xH,yH,BH);

translate([xC,yC,linkOffset])
  rotate([0,0,atan2(yD-yC,xD-xC)])
    mirror([0,0,(linkOffset>0)?1:0]) crankLink(CD,15,Drad);
checkLink(xC,yC,xD,yD,CD);

translate([xC,yC,linkOffset+4.2])
  rotate([0,0,atan2(yH-yC,xH-xC)])
    mirror([0,0,(linkOffset>0)?1:0]) crankLink(CH,15,Hrad);
checkLink(xC,yC,xH,yH,CH);

translate([xF,yF,0])
  rotate([0,0,atan2(yE-yF,xE-xF)]) EFlinks();
checkLink(xE,yE,xF,yF,EF);

footRot = atan2(yH-yF,xH-xF)-atan2(FGperp,FGleft);
translate([xF,yF,0]) rotate([0,0,footRot])
   translate([FGleft,0,0]) bracedFoot(FGleft,FG,FGperp);
checkLink(xF,yF,xH,yH,FH);
} // end module legAssembly()
module EFlinks() {
//  translate([EF,0,5]) rotate([0,0,180])
  translate([0,0,4.5])                 monoBracedLinkage(EF);
  translate([0,0,-.2]) mirror([0,0,1]) monoBracedLinkage(EF);
}
module BHlinks() {
  translate([0,0,12.5]) linkBH(BH);
  translate([0,0,-.2]) mirror([0,0,1]) linkBH(BH);
}


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
module motorMountDemo(phase=90) {
po=8;  // main pulley offset
//difference() { union() {
  translate([0,-Ay,0]) mainBar(Bx,Ay);
  translate([0,-Ay,22.2]) rotate([0,180,0]) mainBar(Bx,Ay);
  translate([0,-Ay,3.85]) rotate([0,180,0]) motorMount();
  translate([0,0,po]) rotate([0,0,phase+90]) mainPulley();
  #translate([0,0,po-12.7  ]) cylinder(r=25.4*3/16/2,h=25.4/2,$fn=18);
  #translate([0,0,po+6.6-.6]) cylinder(r=25.4*3/16/2,h=25.4/2,$fn=18);
  translate([0,-48.5,8]) motorPulley();
  translate([0,0,26.7]) rotate([0,0,phase+180]) crankArmAC();
  translate([0,0,-4.9]) rotate([180,0,phase]) crankArmAC();
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
