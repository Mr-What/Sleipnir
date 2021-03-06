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
if(0) {

legAssembly(a,0);
mirror([1,0,0]) legAssembly(180-a,1.3);

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
%color([0,0,1,.2]) translate([0,0,-8])
   cube([114,1.75*2.54,1.75*2.54],center=true);

} else {
//jigFoot();
//jigHip();
//jigBH();
//jigCrankLink();
jigEF();
}

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

translate([xC,yC,linkOffset+2]) rotate([0,0,atan2(yH-yC,xH-xC)])
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
useF698=0;
thin=1;
withBrace=0;  // use wobble braces at knee as fork
HforkAngle=155;  // angle of SI8 fork at H

  // FG (shin)
    if (withBrace) {
      hull() {  // FG (shin)
        translate([4,0,.2]) cube([4,2.5,2.5],center=true);
        translate([FG-1.3,0,.2]) cylinder(r=1.3,h=2.6,$fn=24,center=true); // foot
      }
    } else {
      // knee end fork cut out of square tube
      difference() {
        hull() {
          cube([4,2.54,2.54],center=true);
          translate([FG-1.3,0,.2]) cylinder(r=1.3,h=2.54,$fn=24,center=true); // foot
        }

        #cylinder(r=.4,h=4,$fn=17,center=true);
        translate([-.5,.2,0]) cube([4,2.54,2.1],center=true);
      }
    }

  // knee braces/fork
  *%color([0,1,1,.2])
  for (z=[-1.3,thin?1.6:7]) rotate([0,0,(z>0)?25*0:0]) difference() {
    hull() {
      // This was elongated as a brace for thin knee
      translate([-5,2,z])scale([3,5,1])cylinder(r=1,h=.4,$fn=64,center=true);

      // wider knee shouldn't need brace
      //translate([0,0,z]) cylinder(r=2.5,h=.4,$fn=24,center=true);
      translate([9,0,z])cylinder(r=1,h=.4,center=true);
    }
    #cylinder(r=.4,h=thin?4:17,$fn=17,center=true);
  }


  // hinge holders at H
  if (useF698) {
    // F698 tubes for H-hinge fork
    %color([0,0,.6,.4])
    translate([FGleft,FGperp,-1]) difference() {
      cylinder(r=2.54/2,h=7,$fn=36);

      cylinder(r=1.9/2,h=22,center=true,$fn=24);
      translate([0,0,3.6])cube([3,3,2.8],center=true);
    }
    translate([FGleft,FGperp,-.87]) {
      rotate([180,0,0]) F698();
      translate([0,0,5.0]) rotate([180,0,0]) F698();
      translate([0,0,1.95]) F698();
      translate([0,0,6.75]) F698();
    }
  } else {
    // use SA8 Heim rod-ends for H fork
    // use some washers/spacers to get heim a few mm inside fork, to allow
    // room for connecting rod to clear fork
    for (z=[-.7+.3,5.6-.3]) translate([FGleft,FGperp,z])
      rotate([0,0,HforkAngle]) SI8onBolt(); //SA8();
  }

  if (thin==0) {
    // vertical brace extension at knee
    translate([3.5,0,4.1]) cube([2.5,2.5,5.3],center=true);
    hull() {  // gusset
      translate([ 5.5,-1,1]) cylinder(r=.2,h=5.8,$fn=8);
      translate([18, 1,0]) cylinder(r=.3,h=1  ,$fn=8);
    }
  }

  // FH segment bracing
  if (thin) {
    for(z=[0,1]) hull() {
      translate([FGleft+4,FGperp-3,z?-2.5:7]) barEnd1();
      translate([    3     ,   0    ,z?-1:1]) barEnd1();
    }

  } else {
    for (z=[-.3,5.1]) hull() {
      translate([   3    ,   1    ,z]) barEnd1();
      translate([FGleft-(useF698?1:-4),
                 FGperp-(useF698?1:4),z]) barEnd1();
    }

    hull() {  // dig brace.  Could be gusset?
       translate([3,1,5.7]) barEnd1();
       translate([useF698?12:13+2,11,-.3]) barEnd1();
    }

    hull() {
      translate([FGleft-(useF698?7.2:5-4),FGperp-8,5.3]) barEnd1();
      translate([useF698?14:15.5+2.6,13.5,-.3]) barEnd1();
    }
  }


  for (z=[0,1]) hull() {  // GH braces
    translate([FG-9,0,z?-1:1]) barEnd1();
    translate([FGleft+6,FGperp-1.5,z?-2:6.7]) barEnd1();
  }

  for (z=[0,1]) hull() {    // perp brace
     translate([FGleft+5.5,FGperp-3,z? 7:-2]) barEnd1();
     translate([FGleft+5.5,   0    ,z?.5:-1]) barEnd1();
  }

  // extra truss braces
  hull() {
      translate([47,16,4.2]) barEnd1();
      translate([35, 0,0]) barEnd1();
  }

  // out-of-plane perp braces
  if (useF698) {
    translate([FGleft+2,FGperp-2,.3]) cylinder(r=.6,h=5);
    translate([FGleft,FGperp-2,.3]) cylinder(r=.6,h=5);
    translate([FGleft-2,FGperp-2,.3]) cylinder(r=.8,h=5,$fn=11);
  } else {
    ////translate([FGleft+1,FGperp-2,.3]) cylinder(r=.6,h=5);
    ////translate([FGleft-1,FGperp-4,.3]) cylinder(r=.8,h=5,$fn=11);
    //translate([FGleft+4,FGperp-4,.3]) cylinder(r=.8,h=5,$fn=11);
    translate([FGleft,FGperp,2.4]) rotate([0,0,HforkAngle])
       translate([-4.8,0,0])
          cube([.75*2.54,.75*2.54,10],center=true);
  }
}

