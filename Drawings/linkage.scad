
module monoBracedLinkage1(len) {
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

module monoBracedLinkage(len) {
lro = Drad+2;  // outisde link radius
difference() {
  union() { //------------------------ EF
    //difference() {
      hull() {  // main bar
        translate([0,0,0.3]) scale([Frad+.3,Frad+.3,1.8]) sphere(1,$fn=48);
        translate([len,0,0]) scale([2,rad4+1,2]) sphere(1,$fn=48);
      }
      *hull() { translate([0,0,-1.5]) { nodeCyl(BarHeight,Frad-1.5);
               translate([len,0 ,0])   nodeCyl(BarHeight,1); }}
    //}

    // non-braced (BED side) reinforcement 
    translate([len,0,0]) {
       hull() { translate([-3*lro,0,0]) sphere(.2);
         translate([0,0,.4]) scale([lro,lro,2]) sphere(1,$fn=36);
       }
       hull() { translate([-2*lro,0,2]) sphere(.2);
         cylinder(r1=rad4+2,r2=rad4+1.3,h=ForkHeight,$fn=36);
       }
    }

    *hull() { translate([1.3*Frad,0,1.5]) scale([1,1,1]) sphere(r=1,$fn=16);
        translate([0,0,BarHeight-1])
          cylinder(h=ForkHeight-BarHeight+1,r1=Frad-.6,r2=rad4+1.6,$fn=64); }
    hull() { translate([1.7*Frad,0,1.5]) sphere(.2);
        cylinder(h=ForkHeight,r1=0.8*Frad,r2=rad4+1.4,$fn=48);
    }

    *cylinder(h=BarHeight-1,r1=rad4+2.2,r2=rad4+3.3,$fn=32);

    // out-of-plane ridge/brace
    hull() for(x=[0,len]) translate([x,0,1]) scale([1,1,ForkHeight-1])
      sphere(r=1,$fn=16);
  }

  for(x=[0,len]) translate([x,0,0]) drillHole(rad4);
  translate([-20,-20,-20]) cube([len+40,40,20]);
}}

module linkage2(len,h0,r0,d0,h1,r1,d1) { difference() { union() {
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
module linkage1(len,h0,r0,d0,h1,r1,d1) difference() {
  union() {
    hull() { translate([2*r0,0,.4]) sphere(.2);
      intersection() { translate([0,0,h0/2]) cube([16,16,h0],center=true);
        translate([0,0,h0*.4]) scale([r0,r0,h0+1]) sphere(1,$fn=48);
      }
    }
    translate([len,0,0]) hull() { translate([-2.5*r1,0,.3]) sphere(.2);
      intersection() { translate([0,0,h1/2]) cube([16,16,h1],center=true);
        translate([0,0,.5]) scale([r1,r1,h1]) sphere(1,$fn=48);
      }
    }

    hull() {
      translate([ 0 ,0,.6]) scale([3,r0-.2,BarHeight- .6]) sphere(1,$fn=24);
      translate([len,0,.6]) scale([2,d1+1 ,BarHeight-1.6]) sphere(1,$fn=24);
    }

    hull() {
      translate([    d0  ,0,2]) scale([1,1,h0-2]) sphere(1,$fn=24);
      translate([len-d1,0,0]) scale([.5,.5,BarHeight-.3]) sphere(1);
    }
  }

  drillHole(d0);
  translate([len,0,0]) drillHole(d1);
  translate([-10,-10,-10]) cube([len+20,20,10]);
}

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

module brace1(len,h0,r0) {
r1=r0+1.7;
difference() {
  union() {
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

module brace(len,h0,r0) {
r1=r0+1.7;
difference() {
  union() {
    hull() for(x=[-1,1]) translate([x*len/2,0,0.8])
       scale([1,r0+2,1.8]) sphere(1,$fn=24);

    for(x=[-1,1]) translate([x*len/2,0,0]) hull() {
      intersection() {
        translate([0,0,h0/2-.1]) cube([2*r0+8,2*r0+8,h0+0.2],center=true);
        translate([0,0,1]) scale([r0+2,r0+2,h0+4]) sphere(1,$fn=36);
      }
      translate([-x*h0*1.5,0,0]) sphere(.2);
    }

     hull() for(x=[-1,1]) translate([x*len/2,0,0])
        scale([1,1,h0-.3]) sphere(1,$fn=24);
   }

   for(x=[-1,1]) translate([x*len/2,0,0]) drillHole(r0);

   translate([0,0,-5]) cube([len+20,20,10],center=true);
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

