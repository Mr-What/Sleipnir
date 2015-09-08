// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/JansenDefs.scad $
// $Id: JansenDefs.scad 426 2014-07-28 00:18:06Z mrwhat $

//--------------------------------------------------------- Boim optimization
AC=17.5;

// This one had the wide (stable) stance and small steps.
// unfortunately, one edge of the cycle was at the very tips of realizability.
// the linkage formed a bit of a rigid "circle" which was hard to move,
// and a small error could make it lock, and not make the full cycle.
// too dangerous.  Even if it was implemented perfectly, and did work,
// it would have some nasty torque ripple at the point in the cycle where
// a knee was at max flexion.... back to the drawing board...
//Ay=9.5;  Bx=56.3;
//BH=44.7; EF=68.2;
//CD=58.44;CH=83.2;
//BD=55.5; BE=57.6;  DE=59.6;
//FG=76.9; FH=34.76; GH=51.4;

// (A) This one had longer, rounder steps, but not quite as wide(stable) of a stance.
// try it before re-writing optimizer to try and avoid "poles" like we were close
// to in the above design.
/*
Ay=6.1;  Bx=48; 
BH=43.2; EF=46.35;
CD=59;   CH=73.2;
BD=48.6; BE=46.7; DE=65.4;
FG=77;   FH=41.3; GH=56.2;
*/

// (B) *** WARNING:  Although this linkage was 1.9mm to closest known "lock"
//                   where (A) was 0.6mm to closest known "lock",
//                   when printing it exhibited sticky, locking behavior.
//                   I recommend re-runngin optimizer, with a term that
//                   favors configurations where the CH link stays away
//                   from the B axle.  All "sticky" solutions built had CH
//                   get very close to the axle.
// After re-running the optimizer, circa 1308, with slightly different metric,
// and a keep-out zone around known bad linkage configurations, I liked
// JansenOpt14, number 114.  Fairly round footpath, not too high
// There were a family of good solutions that were VERY wide (large reach)
// which are interesting, but extreme.  I may try them later.
//Ay = 5.53;   Bx =  51.17;
//BD = 48.41;  BE =  45.76;  BH = 42.87;
//CD = 59.19;  CH =  74.37;  DE = 65.34;
//EF = 46.13;  FG =  77.29;
//FH = 41.77;  GH =  54.44;

// (C) from JansenOpt17, solution no 64:
//3.93 -51.72 48.41 45.6 42.73 59.73 73.48 65.21 47.29 77.22 41.01 55.08
/* skipping this.  CH clearance not very good
Ay =  3.93; Bx = 51.72;
BD = 48.41; BE = 45.6;  BH = 42.73;
CD = 59.73; CH = 73.48; DE = 65.21;
EF = 47.29; FG = 77.22;
FH = 41.01; GH = 55.08;
*/

// (D) Opt17 run, plot 237:
//1.38 -51.33 48 46.23 44.2 59.79 73.6 67.47 47.47 77.51 41.63 54.86
/*
Ay =  1.38; Bx = 51.33;
BD = 48   ; BE = 46.23; BH = 44.2 ;
CD = 59.79; CH = 73.6 ; DE = 67.47;
EF = 47.47; FG = 77.51;
FH = 41.63; GH = 54.86;
*/

/* configuration (E) circa 140227.  Tried to flatten stride, in the hopes
   that the little dip when cranks are vertical will be less pronounced than
   in cofiguration (D).
3.318 -53.833 48.020 46.977 40.359 59.635 71.441 66.437 47.467 75.792 40.843 55.790*/
Ay =  3.318; Bx = 53.833;
BD = 48.020; BE = 46.977; BH = 40.359;
CD = 59.635; CH = 71.441; DE = 66.437;
EF = 47.467; FG = 75.792;
FH = 40.843; GH = 55.790;

//  ------------ Published config:
////MainScale=1.1;  // scale crank from 15 (cm at 10:1) to 16.5 for use with standard bicycle crankset for AC
//MainScale=1.1666667;  // scale crank from 15 to 17.5, for 10:1 scale for use with 175mm bicycle crankset
//
//Ay =  7.8 * MainScale;
//Bx = 38   * MainScale;
//AC = 15   * MainScale;
//CD = 50   * MainScale;
//DE = 55.8 * MainScale;
//BD = 41.5 * MainScale;
//BE = 40.1 * MainScale;
//BH = 39.3 * MainScale;
//EF = 39.4 * MainScale;
//FG = 65.7 * MainScale;
//GH = 49   * MainScale;
//CH = 61.9 * MainScale;

DEleft = (DE*DE + BD*BD - BE*BE)/(2*DE);
FGleft = (FG*FG + FH*FH - GH*GH)/(2*FG);
DEperp = sqrt(BD*BD - DEleft*DEleft);
FGperp = sqrt(FH*FH - FGleft*FGleft);

echo(str("DEleft=",DEleft,"   DEperp=",DEperp));
echo(str("FGleft=",FGleft,"   FGperp=",FGperp));
