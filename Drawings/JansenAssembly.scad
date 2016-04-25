// https://github.com/Mr-What/Sleipnir/blob/master/Drawings/Jansen.scad

// modules to include in Jansen.scad, for animating the complete assembly

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
