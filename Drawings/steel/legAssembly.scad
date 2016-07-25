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

//r38 = (3/8)*2.54/2;  // radius of 3/8" bolt

a=360*$t;
legAssembly(a,0);
mirror([1,0,0]) legAssembly(180-a,1.4);

//  -------------------------- crank-arm circle reference
%color([1,.5,.3,.4]) translate([0,Ay,-2]) difference() {
  cylinder(r=AC,h=1,$fn=48,center=true);
  cylinder(r=2,h=2,center=true);
}
color([0.3,.3,1,.7]) // axles
for(x=[-1,1]) translate([x*Bx,0,0]) difference() {  
   cylinder(r=2.54/2,h=20,$fn=24,center=true);
   cylinder(r=2.54/2-.4,h=22,$fn=19,center=true);
}

%translate([0,-93,0]) cube([200,2,2],center=true); // ground

// -----------------------------------------------------------------

// plot a link shadow, a different way, to check kinematic correctness
module checkLink(xa,ya,xb,yb,ab) {
  *translate([(xa+xb)/2,(ya+yb)/2,-9])
    rotate([0,0,atan2(yb-ya,xb-xa)]) cube([ab,1,1],center=true);
}

function triK1(ax,ay,ca,bx,by,cb) = (cb*cb - ca*ca + ax*ax -bx*bx +ay*ay -by*by)/(2*(ax-bx));

// ===================================================================
 
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

//------------------------------------------------------- CrankLinks
translate([xC,yC,linkOffset-.6]) rotate([0,0,atan2(yD-yC,xD-xC)])
  mirror([0,0,(linkOffset>0)?1:0]) crankLink(CD);
checkLink(xC,yC,xD,yD,CD);

translate([xC,yC,linkOffset+2.2]) rotate([0,0,atan2(yH-yC,xH-xC)])
  mirror([0,0,(linkOffset>0)?1:0]) crankLink(CH);
checkLink(xC,yC,xH,yH,CH);

translate([xF,yF,0]) rotate([0,0,atan2(yE-yF,xE-xF)]) EFlink();
checkLink(xE,yE,xF,yF,EF);

footRot = atan2(yH-yF,xH-xF)-atan2(FGperp,FGleft);
translate([xF,yF,0]) rotate([0,0,footRot])
   foot();
checkLink(xF,yF,xH,yH,FH);

} // end module legAssembly()

// include includes whole text.
// use just imports modules
use <util.scad>

// -----------------------------------------------------------------

module foot() {
  hull() {  // FG
    translate([4,0,.2]) cube([4,2.5,2.5],center=true);
    translate([FG-1.3,0,.2]) cylinder(r=1.3,h=2.6,$fn=24,center=true);
  }

  // knee braces/fork
  for (z=[-1.3,7]) rotate([0,0,(z>0)?25*0:0]) difference() {
    hull() {
      // This was elongated as a brace for knee
      //translate([-5,2,1.5*z])scale([3,5,1])cylinder(r=1,h=.4,$fn=64,center=true);
      // wider knee shouldn't need brace
      translate([0,0,z]) cylinder(r=2.5,h=.4,$fn=24,center=true);
      translate([9,0,z])cylinder(r=1,h=.4,center=true);
    }
    cylinder(r=.4,h=22,$fn=17,center=true);
  }


  // hinge holders at H
  %color([0,0,.6,.4])
  translate([FGleft,FGperp,-1]) difference() {
    cylinder(r=2.54/2,h=7,$fn=36);

    cylinder(r=1.9/2,h=22,center=true,$fn=24);
    translate([0,0,3.9])cube([3,3,2.8],center=true);
  }
  translate([FGleft,FGperp,-.87]) {
    rotate([180,0,0]) F698();
    translate([0,0,5.3]) rotate([180,0,0]) F698();
    translate([0,0,2.24]) F698();
    translate([0,0,6.74]) F698();
  }

  // vertical brace extension at knee
  translate([3.5,0,4.1]) cube([2.6,2.6,5.3],center=true);
  hull() {  // gusset
    translate([ 5.5,-1,1]) cylinder(r=.2,h=5.8,$fn=8);
    translate([18, 1,0]) cylinder(r=.3,h=1  ,$fn=8);
  }

  // FH segment bracing
  for (z=[-.3,5.1]) hull() {
    translate([   3    ,   1    ,z]) sphere(.8);
    translate([FGleft-1,FGperp-1,z]) sphere(.8);
  }
  hull() {  // dig brace.  Could be gusset?
      translate([3,1,5.7]) sphere(.8);
      translate([12,11,-.3]) sphere(.8);
  }
  translate([FGleft-2,FGperp-2,.3]) cylinder(r=.8,h=5,$fn=11);
  hull() {
      translate([FGleft-7.2,FGperp-8,5.3]) sphere(.8);
      translate([14,13.5,-.3]) sphere(.8);
  }

  // GH braces
  hull() {
      translate([FG-8,0,-.3]) sphere(.8);
      translate([FGleft+1,FGperp-1,-.3]) sphere(.8);
  }
  hull() {
      translate([FG-10,0,0]) sphere(.8);
      translate([FGleft+1,FGperp-1,5.2]) sphere(.8);
  }

  hull() {    // perp brace
      translate([FGleft,FGperp-1,5.2]) sphere(.8);
      translate([FGleft,0,0]) sphere(.8);
  }
  hull() {    // perp brace
      translate([FGleft,FGperp-1,-.3]) sphere(.8);
      translate([FGleft,0,-.3]) sphere(.8);
  }

  // extra truss braces
  hull() {
      translate([46,15,3]) sphere(.8);
      translate([35, 0,0]) sphere(.8);
  }
  translate([FGleft+2,FGperp-2,.3]) cylinder(r=.6,h=5);
  translate([FGleft,FGperp-2,.3]) cylinder(r=.6,h=5);
}

