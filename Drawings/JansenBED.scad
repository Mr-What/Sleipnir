// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/JansenBED.scad $
// $Id: JansenBED.scad 435 2015-03-02 15:21:04Z mrwhat $

// main BED code, more injection-mold-like model

// Uses a ton of stuff from Jansen.scad.
// Use from an #include in  Jansen.scad.

forkLen = 3.5*LinkRad;  // forks around linkage in BED
nf=24;  // faces for hull components

module BEDhull(dLeft,dPerp,dRight,ph,rp) { hull() {
translate([-dLeft,-1,    0]) cylinder(h=1,r1=1,r2=.1,$fn=nf);
translate([dRight,-1,    0]) cylinder(h=1,r1=1,r2=.1,$fn=nf);
translate([ rp,dPerp+1,0]) cylinder(h=1,r1=1,r2=.1,$fn=nf);
translate([-rp,dPerp+1,0]) cylinder(h=1,r1=1,r2=.1,$fn=nf);
translate([ 0,dPerp-rp,ph-1]) sphere(r=1,$fn=nf);
translate([4-dLeft ,1,2]) sphere(r=1,$fn=nf);
translate([dRight-4,1,2]) sphere(r=1,$fn=nf);
}}

module BEDsideRail(x,dPerp,ph) {
hull() {
   translate([x,-1,  0]) {
     cylinder(h=1,r1=1.2,r2=.1,$fn=nf);
     translate([0,0,2]) sphere(r=.6,$fn=nf); }
   translate([0,dPerp+2,0]) {
     cylinder(h=1,r1=1.5,r2=.1,$fn=nf);
     translate([0,0,ph-.6]) sphere(r=.6,$fn=nf); }
   }
hull() {
   if (x < 0) { translate([x+2,0,0]) cylinder(h=2,r1=2.5,r2=2,$fn=nf); }
   else       { translate([x-2,0,0]) cylinder(h=2,r1=2.5,r2=2,$fn=nf); }
   translate([0,dPerp,0]) cylinder(h=2,r1=2.5,r2=2,$fn=nf);
   }
}

module BEDrails(dLeft,dPerp,dRight,ph,rp) {
union() {
   BEDsideRail(-dLeft,dPerp,ph);
   BEDsideRail(dRight,dPerp,ph);
   hull() { // vert bar part, DE
     translate([-dLeft,-1,0]) { cylinder(h=1,r1=1.5,r2=.1,$fn=6);
     translate([0,0,3]) sphere(r=.6,$fn=nf); }
     translate([dRight,-1,0]) { cylinder(h=1,r1=1.5,r2=.1,$fn=6);
     translate([0,0,3]) sphere(r=.6,$fn=nf); }
   }
   hull() { // horiz, flat part of DE segment
     translate([-dLeft+2,0,0]) cylinder(h=2,r1=2.5,r2=2,$fn=6);
     translate([dRight-2,0,0]) cylinder(h=2,r1=2.5,r2=2,$fn=6);
   }
   hull() { 
     translate([dRight-5,6,0]) cylinder(h=2,r1=1.5,r2=1,$fn=6);
     translate([dRight+1,2,0]) cylinder(h=2,r1=1.5,r2=1,$fn=6);
   }
}}

module forkTab(h,r1,r2,len) {
difference(){
hull() { cylinder(h=h,r1=r1,r2=r2,$fn=48);
  translate([len+2,0,0]) cylinder(h=2,r1=2,r2=1,$fn=12); }
translate([len,0,-.1]) cylinder(h=3*NodeHeight,r=.6,$fn=6);
    drillHole(rad4);
}}

