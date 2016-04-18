// try to draw Jansen linkage leg assembly as it might appear in steel

// these are for configuration "E" as referenced in other drawings
AC=17.5;
Ay =  3.318; Bx = 53.833;
BD = 48.020; BE = 46.977; BH = 40.359;
CD = 59.635; CH = 71.441; DE = 66.437;
EF = 47.467; FG = 75.792;
FH = 40.843; GH = 55.790;

DEleft = (DE*DE + BD*BD - BE*BE)/(2*DE);
FGleft = (FG*FG + FH*FH - GH*GH)/(2*FG);
DEperp = sqrt(BD*BD - DEleft*DEleft);
FGperp = sqrt(FH*FH - FGleft*FGleft);

echo(str("DEleft=",DEleft,"   DEperp=",DEperp));
echo(str("FGleft=",FGleft,"   FGperp=",FGperp));

//a=0;
//legAssembly(a,0);
//mirror([1,0,0]) legAssembly(180-a,1.2);
legAssembly(0);

function triK1(ax,ay,ca,bx,by,cb) = (cb*cb - ca*ca + ax*ax -bx*bx +ay*ay -by*by)/(2*(ax-bx));
 
module legAssembly(ang=0,linkOffset=0) {

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
/*
ke1=(yD*yD + xD*xD + DE*DE + BE*BE)/(2*yD);
ke2=(xD+Bx)/yD;
ae=2+ke2*ke2;
be=2*(Bx-ke1*ke2);
ce=ke1*ke1 - BE*BE +Bx*Bx;
echo("E abc:",ae,be,ce);
xE=(-be+sqrt(be*be-4*ae*ce))/(2*ae);
yE=sqrt(BE*BE - pow(xE+Bx,2));
*/
echo("E",xE,yE);

// this initial soln. seems wrong.
//xH=(BH*BH + xC*xC - CH*CH - Bx*Bx)/(2*(xC+Bx));
//yH=-sqrt(CH*CH - xC*xC + 2*xC*xH - xH*xH);
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

/*
k1f=(FH*FH - EF*EF - yE*yE - yH*yH + xE*xE - xH*xH) / (2*(yE-yH));
k2f=(xH-xE)/(yE-yH);
af=k2f*k2f+1;
bf=2*(k1f*k2f - xH - k2f*yH);
cf=xH*xH + yH*yH - 2*k1f*yH + k1f*k1f - FH*FH;
xF=(-bf-sqrt(bf*bf - 4*af*cf))/(2*af);
yF=k1f+k2f*xF;
*/
k2f = (yE-yH)/(xE-xH);
k1f = triK1(xE,yE,EF,xH,yH,FH);
af=k2f*k2f+1;
bf=2*(k2f*xE - k1f*k2f -yE);
cf=k1f*k1f - 2*k1f*xE + xE*xE + yE*yE - EF*EF;
yF=(-bf-sqrt(bf*bf - 4*af*cf))/(2*af);
xF=k1f-k2f*yF;
echo("F",xF,yF,"EF err",sqrt(pow(xF-xE,2)+pow(yF-yE,2))-EF);
echo("FH err",sqrt(pow(xF-xH,2)+pow(yF-yH,2))-FH);

//  -------------------------- crank-arm circle reference
%translate([0,Ay,0]) difference() {
  cylinder(r=AC,h=1,$fn=48,center=true);
  cylinder(r=2,h=2,center=true);
}

// draw the hip so that the main "plane", the ED centerline plane, is at z=0
translate([-Bx,0,0]) rotate([0,0,hipRot])
    translate([DEleft-DE,DEperp,0]) hip();
//translate([-Bx,0,2.5]) rotate([0,0,12.5]) translate([-DEleft,DEperp,0]) hip();
//translate([ Bx,0,0]) rotate([0,0,-20]) translate([DE-DEleft,DEperp,0]) mirror([1,0,0])
//  hip();
checkLink(-Bx,0,xD,yD,BD);
checkLink(-Bx,0,xE,yE,BE);
checkLink(xD,yD,xE,yE,DE);

translate([-Bx,0,0]) rotate([0,0,bhRot])
   BHlinks();
checkLink(-Bx,0,xH,yH,BH);

//translate([xC,yC,2]) rotate([0,0,142]) 
//   CDlink();
translate([0,0,linkOffset-.5]) CDlink(xC,yC,xD,yD);
checkLink(xC,yC,xD,yD,CD);

EFlink(xE,yE,xF,yF);
//EFlink();
checkLink(xE,yE,xF,yF,EF);

translate([0,0,linkOffset+1.8]) CDlink(xC,yC,xH,yH);
checkLink(xC,yC,xH,yH,CH);

footRot = atan2(yH-yF,xH-xF)-atan2(FGperp,FGleft);
translate([xF,yF,0]) rotate([0,0,footRot])
   foot();
checkLink(xF,yF,xH,yH,FH);

} // end module legAssembly()