$fn=12;
module hip() {
  translate([DE/2,0,-.2]) cube([DE-5,2.5,2.5],center=true); // top tube
  translate([DE-DEleft,-DEperp,-1.2]) difference() {
     cylinder(r=2.54*1.5/2,h=7.2,$fn=36); // axle
     cylinder(r=2.54*1.5/2-.3,h=22,$fn=18,center=true);
  }

  // top tube fork plates
  translate([DE,0,0]) mirror([1,0,0]) eFork();
                                      eFork();


  hull() {  // diag tubes
    translate([DE-DEleft,-DEperp,0]) sphere(.8);
    translate([8,0,0]) sphere(.8);
  }
  hull() {
    translate([DE-DEleft,-DEperp,0]) sphere(.8);
    translate([DE-8,0,0]) sphere(.8);
  }

  // extra bracing
  translate([DE/2,-20,0]) rotate([0,90,0]) cylinder(r=.8,h=20,center=true);
  translate([DE-DEleft,-DEperp,5]) rotate([-110,0,0]) cylinder(r=.8,h=14.4);
}

module eFork() for(z=[-1,1]) difference() { 
  hull() {
    translate([0,0,1.4*z]) cylinder(r=2,h=.3,$fn=24,center=true);
    translate([6,0,1.4*z]) cube([1,2,.3],center=true);
  }
  cylinder(r=.4,h=11,$fn=17,center=true);
}

module crankLink(dx=CD) {
  %color([0,0,.6,.4]) difference() {
    cylinder(r=2.54/2,h=1,$fn=36,center=true);
    cylinder(r=2.54/2-.17,h=2,$fn=24,center=true);
  }
  translate([0,0, .36]) F698(); //cylinder(r=1.4,h=.7,$fn=24,center=true);
  translate([0,0,-.36]) rotate([180,0,0]) F698();

  //translate([dx/2-1,0,0]) cube([dx-3,1.3,1.3],center=true);
  %color([0,.8,0,.6])
  translate([dx/2-1,0,0]) rotate([0,90,0])
     cylinder(r=.6,h=dx-3,$fn=11,center=true);

  translate([dx,0,0]) SA8();
}


module EFlink() {
  translate([EF,0,0]) SA8();
  translate([EF/2-.4,0,0]) rotate([0,90,0])
      cylinder(r=.8,h=EF-3,$fn=13,center=true);

    // ------ tube and knee bearings
    %color([0,0,.6,.4])
    translate([0,0,-.84]) difference() {
       cylinder(r=2.54/2,h=2.54*3-.25,$fn=36);
       cylinder(r=2.54/2-.3,h=22,$fn=36,center=true);
    }
    translate([0,0,6.41]) F698();
    translate([0,0,-.7]) rotate([180,0,0]) F698();

    hull() {  // gusset
      translate([1.3,0,2*2.54/2]) cylinder(r=.2,h=2.54*3,$fn=12,center=true);
      translate([9,0,   0    ]) cylinder(r=.2,h=1,$fn=12); 
    }

  //translate([EF,0,0]) cylinder(r=r38,h=5,center=true);
    //                //cylinder(r=r38,h=55,center=true);
  //cylinder(r=1.2,h=22,$fn=36,center=true);
}


// this link drawn with B axle at origin, always.
module BHlinks() {
  difference() {  // main axle rings
    translate([0,0,2.4]) cylinder(r=2.54*1.5/2,h=13.5,$fn=36,center=true);
    translate([0,0,2.4]) cube([5,5,7.9],center=true);
    cylinder(r=2.54*1.5/2-.3,h=22,$fn=19,center=true);
  }

  // brace near axle
  translate([3,0,2.2]) cylinder(r=.8,h=10,$fn=19,center=true);
  // fork brace 
  translate([BH-7,0,2.43]) cube([2.5,2.5,7.6],center=true);

  for(z=[-2.4,7.2]) {
     hull() {
       translate([BH-6,0,z]) sphere(.8);
       translate([   0,0,z]) sphere(.8);
     }
  }

  hull() {
    translate([   4,.7,-1.6]) sphere(.8);
    translate([BH-9,.7, 6.2]) sphere(.8);    
  }
  hull() {
    translate([   4,-.7, 6.2]) sphere(.8);
    translate([BH-9,-.7,-1.6]) sphere(.8);    
  }

  // H forks
  for(z=[-1.7,6.2]) translate([BH,0,z]) difference() {
     hull() {
       cylinder(r=3,h=.33,$fn=36);
       translate([-8,0,0]) cylinder(r=1,h=.33);
     }
     cylinder(r=.7,h=2,center=true);
  }

  // to check dimensions
  //%translate([BH/2,0,2.4]) cube([BH,1,7.8],center=true);
}
module BHlinks1() {
  translate([0,0, 6.8])                 BHlink();
  translate([0,0,-2  ]) mirror([0,0,1]) BHlink();
}
module BHlink() {
  cylinder(r=1.4,h=6,$fn=24);

  //%translate([BH/2-1,0,1.3]) cube([BH-2,2.5,2.5],center=true);
  for (q=[-1,1]) hull() {
    translate([  0 ,1.5*q,1]) sphere(0.8);
    translate([BH-3,1  *q,1]) sphere(0.8);
  }
  hull() {
    translate([  0 ,0,5]) sphere(0.8);
    translate([BH-3,0,1]) sphere(0.8);
  }

  translate([BH,0,-.3]) difference() {
     hull() {
       cylinder(r=3,h=.33,$fn=36);
       translate([-8,0,0]) cylinder(r=1,h=.33);
     }
     cylinder(r=.7,h=2,center=true);
  }
}
