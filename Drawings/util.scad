// miscelaneous utilility modules


module nodeCyl(nodeHeight,nodeRad)
{ cylinder(h=nodeHeight,r1=nodeRad+.3,r2=nodeRad-.3,$fn=64); }  // set to 20+ for production quality

module drillHole(holeRad) translate([0,0,-.03]) cylinder(h=22,r=holeRad,$fn=80);

//module footpad(r) { // pad to help a part stick to plate for 3D printer
//   color("Cyan") cylinder(h=layer1bias,r1=r,r2=r-.3,$fn=11); }

// place a point, usually inside a linkage bar, to use in a hull
// with a part connected to a linkage bar
//module barAnchor(dx) translate([dx,0,0]) cylinder(h=BarHeight,r1=.8,r2=.6,$fn=6);

module sphereSection(r,h,ar=1.5,off=-.3,fn=48) translate([0,0,h/2]) intersection() {
  cube([2*r,2*r,h],center=true);
  translate([0,0,off*h]) scale([1,1,ar]) sphere(r,$fn=fn);
}

module linkNode(r,h,ar=1.5,off=-.3,fn=64,dx=20,dy=0,dz=0.3) hull() {
  sphereSection(r,h,ar,off,fn);
  translate([dx,dy,dz]) sphere(0.2);
}
