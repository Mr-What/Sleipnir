// https://github.com/Mr-What/Sleipnir/blob/master/Drawings/JansenFoot.scad

// for testing:
//include <util.scad>
//bracedFoot(28.4,75.8,29.4);NodeHeight=4.3;Drad=2.4;Frad=7;Hrad=2.4;BarHeight=3;LinkRad=3;NodeHeight3=12.5;

padH = 0.3;  // extra clearance amount for H end of CH link

// main envelope (positive part) of braced foot
module bracedFootE(dLeft,dBase,dPerp,braceHeight,dRight,dLeft1) union() {

  translate([-dLeft,0,0]) linkNode(Frad+.2,NodeHeight,ar=1,off=0,dx=3*Frad);

  // hamstring node
  translate([0,dPerp,0]) {
    linkNode(Hrad+2.2,braceHeight,ar=3.3,off=-.1,dx=.35*dRight,dy=-.35*dPerp);
    linkNode(Hrad+2.2,braceHeight,ar=3.3,off=-.1,dx=-.25*dRight,dy=-.4*dPerp);
    translate([0,-2,1.5*NodeHeight]) scale([1,1,1]) sphere(Hrad+3,$fn=36);
  }

  translate([dBase-dLeft-LinkRad,0,0]) // foot
       cylinder(h=NodeHeight+.5,r=LinkRad,$fn=80);

  // lower diagonal link
  blade([3,dPerp-1 ,0],1,braceHeight,  // vert
        [dRight-2,0,1],1,2.5, fn=17);
  blade([0,dPerp ,0.4],4,2.2,            // horiz
        [dRight,0,0.4],2.6,1.8);

  // upper diag link
  blade([-dLeft1-2,-Frad*0.6,1],1,2,    // vert
        [-2,dPerp-2,0],1.5,braceHeight,fn=17);
  blade([-dLeft1+2,0,0.4],2.6,1.5,   // horiz
        [0,dPerp    ,0.4],4  ,2.2);

  // main leg vertical support
  blade([0,0,0],1.5,8,  [-dLeft+1.8*Frad, 0.6*Frad,1],1,3,fn=17);
  blade([0,0,0],1.5,8,  [-dLeft+0.7*Frad,-0.7*Frad,0],1,3,fn=17);
  blade([0,0,0],1.5,8,  [dBase-dLeft-3          ,0,1],1,3,fn=17);

  // main, long-leg segment
  blade([-dLeft,0,0.4],Frad,2.4,  [dBase-LinkRad-dLeft,0,0.4],2.4,1.6);

  hull(){   // stop to keep "knee" from hyper-extending
    translate([-dLeft-Frad+3,0,0.6]) sphere(3,$fn=16);
    translate([-dLeft,-Frad+3,0.6]) sphere(3,$fn=16);
    translate([-dLeft-Frad+2,-Frad-3,1]) sphere(3,$fn=16);
  }
  translate([-dLeft-Frad+2,-Frad-3,0])
     sphereSection(3,2*NodeHeight,ar=3.2,off=-.2);
}



module bracedFoot(dLeft,dBase,dPerp) {
echo("bracedFoot:",dLeft,dBase,dPerp);
//%bracedFoot14(dLeft,dBase,dPerp);

braceHeight = NodeHeight3; // 3*TrueNodeHeight-.4;  // A little shorter than the hinge-pin
dRight = 0.65 * (dBase-dLeft);  // scoot brace in a bit from foot
dLeft1 = dLeft-Frad-1-((0.5*Frad)/(dLeft-Frad-1));

  difference() {
    bracedFootE(dLeft,dBase,dPerp,braceHeight,dRight,dLeft1);

    translate([0,dPerp,0])  drillHole(Hrad);
    translate([-dLeft,0,0]) drillHole(Drad);

    // had trouble with fill around braced link.  See if adding little hollows
    // helps slicer to fill better
    #translate([-dLeft,0,NodeHeight/2]) for(a=[0:30:355]) 
       translate([0.5*(Frad+Drad)*cos(a),0.5*(Frad+Drad)*sin(a),0])
          cylinder(h=NodeHeight-1.4,r=.4,$fn=6,center=true);


    // knock out a slot to take the CH linkage.
    translate([0,dPerp,NodeHeight-padH]) {
      cylinder(h=NodeHeight+2*padH,r=Hrad+3,$fn=48);
      hull() {
         translate([ 0,-4,0]) cube([.1,.1,NodeHeight+2*padH]);
         translate([ 7,-1,0]) cube([2,5,NodeHeight+2*padH]);
         translate([-7,-2,0]) cube([1,5,NodeHeight+2*padH]);
      }
    }

    //cube([3,11,11]);   // diagnostic slice to examine pyramid shell
    translate([-dLeft-20,-20,-30]) cube([dBase+40,dPerp+30,30]);
  }


