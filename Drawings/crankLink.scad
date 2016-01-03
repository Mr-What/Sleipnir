// copied values from Jansen.scad, just for testing.
// intended to ONLY be called from Jansen.scad where these values are set!
//BarHeight=3;  LinkRad=3;  AradFree=2.5; NodeHeight=4.3;
//module drillHole(holeRad) { translate([0,0,-.03]) cylinder(h=22,r=holeRad,$fn=18); }
//crankLink(60,15,2.5);

// linkage with thin, wide connection for crank side, full node height on other
module crankLink(len,dFlat,rHole) {
// changing crank spindle to a 3/16 spacer instead of the 1/8" brass tube
radA = AradFree;  // free spinning on 3/16 OD standoff
echo(str("rHole=",rHole));
  difference() {
    union() {
      hull() {
        intersection() {
          translate([0,0,NodeHeight/4]) cube([20,20,NodeHeight/2],center=true);
          translate([0,0,NodeHeight/4]) scale([radA+3,radA+3,0.8*NodeHeight])
               sphere(1,$fn=48);
        }
        translate([dFlat*1.5,0,NodeHeight/4]) sphere(NodeHeight/4,$fn=8);
      }

      *translate([len,0,0]) {
        hull() {
          cylinder(h=NodeHeight,r1=rHole+2.2,r2=rHole+2,$fn=48);
          translate([-rHole-4,0,0]) cylinder(h=BarHeight,r1=1.2,r2=1,$fn=6);
        }
      }
      translate([len,0,0]) {
        hull() {
          intersection() {
            translate([0,0,NodeHeight/2]) cube([20,20,NodeHeight],center=true);
            translate([0,0,NodeHeight/2]) scale([rHole+2,rHole+2,NodeHeight*.9])
                sphere(1,$fn=48);
          }
          translate([-rHole*7,0,.1]) sphere(.1);
        }
      }

      *hull() {  
        cylinder(h=NodeHeight/2,r1=LinkRad+.4,r2=LinkRad,$fn=6);
        translate([len/2,0,0])
            cylinder(h=NodeHeight/2,r1=LinkRad+.4,r2=LinkRad,$fn=6); 
      }
      *hull() { 
        translate([dFlat-2,0,0]) cylinder(h=BarHeight,r1=LinkRad+.4,r2=LinkRad-.2,$fn=6);
        translate([len-2  ,0,0]) cylinder(h=BarHeight,r1=LinkRad+.4,r2=LinkRad-.2,$fn=6);
      }
      // thin, flat bottom main bar
      intersection() {
        translate([len/2,0,NodeHeight/4]) cube([40+len,20,NodeHeight/2],center=true);
        hull() {
          translate([ 0 ,0,1]) scale([2,rHole+1,3]) sphere(1,$fn=48);
          translate([len,0,1]) scale([2,rHole  ,3]) sphere(1,$fn=48);
        }
      }

      // vertical brace
      *hull() {
        translate([dFlat+2  ,0,BarHeight-1]) scale([1,1,1.5]) sphere(r=1,$fn=12);
        translate([len-rHole,0,BarHeight-1]) scale([1,1,1.5]) sphere(r=1,$fn=12);
        translate([len*0.65 ,0,BarHeight+.5]){scale([0.6,0.6,1.7]) sphere(r=1,$fn=12);
          translate([0,0,-2]) scale([2,2,1]) sphere(r=1,$fn=12);}
        translate([dFlat+15 ,0,BarHeight+.5]){scale([0.6,0.6,1.7]) sphere(r=1,$fn=12);
          translate([0,0,-2]) scale([2,2,1]) sphere(r=1,$fn=12);}
      }
      hull() {
        translate([radA+2 ,0,1]) cube([1,.4,.1],center=true);
        translate([len*.4 ,0,1]) cylinder(r1=2  ,r2=.15,h=4);
        translate([len*.75,0,1]) cylinder(r1=1.7,r2=.15,h=4);
        translate([len-radA-2,0,3]) cube([1,.2,.1],center=true);
      }

   }

  drillHole(radA);  // a little extra to move freely
  translate([len,0,0]) drillHole(rHole);
  translate([-20,-20,-10]) cube([40+len,40,10]);
}}


module crankLink1(len,dFlat,rHole) {
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
