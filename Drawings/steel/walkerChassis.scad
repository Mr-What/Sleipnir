// config e
Ay=3.318;
AC=17.5;
Bx=53.83;

loY=-40;  // location of lower brace beams
loX= 20;

$fn=8;

for (a=[-1,1]) {
  %translate([0,0, 80*a]) legProxy();
  %translate([0,0,100*a]) legProxy();
  translate([0,0,90*a]) mainBar();
  translate([Bx*a,0,0]) cylinder(r=2.5,h=300,$fn=16,center=true); // main axle
  translate([-20*a,-40,0]) cube([2.5,2.5,300],center=true); // lower rails

  hull() for (b=[-1,1]) translate([ Bx*b, 0 ,70*a]) sphere(1); // arm guard bar
  hull() for (b=[-1,1]) translate([loX*b,loY,70*a]) sphere(1); // outer foot bar
  for (b=[-1,1]) {
    hull() { // outer diagonal
      translate([ Bx*b, 0 ,70*a]) sphere(1);
      translate([loX*b,loY,70*a]) sphere(1);
    }
    hull() { // inner support on outside trapaoid
      translate([  5*b, 0 ,70*a]) sphere(1);
      translate([loX*b,loY,70*a]) sphere(1);
    }
  }

  hull() { // center front trap
    translate([loX,loY, 2*a]) sphere(1);
    translate([ Bx, 0 ,25*a]) sphere(1);
  }
  hull() { // outer front diag
    translate([loX,loY,68*a]) sphere(1);
    translate([ Bx, 0 ,40*a]) sphere(1);
  }
  hull() { // inner back trap
    translate([-loX,loY,25*a]) sphere(1);
    translate([ -Bx, 0 , 5*a]) sphere(1);
  }
  hull() { // outer back
    translate([-loX,loY,35*a]) sphere(1);
    translate([ -Bx, 0 ,65*a]) sphere(1);
  }

  for (b=[-1,1]) { // outside diagonal brace
    hull() {
      translate([loX*b,loY,140*a]) sphere(1);
      translate([ Bx*b, 0 ,110*a]) sphere(1);
    }
    hull() {
      translate([ Bx*b, 0 ,140*a]) sphere(1);
      translate([loX*b,loY,110*a]) sphere(1);
    }
    hull() {
      translate([loX*b,loY,110*a]) sphere(1);
      translate([ Bx*b, 0 ,110*a]) sphere(1);
    }
  }
  hull() for(b=[-1,1]) translate([loX*b,loY,140*a]) sphere(1);
  hull() for(b=[-1,1]) translate([ Bx*b, 0 ,110*a]) sphere(1);


  hull() { // center foot low diag
    translate([ loX,loY, 5*a]) sphere(1);
    translate([-loX,loY,30*a]) sphere(1);
  }
  hull() {
    translate([-loX,loY,40*a]) sphere(1);
    translate([ loX,loY,70*a]) sphere(1);
  }
  for (b=[-1,1]) hull() {  // outer low X
    translate([-loX*b,loY,130*a]) sphere(1);
    translate([ loX*b,loY, 70*a]) sphere(1);
  }

}

module mainBar() {
  cube([110,5,5],center=true);
  translate([0,Ay,0]) {
    cylinder(r=1.5,h=4,$fn=16,center=true);
    #cylinder(r=AC,h=2,$fn=36,center=true);
    //cylinder(r=AC+2,h=.4,$fn=36,center=true);
  }

}
module legProxy() {

  legProxy1();
  mirror([1,0,0]) legProxy1();

}

// measurements from drawing, center pixel 600,300, 4 pixels/cm
module legProxy1() {

  hull() {
    translate([0,3.32,0]) cylinder(r=17.5+2,h=1,$fn=36,center=true);
    translate([-250/4, 290/4,0]) node();
    translate([-200/4, 290/4,0]) node();
    translate([-360/4, 120/4,0]) node();
    translate([-500/4,-110/4,0]) node();
    translate([-430/4,-230/4,0]) node();
  }
  hull() {
    translate([-400/4,-220/4  ,0]) node();
    translate([-340/4,-370/4+2,0]) node();
    translate([ -90/4,-370/4+2,0]) node();
    translate([-140/4,-120/4  ,0]) node();
  }
}

module node() cylinder(r=2,h=1,$fn=9,center=true);