module imBEDmain(dLeft,dBase,dPerp) { //------------------------------------ BED
perpHeight = NodeHeight3; //3*TrueNodeHeight;  // same height as long hinge-pin
difference() { union() {
  difference() { union() {
     BEDhull(dLeft*.8,dPerp,.75*(dBase-dLeft),perpHeight,Brad);

     translate([-dLeft,0,0]) {
        rotate([0,0,5]) hull() { 
           translate([0,0,NodeHeight+0.3]) forkTab(ForkHeight,Drad+2,rad4+1.4,forkLen);
           translate([NodeHeight, 0 , 0 ]) forkTab(    2     ,Drad+2,rad4+1.4,forkLen); }

        translate([dBase,0,0]) rotate([0,0,-5]) difference() {
           hull() { translate([-5*Drad,0,1.5]) sphere(r=1.5,$fn=12);
               cylinder(h=NodeHeight,r1=Drad+2, r2=Drad+1.8, $fn=48); }
           // hollow out hull a but...  injction mold style
           translate([0,0,-1.5]) { difference() { hull() {
               translate([-4*Drad+3,0,0]) cylinder(h=NodeHeight-1,r1=.4,r2=.2,$fn=6);
               cylinder(h=NodeHeight,r1=Drad-.1 ,r2=Drad-.4,$fn=24); }
               cylinder(h=NodeHeight,r1=Drad+1.7,r2=Drad+1.9,$fn=24); }}
       }

     } // end translate
   } // union
   
   translate([0,2,-1])
      BEDhull(dLeft*.8-3,dPerp-3,.75*(dBase-dLeft)-3,perpHeight-2,Drad-1);
   } // inner diff

   translate([0,dPerp,0])
      cylinder(h=perpHeight,r1=Brad+2.4,r2=Brad+1.8,$fn=48);
   }   // end second union

   //------------- main holes/knock outs
   translate([0,dPerp,0])drillHole(BradFree); // a little larger to move freely
   translate([(dBase-dLeft),0,0]) drillHole(Drad);

   // for Maxi version, drill hole in top half of "fork" node,
   // and knock out slot for in-plane CD linkage
   translate([-dLeft,0,0]) {

      translate([0,0,-.1]) {
         difference() { cube([28,33,2*(NodeHeight+.3)],center=true);
            hull() {
              translate([Drad+7,1,0]) cylinder(h=NodeHeight+.31,r=3,$fn=16);
              translate([Drad+14,2,0]) cylinder(h=NodeHeight+3,r=5,$fn=6);
              translate([Drad+14,10,0]) cylinder(h=NodeHeight+3,r=5,$fn=6);
            }
         }
      }
      drillHole(rad4);

      // drill hole to help allign fork linkage, must match linkage length below
      rotate([0,0,5]) translate([forkLen,0,0]) cylinder(h=3*NodeHeight,r=.6,$fn=6);
   }

  // diagnostic slice to examine walls
  //translate([0,-2,-2]) cube([4,44,33]);
}

// add other side of fork
//translate([-dLeft+0.7*forkLen,1.2*forkLen,0]) rotate([0,0,40])
//    forkTab(ForkHeight,Drad+2,rad4+1.4,forkLen);
}
//------------------------------------- end of imBEDmain