$fn=12;
module hip() {
squareTop=1;  // 1==let top tube be square, no additional fork pieces

  if (squareTop) {
    // crank link width with flange bearings is a little over 1"
    // so go with 1.25" square top tube
    *difference() {
      translate([DE/2,0,0])    // top tube
        cube([DE+4,1.25*2.54,1.25*2.54],center=true);

      translate([-1,-.3,0]) cube([5,3.2,2.8],center=true);
      #cylinder(r=.4,h=4,$fn=12,center=true);
      translate([DE,-.3,0]) cube([5,3.2,2.8],center=true);
      #translate([DE,0,0]) cylinder(r=.4,h=4,$fn=12,center=true);
    }

    // Even though , technically, the crank link hits the
    // edge with a 1" top tube, I think there is enough slop
    // with the heim joint to use a 1" top tube anyway.
    // also... if needed, we can shift the top tube
    // up or down 1/8" depending in which side we are, and make it work.
    // have slightly uneven spacers at F, and we are fine
    difference() {
      translate([DE/2,0,0])    // top tube
        cube([DE+4,2.54,2.54],center=true);

      translate([-1,-.3,0]) cube([5,2.6,2.2],center=true);
      #cylinder(r=.4,h=4,$fn=12,center=true);
      translate([DE,-.3,0]) cube([5,2.6,2.2],center=true);
      #translate([DE,0,0]) cylinder(r=.4,h=4,$fn=12,center=true);
    }

  } else {
    translate([DE/2,0,-.2]) rotate([0,90,0])      // top tube
      cylinder(r=.9,h=DE-4,$fn=17,center=true);
  }

  translate([DE-DEleft,-DEperp,-1.2]) difference() {
     union() {
       cylinder(r=2.54*1.75/2,h=7.2,$fn=36);                // axle

       hull() {  // diag tubes
         translate([-1.6,1.4,1.2]) barEnd1();
         translate([DEleft-DE+2,DEperp,1.2]) barEnd1();
       }
       hull() {
         translate([0,0,1.2]) barEnd1();
         translate([DE-DEleft-1,DEperp,1.2]) barEnd1();
       }

       // extra brace
       translate([0,0,6.2]) rotate([-105,0,0]) cylinder(r=.8,h=20);
     }

     // bore out for 6805 bearing
     cylinder(r=3.7/2+.1,h=22,$fn=18,center=true);
  }

