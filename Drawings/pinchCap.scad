%cylinder(r=4.9/2,h=6.05,$fn=32);

skewerCap();


// this one is pretty good for kebab skewer, which seems to be slightly
// less than 3/16" diameter.  May need a little wider at top for 3/16" machine rod
module skewerCap() difference() {
  cylinder(r1=5,r2=4,h=6,$fn=32);

  for(a=[0:60:359]) rotate([0,0,a]) hull() { //cube([6,2.2,18],center=true);
    //translate([2.2,0,-.2]) cylinder(r1=1.2,r2=0.8,h=7,$fn=6);
    //translate([0  ,0,-.2])#cylinder(r1=2.4,r2=0.8,h=7,$fn=4);

    // lower
    #translate([3.5,0,0]) cube([.1,1.4,.2],center=true);
    #translate([1.5,0,0]) cube([.1,3.6,.2],center=true);

    // upper
    #translate([2.8,0,6]) cube([.1,0.8,.2],center=true);
    //%translate([1  ,0,6]) cube([.1,2  ,.2],center=true);
    #translate([1.4,0,6]) cube([.1,2  ,.2],center=true);
  }
  translate([0,0,-.4]) cylinder(r1=5/2,r2=1.8,h=7,$fn=12);
}