module BED1main(dLeft,dBase,dPerp) { //------------------------------------ BED
perpHeight = NodeHeight3; //3*TrueNodeHeight;  // same height as long hinge-pin
difference() { union() {
  difference() { union() {
     BEDrails(dLeft*.8,dPerp,.75*(dBase-dLeft),perpHeight,Brad);

     translate([-dLeft,0,0]) {
        rotate([0,0,5]) hull() { 
           translate([0,0,NodeHeight+0.3]) forkTab(ForkHeight,Drad+2,rad4+1.4,forkLen-2);
           translate([NodeHeight, 0 , 0 ]) forkTab(    2     ,Drad+2,rad4+1.4,forkLen-2); }

        translate([dBase,0,0]) rotate([0,0,-5]) difference() {
           hull() { translate([-4*Drad,0,1.5]) sphere(r=1.5,$fn=12);
               cylinder(h=NodeHeight,r1=Drad+2, r2=Drad+1.8, $fn=48); }
           // hollow out hull a but...  injction mold style
           translate([0,0,-1.5]) { difference() { hull() {
               translate([-4*Drad+3,0,0]) cylinder(h=NodeHeight-1,r1=.4,r2=.2,$fn=6);
               cylinder(h=NodeHeight,r1=Drad-.1 ,r2=Drad-.4,$fn=24); }
               cylinder(h=NodeHeight,r1=Drad+1.7,r2=Drad+1.9,$fn=24); }}
       }

     } // end translate
   } // union
   
   //translate([0,2,-1])
   //   BEDhull(dLeft*.8-3,dPerp-3,.75*(dBase-dLeft)-3,perpHeight-2,Drad-1);
   } // inner diff

   translate([0,dPerp,0])
      cylinder(h=perpHeight,r1=Brad+2.4,r2=Brad+1.8,$fn=48);
   }   // end second union

   //------------- main holes/knock outs
   translate([0,dPerp,0])drillHole(BradFree); // a little larger to move freely
   translate([(dBase-dLeft),0,0]) drillHole(Drad);

   // for Maxi version, drill hole in top half of "fork" node,
   // and knock out slot for in-plane CD linkage
   translate([-dLeft,0,0]) {

      translate([0,0,-.1]) {
         difference() { cube([28,33,2*(NodeHeight+.3)],center=true);
            hull() {
              translate([Drad+7,1,0]) cylinder(h=NodeHeight+.31,r=3,$fn=16);
              translate([Drad+14,2,0]) cylinder(h=NodeHeight+3,r=5,$fn=6);
              translate([Drad+14,10,0]) cylinder(h=NodeHeight+3,r=5,$fn=6);
            }
         }
      }
      drillHole(rad4);

      // drill hole to help allign fork linkage, must match linkage length below
      rotate([0,0,5]) translate([forkLen,0,0]) cylinder(h=3*NodeHeight,r=.6,$fn=6);
   }

  // diagnostic slice to examine walls
  //translate([0,-2,-2]) cube([4,44,33]);
}

// custom support
sW=0.41;  // support width
sH=4.4;  // support height
sH2=sH/2;
color("Cyan") union() {
  translate([-28,1,sH2]) rotate([0,0,10]) cube([sW,8,sH],center=true);
  translate([-29.5,0,sH2]) rotate([0,0,5]) cube([sW,9,sH],center=true);
  translate([-31,0,sH2]) rotate([0,0,5]) cube([sW,9,sH],center=true);
  translate([-32.5,0,sH2]) rotate([0,0,5]) cube([sW,10,sH],center=true);
  translate([-34,0,sH2]) rotate([0,0,5]) cube([sW,10,sH],center=true);
  translate([-35.5,0,sH2]) rotate([0,0,5]) cube([sW,10,sH],center=true);
  translate([-37,0,sH2]) rotate([0,0,5]) cube([sW,9,sH],center=true);
  translate([-36.5,-2.5,sH2]) rotate([0,0,40]) cube([sW,7,sH],center=true);
  translate([-36.5,2.5,sH2]) rotate([0,0,-40]) cube([sW,7,sH],center=true);
  translate([-30,-2.5,sH2]) rotate([0,0,10]) cube([8,sW,sH],center=true);
  translate([-31,3.5,sH2]) rotate([0,0,-10]) cube([8,sW,sH],center=true);
  hull() {
    translate([-34,0,0]) cylinder(r1=2,r2=5,h=3.6,$fn=11);
    translate([-29,0.5,0]) rotate([0,0,15])
        scale([1,3,1]) cylinder(r1=.3,r2=1.5,h=3.6,$fn=6);
  }
}

}

//------------------------------------- end of BED1main

module imBED(dLeft,dBase,dPerp) { //------------------------------------ BED
imBEDmain(dLeft,dBase,dPerp);

// add other side of fork
translate([-dLeft+0.7*forkLen,1.2*forkLen,0]) rotate([0,0,40])
    forkTab(ForkHeight+.1,Drad+2,rad4+1.4,forkLen);
}

// Complete (Joined) version of BED, with in-place fork
module imBEDj(dLeft,dBase,dPerp) { //------------------------------------ BED
union() {
imBEDmain(dLeft,dBase,dPerp);

// add other side of fork, in place
translate([-dLeft,0,-.01]) { rotate([0,0,5]) { 
    rotate([180,0,0]) forkTab(ForkHeight+.2,Drad+2,rad4+1.4,forkLen);

#hull(){
  translate([forkLen  ,0,0])cylinder(h=NodeHeight-2,r=2.8,$fn=12);
  translate([forkLen+1.5,4,1.1])sphere(r=1,$fn=6);
  translate([forkLen+2,0,0])cylinder(h=NodeHeight-2,r=2.2,$fn=12);}
}}

}}

//imBED(DEleft,DE,DEperp);

// version of BED intended for one-sided injection mold
module BED1(dLeft,dBase,dPerp) { //------------------------------------ BED
BED1main(dLeft,dBase,dPerp);

// add other side of fork
translate([-dLeft+0.7*forkLen,1.2*forkLen,0]) rotate([0,0,40])
    forkTab(ForkHeight+.1,Drad+2,rad4+1.4,forkLen);
}