  if (squareTop==0) {
  // use cut-out square tube (or channel) for forks, instead of all welded.
  // easier to drill and maintain aligned holes
  // 14ga roughly 2mm thick
  translate([DE,0,0]) rotate([0,0,180]) channelFork();
  channelFork();
  }

  // extra bracing
  translate([DE/2,-15,0]) rotate([0,90,0]) cylinder(r=.8,h=35,center=true);
}

// cut-out square tube (or channel) for forks
//     easier to drill and maintain aligned holes
module channelFork(od=2.54*1.24,gu=.2,len=3,hd=.82,co=.5)
translate([co,0,0]) difference() { 
  cube([od     ,len  ,od     ],center=true);
  cube([od-2*gu,len+1,od-2*gu],center=true);

  // open one side of square tube to make a channel
  translate([-od/2,0,0]) cube([2.1*gu,len+1,od-2*gu-.05],center=true);

  // put hole at x=0,y=0 in part space.
  #translate([-co,0,0]) cylinder(r=hd/2,h=od+1,$fn=17,center=true);
}

/*
module eFork() for(z=[-1,1]) difference() { 
  hull() {
    translate([0,0,1.4*z]) cylinder(r=2,h=.3,$fn=24,center=true);
    translate([6,0,1.4*z]) cube([1,2,.3],center=true);
  }
  cylinder(r=.4,h=11,$fn=17,center=true);
}
*/

module crankLink(dx=CD) {
  %color([0,0,.6,.4]) difference() {
    cylinder(r=2.54/2,h=.9,$fn=36,center=true);
    cylinder(r=2.54/2-.17,h=2,$fn=24,center=true);
  }
  translate([0,0, .31]) F698(); //cylinder(r=1.4,h=.7,$fn=24,center=true);
  translate([0,0,-.31]) rotate([180,0,0]) F698();

  //translate([dx/2-1,0,0]) cube([dx-3,1.3,1.3],center=true);
  %color([0,.8,0,.6])
  translate([dx/2-1-1,0,0]) rotate([0,90,0])
     cylinder(r=.6,h=dx-3-3,$fn=11,center=true);

  translate([dx,0,0]) SI8onBolt(); //SA8();
}


module EFlink() {
thin=1;

  translate([EF,0,0]) SI8onBolt(); //SA8();

  if (thin) {
    rotate([0,0,180]) SI8onBolt();

    // main tube
    translate([EF/2,0,0]) rotate([0,90,0])
      cylinder(r=.8,h=EF-9,$fn=13,center=true);

  } else {

    // main tube
    translate([EF/2-.4-1.5,0,0]) rotate([0,90,0])
      cylinder(r=.8,h=EF-3-3,$fn=13,center=true);

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
  }

  //translate([EF,0,0]) cylinder(r=r38,h=5,center=true);
    //                //cylinder(r=r38,h=55,center=true);
  //cylinder(r=1.2,h=22,$fn=36,center=true);
}


// this link drawn with B axle at origin, always.
module BHlinks() {

  // main bars for BH link.
  // may want to fabricate these first, then add the extra
  // bracing, in place, on a working (but wobbly?) leg
  translate([0,0,7.8]) rotate([180,0,0]) BHbar();
  translate([0,0,-3]) BHbar();

  // do these last, after leg assembly, improvised
  color([0,.5,1,.5]) {
    BHcrosses();

    // brace near axle
    translate([3.3,0,2.2]) cylinder(r=.8,h=10,$fn=19,center=true);
  }
}

module BHbar() {
  difference() {
    union() {
      cylinder(r=2.54*1.75/2,h=2.8,$fn=42,center=true);
      translate([BH/2+1,0,.14]) difference() {
        cube([BH+2,2.54,2.54],center=true);  // sq. tube
        cube([BH+3,2.2,2.2],center=true);

        // carve out for H bolt
        translate([BH/2,0,-1.4]) rotate([0,-30,0])
           cube([6,3,3],center=true);
      }

      // weld extra plate for strength at H node
      translate([BH,0,2.54/2+.3]) cube([3,3,.4],center=true);
    }

    cylinder(r=3.7/2+.1,h=3,$fn=19,center=true);
    #translate([BH,0,0]) cylinder(r=.4,h=7,$fn=13);
  }
}