// plot a link shadow, a different way, to check kinematic correctness
module checkLink(xa,ya,xb,yb,ab) {
  %translate([(xa+xb)/2,(ya+yb)/2,-9])
    rotate([0,0,atan2(yb-ya,xb-xa)]) cube([ab,1,1],center=true);
}

module foot() difference() {
  union() {
    hull() {
      cube([4,2.6,2.6],center=true);
      translate([FG-1.3,0,0]) cylinder(r=1.3,h=2.6,$fn=24,center=true);
    }
    translate([FGleft,FGperp-5,0]) cube([2.6,6,2.6],center=true);
    translate([FGleft,FGperp-5,4.8]) cube([2.6,6,2.6],center=true);
    translate([FGleft,FGperp-5,2.5]) cube([2.6,2.6,7],center=true);
    color([.3,.3,.4,.8]) {
      translate([FGleft,FGperp-.5, 0 ]) cube([3.5,5,2.2],center=true);
      translate([FGleft,FGperp-.5,4.8]) cube([3.5,5,2.2],center=true);
    }
    hull() {
      translate([6,0,0]) sphere(.8);
      translate([FGleft,FGperp-5,0]) sphere(.8);
    }
    hull() {
      translate([FG-6,0,0]) sphere(.8);
      translate([FGleft,FGperp-6,0]) sphere(.8);
    }
    hull() {
      translate([FGleft,FGperp-5,5]) sphere(.8);
      translate([FGleft,0,0]) sphere(.8);
    }
  }

  cylinder(r=.3,h=4,center=true);
  cube([4.4,3,2],center=true);
  translate([FGleft,FGperp,0]) cylinder(r=.7,h=33,center=true);
}
$fn=12;

module hip() {
  //color("Black") cube([3,3,2.5],center=true);
  difference() {
    translate([DE/2,0,0]) cube([DE+4,2.6,2.6],center=true);
    #cylinder(r=.5,h=4,center=true);
    cube([5,3,2],center=true);

    translate([DE,0,0]) {
      #cylinder(r=.25,h=8,center=true);
      cube([5,3,2],center=true);
    }
  }
  translate([DE-DEleft,-DEperp,-1.5]) cylinder(r=1.4,h=8,$fn=36);
  hull() {
    translate([DE-DEleft,-DEperp,0]) sphere(.8);
    translate([8,0,0]) sphere(.8);
  }
  hull() {
    translate([DE-DEleft,-DEperp,0]) sphere(.8);
    translate([DE-8,0,0]) sphere(.8);
  }
  translate([DE/2,-20,0]) rotate([0,90,0]) cylinder(r=.8,h=20,center=true);
  translate([DE-DEleft,-DEperp,4]) rotate([-105,0,0]) cylinder(r=.8,h=14);
}

module CDlink(cx=0,cy=0,dx=CD,dy=0) {
echo("CD",cx,cy,dx,dy);
  translate([dx,dy,0]) cylinder(r=1.4,h=.7,$fn=24,center=true);
  translate([cx,cy,0]) cylinder(r=1.4,h=.7,$fn=24,center=true);
  hull() {
    translate([dx,dy,0]) cylinder(r=.7,h=.7,$fn=24,center=true);
    translate([cx,cy,0]) cylinder(r=.7,h=.7,$fn=24,center=true);
  }
  //%translate([CD/2,0,0]) cube([CD-2,1.4,1.4],center=true);
}

module EFlink(ex=0,ey=0,fx=EF,fy=0) {
echo("EF",ex,ey,fx,fy);
  difference() {
     union() {
       color([.3,.3,.4,1]) {
         translate([ex,ey,0]) cube([4,3,3],center=true);
         translate([fx,fy,0]) cube([4,3,3],center=true);
       }
       hull() {
         translate([ex,ey,0]) cylinder(r=1.3,h=2.6,center=true);
         translate([fx,fy,0]) cylinder(r=1.3,h=2.6,center=true);
       }
     }

     translate([ex,ey,0]) cylinder(r=.7,h=3,center=true);
     translate([fx,fy,0]) cylinder(r=.7,h=3,center=true);
  }
}

// this link drawn with B axle at origin, always.
module BHlinks() {
  translate([0,0, 6.8])                 BHlink();
  translate([0,0,-2  ]) mirror([0,0,1]) BHlink();
}
module BHlink() {
  cylinder(r=1.4,h=6,$fn=24);
  translate([BH/2-1,0,1.3]) cube([BH-2,2.5,2.5],center=true);
  translate([BH,0,-.3]) difference() {
     hull() {
       cylinder(r=3,h=.33,$fn=36);
       translate([-8,0,0]) cylinder(r=1,h=.33);
     }
     cylinder(r=.7,h=2,center=true);
  }
}