  color("Cyan") supportH(dPerp); // custom support at H node
}

module supportH(dPerp) union() {
  translate([0,29,NodeHeight-padH*.9]) difference() {
    cylinder(r2=4.4,r1=3.73,h=NodeHeight-.5,$fn=8);
    translate([0,0,-.1]) cylinder(r2=2.6,r1=3.4,h=5,$fn=8);
  }

  translate([0,dPerp,NodeHeight+2+padH]) {
    Hblade(4);
    rotate([0,0, 20]) Hblade();
    rotate([0,0, 50]) Hblade();
    rotate([0,0, 80]) Hblade();
    rotate([0,0,110]) Hblade();
    rotate([0,0,140]) Hblade();
    rotate([0,0,170]) Hblade();
    rotate([0,0,200]) Hblade(3.6);
    rotate([0,0,230]) Hblade(3.3);
    rotate([0,0,250]) Hblade(3.3);
    rotate([0,0,270]) Hblade(3.3);
    rotate([0,0,290]) Hblade(3.3);
    rotate([0,0,310]) Hblade(3.3);
    rotate([0,0,330]) Hblade(3.3);
    rotate([0,0,345]) Hblade(4.5);
  }
}






module bracedFoot14(dLeft,dBase,dPerp) { // ---------------- foot with out-of-axis support
echo("bracedFoot:",dLeft,dBase,dPerp);
braceHeight = NodeHeight3; // 3*TrueNodeHeight-.4;  // A little shorter than the hinge-pin
dRight = 0.65 * (dBase-dLeft);  // scoot brace in a bit from foot
dLeft1 = dLeft-Frad-1-((0.5*Frad)/(dLeft-Frad-1));
union() { difference() { union() {
   translate([-dLeft,0,0]) {
      cylinder(h=NodeHeight,r1=Frad+.2,r2=Frad-.2,$fn=48); }
   hull() {
      translate([0,dPerp,0]) cylinder(h=braceHeight,r1=Hrad+2,r2=Hrad+1.6,$fn=48);
      translate([0,dPerp-3,0]) cylinder(h=braceHeight-1,r1=Hrad+1,r2=Hrad+0.5,$fn=32);
      translate([.22*dRight,.8*dPerp,1.1]) sphere(r=1,$fn=6); }
   hull() {
      translate([0,dPerp,0]) cylinder(h=braceHeight,r1=Hrad+1.9,r2=Hrad+1.4,$fn=48);
      translate([0,dPerp-3,0]) cylinder(h=braceHeight-1,r1=Hrad+1,r2=Hrad+0.5,$fn=32);
      translate([-.28*dLeft1,(1-.23)*dPerp,2]) sphere(r=1,$fn=6); }

   // foot
   translate([dBase-dLeft-LinkRad,0,0]) cylinder(h=NodeHeight+.5,r=LinkRad,$fn=80);

   hull() {
      translate([0,dPerp ,0]) cylinder(h=braceHeight  ,r1=1.6,r2=1,$fn=6);
      translate([dRight,0,0]) cylinder(h=BarHeight+0.8,r1=1.6,r2=1,$fn=6); }
   hull() {
      translate([0,dPerp ,0]) cylinder(h=BarHeight,r1=LinkRad,r2=LinkRad-.5,$fn=6);
      translate([dRight,0,0]) cylinder(h=BarHeight,r1=LinkRad,r2=LinkRad-.5,$fn=6); }
   hull() {
      translate([-dLeft1,-Frad*0.5,0])  cylinder(h=BarHeight+1.5,r1=1.6,r2=1,$fn=6);
      translate([0,dPerp,0])            cylinder(h=braceHeight  ,r1=1.6,r2=1,$fn=6); }
   hull() {
      translate([-dLeft1+((8*Frad)/(dLeft-Frad-1)),0,0])
                             cylinder(h=BarHeight,r1=LinkRad,r2=LinkRad-.5,$fn=6);
      translate([0,dPerp,0]) cylinder(h=BarHeight,r1=LinkRad,r2=LinkRad-.5,$fn=6); }
   hull() {     // re-inforcing pyramid over main, long leg
      translate([-dLeft+2*Frad,0,0]) cylinder(h=BarHeight,r1=Frad-1,r2=Frad-3,$fn=6);
      translate([dBase-dLeft-2*LinkRad,0,0]) cylinder(h=BarHeight,r1=LinkRad,r2=LinkRad-2,$fn=6);
      translate([0,0,1.5*NodeHeight-1]) sphere(r=1,$fn=16);   }