// diag braces.  Try to leave fork area open to allow clearance for CH link
module BHcrosses() {
h1=BH-4;  // node closest to H
b1=4;
spread=.7;
lo=-1.6;
hi=6.5;
rBar=.8;
  hull() {
    translate([b1, spread,lo]) barEnd1();
    translate([h1, spread,hi]) barEnd1();    
  }
  hull() {
    translate([b1,-spread,hi]) barEnd1();
    translate([h1,-spread,lo]) barEnd1();    
  }
}

module barEnd1() sphere(.8,$fn=12);

module jigFoot() {
  %translate([0,0,2.54/2]) foot();

  color([.6,.6,.8,1]) {   // extrusions
    translate([-5,-1,-2]) cube([FG+10,4,2]);
    translate([FGleft-1,0,-2]) cube([4,FGperp+4,2]);
  }

  // peg to hold 1" tube segment for foot
  translate([FG-(2.54/2),0,0]) cylinder(r=1.9/2,h=8,$fn=32);

  cylinder(r=.4,h=8,$fn=16);  // alignment peg for F joint

  // hamstring alignment pin
  translate([FGleft,FGperp,0]) cylinder(r=.4,h=10,$fn=16);
}
module jigHip() {
  %translate([0,0,2.54/2]) hip();

  color([.6,.6,.8,1]) {   // extrusions
    translate([-5,-1,-2]) cube([DE+10,4,2]);
    translate([DE-DEleft-1,-DEperp-5,-2]) cube([4,DEperp+4,2]);
  }

  translate([DE,0,0]) cylinder(r=.4,h=8,$fn=16);  // D bolt hole alignment
  cylinder(r=.4,h=8,$fn=16);  // E bolt hole alignment

  // Axis bearing alignment.  Use actual bearings seated in tube
  translate([DE-DEleft,-DEperp,0]) {
     difference() { // peg with 5mm bolt hole to align bearings
       cylinder(r=2.5/2,h=10,$fn=36);
       cylinder(r=.5/2,h=11,$fn=16);
     }

     color([.3,.3,.8,.9]) for(z=[.4,6.9]) translate([0,0,z]) bb6805();  // bearings
  }
}
module jigBH() {
  %translate([0,0,2.54/2+.4]) rotate([180,0,0]) BHbar();

  color([.6,.6,.8,1]) {   // extrusions
    translate([-5,-1,-2]) cube([BH+10,4,2]);
  }

  translate([BH,0,0]) cylinder(r=.4,h=8,$fn=16);  // H bolt hole alignment

  // Axis bearing alignment.  Use actual bearings seated in tube
  difference() { // peg with 5mm bolt hole to align bearings
       cylinder(r=2.5/2,h=5,$fn=36);
       cylinder(r=.5/2 ,h=6,$fn=16);
  }
  color([.3,.3,.8,.9]) for(z=[.6,2.7]) translate([0,0,z]) bb6805();  // bearings
}
module jigCrankLink() {
  %translate([0,0,.65]) crankLink(CD);

  color([.6,.6,.8,1]) {   // extrusions
    translate([-5,-1,-2]) cube([CD+10,4,2]);
  }

  translate([CD,0,0]) cylinder(r=.4,h=8,$fn=16);  // heim joint alignment 
  cylinder(r=.4,h=8,$fn=16);  // pedal spindle proxy
}
module jigEF() {
  %translate([0,0,.7]) EFlink();

  color([.6,.6,.8,1]) {   // extrusions
    translate([-5,-1,-2]) cube([EF+10,4,2]);
  }

  translate([EF,0,0]) cylinder(r=.4,h=5,$fn=16);  // heim joint alignment 
  cylinder(r=.4,h=5,$fn=16);
}

