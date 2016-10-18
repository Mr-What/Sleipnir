// Utilities for steel jansen linkage

SI8onBolt();
translate([0,0,5]) SA8();
translate([0,0,11]) F698();

module SI8onBolt() {
  translate([-7,0,0]) rotate([0,90,0])
    cylinder(r=.8/2,h=5,$fn=17);
  SI8();
}

// SI8T/K rod end (female)
module SI8() scale(.1) difference() {
  union() {
    cylinder(r=10/2,h=12,center=true,$fn=24);
    hull() {
      cylinder(r=24/2,h=9,center=true,$fn=36);
      translate([-16,0,0]) rotate([0,90,0]) cylinder(r=4.5,h=1,$fn=16);
    }
    translate([-38,0,0]) rotate([0,90,0]) {
      cylinder(r=12.5/2,h=23,$fn=16);
      intersection() {
        translate([0,0,4]) cube([14,16,8],center=true);
        cylinder(r=16/2,h=7,$fn=19);
      }
    }
  }
  cylinder(r=8/2,h=22,center=true,$fn=16);
}

// SA8T/K rod end
module SA8() scale(.1) difference() {
  union() {
    cylinder(r=10/2,h=12,center=true,$fn=24);
    hull() {
      cylinder(r=24/2,h=9,center=true,$fn=36);
      translate([-16,0,0]) rotate([0,90,0]) cylinder(r=4.5,h=1,$fn=16);
    }
    translate([-42,0,0]) rotate([0,90,0]) cylinder(r=8/2,h=30,$fn=16);
  }
  cylinder(r=8/2,h=22,center=true,$fn=16);
}

// F688 8x16x5 bearing  flange 18x1.1
module F688 () scale(.1) difference() { union() {
  cylinder(r=8,h=5,$fn=36,center=true);
  translate([0,0,2.5-1.1]) cylinder(r=9,h=1.1,$fn=36);
  }
  cylinder(r=4,h=8,$fn=18,center=true);
}

//F698 8x19x6  flange 22x1.5
module F698 () scale(.1) difference() { union() {
  cylinder(r=19/2,h=6,$fn=36,center=true);
  translate([0,0,3-1.5]) cylinder(r=11,h=1.5,$fn=36);
  }
  cylinder(r=4,h=8,$fn=18,center=true);
}

//F608 8x22x7  flange 25x1.5
module F608 () scale(.1) difference() { union() {
  cylinder(r=11,h=7,$fn=36,center=true);
  translate([0,0,3.5-1.5]) cylinder(r=12.5,h=1.5,$fn=36);
  }
  cylinder(r=4,h=8,$fn=18,center=true);
}

// 6805 bearing, common for bicycle bottom-brackets
module bb6805() scale(.1) difference() {
  cylinder(r=37/2,h=7,$fn=48,center=true);
  cylinder(r=25/2,h=8,$fn=16,center=true);
}