   difference() { hull() {   // main, long-leg segment
      translate([-dLeft,0,0]) {      nodeCyl(BarHeight,Frad-1);
      translate([dBase-LinkRad,0,0]) nodeCyl(BarHeight,LinkRad-1); }
     }
     translate([-dLeft,0,-1.5]) hull(){nodeCyl(BarHeight,Frad-2.4);
        translate([dBase-LinkRad-2,0,0])nodeCyl(BarHeight,.4);}
   }

   hull(){   // stop to keep "knee" from hyper-extending
      translate([-dLeft-Frad+2,0,0]) cylinder(h=BarHeight,r=2,$fn=8);
      translate([-dLeft,-Frad+2,0])  cylinder(h=BarHeight,r=2,$fn=8);
      translate([-dLeft-Frad+2,-Frad-3,0]) cylinder(h=BarHeight,r=2,$fn=12); }
   translate(   [-dLeft-Frad+2,-Frad-3,0]) cylinder(h=3*BarHeight,r1=3,r2=2,$fn=24);
   }
   translate([0,dPerp,0])  drillHole(Hrad);
   translate([-dLeft,0,0]) drillHole(Drad);

   // hollow out re-inforcing pyramid
   hull() { translate([-dLeft+2*Frad+2,0,-1.5]) cylinder(h=BarHeight,r1=Frad-2,r2=Frad-4,$fn=6);
      translate([dBase-dLeft-3*LinkRad,0,-1.5]) cylinder(h=BarHeight,r1=1.5,r2=.2,$fn=6);
      translate([0,0,1.5*NodeHeight-2.5]) sphere(r=0.5,$fn=16); }

   // had trouble with fill around braced link.  See if adding little hollows
   // helps slicer to fill better
   translate([-dLeft,0,NodeHeight/2]) {
      for(a=[0,30,60,90,120,150,180,210,240,270,300,330]) {
         translate([0.5*(Frad+Drad)*cos(a),0.5*(Frad+Drad)*sin(a),0])
            cylinder(h=NodeHeight-1.4,r=.4,$fn=6,center=true);
   }}

   // knock out a slot to take the CH linkage.
   translate([0,dPerp,NodeHeight-padH]) {
      cylinder(h=NodeHeight+2*padH,r=Hrad+3,$fn=48);
      hull() {
         translate([ 0,-4,0]) cube([.1,.1,NodeHeight+2*padH]);
         translate([ 7,-1,0]) cube([2,5,NodeHeight+2*padH]);
         translate([-7,-2,0]) cube([1,5,NodeHeight+2*padH]);
      }
   }

   //cube([3,11,11]);   // diagnostic slice to examine pyramid shell
   }
}

// custom support at H node
color("Cyan") union() {
  translate([0,29,NodeHeight-padH*.9]) difference() {
    cylinder(r2=4.4,r1=3.73,h=NodeHeight-.5,$fn=8);
    translate([0,0,-.1]) cylinder(r2=2.6,r1=3.4,h=5,$fn=8);
  }
if(0) {
  translate([0,29,NodeHeight*2-padH*2.5]) difference() {
    cylinder(r=4.55,h=1,$fn=8);
    translate([0,0,-.1]) cylinder(r=4.1,h=1.2,$fn=8);
  }
  translate([0,29.4,NodeHeight*2-padH*2.5]) difference() {
    cylinder(r=3.55,h=1,$fn=8);
    translate([0,0,-.1]) cylinder(r=3.1,h=1.2,$fn=8);
  }
  translate([4,28,NodeHeight*2-1.6]) rotate([0,0,60]) rotate([25,0,0]) cube([4,.35,4],center=true);
  translate([-3.5,27,NodeHeight*2-1.6]) rotate([0,0,-50]) rotate([25,0,0]) cube([4,.35,4],center=true);
} else {
  translate([0,dPerp,NodeHeight+2+padH]) {
    Hblade(4);
    rotate([0,0, 20]) Hblade();
    rotate([0,0, 50]) Hblade();
    rotate([0,0, 80]) Hblade();
    rotate([0,0,110]) Hblade();
    rotate([0,0,140]) Hblade();
    rotate([0,0,170]) Hblade();
    rotate([0,0,200]) Hblade(3.6);
    rotate([0,0,230]) Hblade(3.3);
    rotate([0,0,250]) Hblade(3.3);
    rotate([0,0,270]) Hblade(3.3);
    rotate([0,0,290]) Hblade(3.3);
    rotate([0,0,310]) Hblade(3.3);
    rotate([0,0,330]) Hblade(3.3);
    rotate([0,0,345]) Hblade(4.5);
  }
}
}

}






// Support blade for H node
lineW = 0.41;  // single line width
plateH = NodeHeight-2-padH*0.2;
module Hblade(len=3,h=plateH,w=lineW,cr=2) {
  translate([cr,-w/2,0]) cube([len,w,h]);
}

// example from config E, circa 140227
//bracedFoot(28.3675,75.792,29.3843);