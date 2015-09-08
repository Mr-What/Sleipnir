// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/JansenMetric.java $
// $Id: JansenMetric.java 411 2014-02-26 15:32:13Z mrwhat $
// Implement a QualityMetric for optimization of a Jansen-type linkage.

package com.boim.walker;
import java.io.IOException;

import  com.boim.optimize.*;
import  com.boim.util.*;

public class JansenMetric implements QualityMetric {
    public JansenLinkage _linkage;
    public int _nSteps;
    public String[] _desc;

    public BadConfigurationList _badList;
    public double _badThresh;  // how close can you be to a known bad config before getting a penalty

    public double _clearBCHthresh;  // how close can CH get to B before penalty
    //public double _returnThresh;//  how much longer can return phase be than step length
    
    private int _nDiagPlots;  // counter to label diagnostic plots
    public  double _prevMax;  // metric at last dump
    private double _plotDistThresh;
    private double[] _prevState;
    
    //public double _contactThresh;  // how far from ground is still "on-ground"

    // weights/values for aspects of quality metric
    private class MetricParts {
        public double
            reach,      // how close legs get to center
            clearBCH,   // how B stays from CH link
            length,     // how long is the active portion of the step
            height,     // how high the step is on the return phase
            bumpyness,  // how non-flat the stride is while near ground
            dspeed,     // how constant the stride speed is while near ground
            nonPhysical,// measure of how much/how many evaluations are impossible
	        returnSym,  // symmetry of return path //returnLen,  // length of return foot path
	        kneeHeight; // lowest height of knee on return path
        
	// No more duty cycle.  Assume 50% duty cycle, switching at vertical crank position
	//duty,       // what fraction of cycle is near ground

//	public void load(String fileName) { /// load weights from an ASCII file
//	}

        public void setDefaultWeights() {
            reach      = .3;
	    //duty       = 2;
            clearBCH   = 3;
            length     = 2;
            height     = 2;
            bumpyness  = 3;
            dspeed     = 4;
            nonPhysical= 4;
            returnSym  = 2;  //returnLen  = 1;
            kneeHeight = 2;
        }

        public MetricParts() { setDefaultWeights(); }
    }
    
	private MetricParts _weight;
    private MetricParts _meas;   // measurement

    public JansenMetric(JansenLinkage jl) {
        _linkage = jl;
        _nSteps = 256;
        //_contactThresh = 4;   // cm from lowest to be considered on ground
        _weight = new MetricParts();
        _meas   = new MetricParts();
        _badThresh = 2;   // penalize if within this distance of bad
        _badList = new BadConfigurationList();
        _badList.load("JansenBadList.dat");
        _clearBCHthresh = 12.4;  // good for laser cut design, scaled to 17.5mm AC
        _nDiagPlots = 0; _prevMax=1.0; _plotDistThresh=0.5; _prevState = new double[] {0,0,0,0,0,0,0,0,0,0,0,0};
        //_returnThresh = 1.5;
        _desc = new String[2];
    }


    public double metric(double[] x) {
        _linkage.setState(x);
        StrideOrbit orb = new StrideOrbit(_linkage, _nSteps);  // compute orbit
        if (orb.nonPhysical)
        	_badList.add(x);
        _meas = orb.measure();
        double nonPhysicalDist = _badList.closest(x);
        double nonPhysFactr = nonPhysicalDist / _badThresh;  // normalize distance
        if (nonPhysFactr < 0.001)
        	nonPhysFactr = 0.001;

        double     reachFactr = Math.pow(_meas.reach    , _weight.reach    );
        double    lengthFactr = Math.pow(_meas.length   , _weight.length   );
        double    heightFactr = Math.pow(_meas.height   , _weight.height   );
        double      bumpFactr = Math.pow(_meas.bumpyness, _weight.bumpyness);
        double     speedFactr = Math.pow(_meas.dspeed   , _weight.dspeed   );
        double       symFactr = Math.pow(_meas.returnSym ,_weight.returnSym);

        double q = reachFactr * lengthFactr * heightFactr
        		/ (bumpFactr * speedFactr * symFactr);

        if (_meas.clearBCH < _clearBCHthresh) {  // low clearance penalty
            double clearFactr = _meas.clearBCH / _clearBCHthresh;
            clearFactr = Math.pow(clearFactr, _weight.clearBCH);
            q *= clearFactr;
        }

        //// penalty if return path gets a LOT longer than step length
        //double lenRatio = _meas.returnLen / (_meas.length * _returnThresh);
        //if (lenRatio > 1) {
        //    double lenFactr = Math.pow(lenRatio, _weight.returnLen);
        //}
        
        // penalty if knee drops below median step height
        double kneeDepth = _meas.kneeHeight - _meas.height;
        if (kneeDepth < 0) {
            kneeDepth = -kneeDepth;
            double kneeFactr = Math.pow(kneeDepth, _weight.kneeHeight);
            q /= 1+kneeFactr;
        }
        
        if (nonPhysFactr < 1.0) { // close enough to known non-physical to get a penalty
        	nonPhysFactr = Math.pow(nonPhysFactr,_weight.nonPhysical);
        	q *= nonPhysFactr;
        }

        _desc[0] = String.format(
"%.5g bump=%.2f^%.1f dspeed=%.2f^%.1f length=%.1f^%.1f height=%.1f^%.1f reach=%.1f^%.1f",
			q,
			_meas.bumpyness*10 ,_weight.bumpyness,
			_meas.dspeed*100   ,_weight.dspeed,
            _meas.length       ,_weight.length,
            _meas.height       ,_weight.height,
			_meas.reach        ,_weight.reach);
        _desc[1] = String.format("phys=%.1f clear=%.1f knee=%.1f sym=%.1f^%.1f",
                nonPhysicalDist,_meas.clearBCH ,kneeDepth,
                _meas.returnSym    ,_weight.returnSym);

        checkPlotRequest(q);  // check to see if user interactively reqiuested a plot

        return(q);
    }

    private void checkPlotRequest(double q) {
        int key = -1;
        double[] s = _linkage.getState();
        double d = BasicStats.dist(s,_prevState);
        if ((q > _prevMax) && (d > _plotDistThresh)) {
            key = 'd';  // trigger a dump on each new maxima
            _prevMax = q;
            _prevState = s.clone();
        } else { // check for keyboard request
            try {
                if (System.in.available() > 0) { // check if a plot was requested
                    key = System.in.read();
                }
            } catch (IOException e) {
                e.printStackTrace();
                System.err.println("Assuming no plot requested... will continue...");
            }
        }

        if ((key=='a') || (key=='d')) {
            _nDiagPlots++;
            String nam = String.format("dump%04d.svg",_nDiagPlots);
            _linkage.plotOrbit(128, 2, nam, _desc);
            if (key=='a') { // dump animation too
                String fmt = String.format("dump%04d_%%03d.svg",_nDiagPlots);
                _linkage.plotOrbitAnim(3,fmt);
            }
        } else if ((key=='h') || (key=='?')) {
            System.err.println("\na -- dump current linkage and animate\nd -- dump current linkage\n");
        } else if ((key==10) || (key=='\r') || (key < 0)) {
        // do nothing.  ignore whitespace and eoln chars
        } else {
            System.err.printf("Unsupported keystroke '%c'(%d)\n",key,key);
        }
    }

    public void setState(double[] x) {
        _linkage.setState(x);
    }
    public double[] getState() {
        double[] x = _linkage.getState();
        return x;
    }

    public static double returnPathErr(double[][] returnPath, double footLevel, double Gx0,double Gx2) {
        // a good (if not ideal) foot path will look like a symetric triangle.
        // measure how close this return path is to a symetric triangle.
        double returnLen = BasicStats.pathLength(returnPath);
        double activeLen = Math.abs(Gx0-Gx2);
        double Gx1 = 0.5 * (Gx0+Gx2);
        double r2 = returnLen/2;
        double l2 = activeLen/2;
        double h = Math.sqrt(r2*r2 + l2*l2);
        double[] G0 = {Gx0,footLevel};
        double[] G1 = {Gx1,footLevel+h};
        double[] G2 = {Gx2,footLevel};
        double d = 0;
        for (int i=0; i < returnPath.length; i++) {
            double d0 = BasicStats.dist(returnPath[i], G0, G1);
            double d2 = BasicStats.dist(returnPath[i], G2, G1);
            d += (d0 < d2) ? d0 : d2;
        }
        d /= returnPath.length;
        return d;
    }

    //--------------------------------------------------------- StrideOrbit sub-class

    private class StrideOrbit {
        //public int startReturn;  // index where return phase starts
        public double Bx;  // location of B axle
        //public double Ay;  // location of crank axis
        public double orbit[][][];
        public JansenLinkage _linkage;
        public boolean nonPhysical;

        public StrideOrbit(JansenLinkage jl, int nSteps) {
            double p[];
            nonPhysical = false;
            _linkage = jl;
            jl.update(0);
            //p = jl.getPos('A');   Ay = p[1];
            p = jl.getPos('B');   Bx = p[0];
            orbit = new double[6][][];
            int i;
            for (i=0; i < 6; i++) { orbit[i] = new double[nSteps][]; }
            for (i=0; i < nSteps; i++) {
                double theta = Math.PI * (2.0*i/nSteps + 0.5);
                jl.update(theta);
                p = jl.getPos('C');   orbit[0][i] = p;
                p = jl.getPos('D');   orbit[1][i] = p;
                p = jl.getPos('E');   orbit[2][i] = p;
                p = jl.getPos('F');   orbit[3][i] = p;
                p = jl.getPos('H');   orbit[5][i] = p;
                p = jl.getPos('G');   orbit[4][i] = p;
                
                if (p[1] == 0) // error code
                	nonPhysical = true;
            }
        }

        /// At this time, only clearance measured is between CH and B-axle.
        /// We may decide to add other clearances in a combined metric later if another
        /// critical clearance is identified
        public double clearanceBCH() {
            // on a reasonable Jansen linkage, this clearance is at a minimum
            // when the cranks are horizontal.
            //    I'm not totally sure of the above, but it seems to be pretty close to true.
            double theta = (Bx < 0) ? Math.PI : 0;
            _linkage.update(theta);
            double [] c = _linkage.getPos('C');
            double [] h = _linkage.getPos('H');
            double [] b = {Bx,0};
            double d = BasicStats.dist(b,c,h);
            return d;
        }

        public MetricParts measure() {
            int n = orbit[0].length;
            MetricParts p = new MetricParts();
            double Gx2 = orbit[4][n/2][0];
            double Gx0 = orbit[4][ 0 ][0];
            p.length = Math.abs(Gx2 - Gx0);
            p.clearBCH = clearanceBCH();
            //double bottom = getYmin(orbit[4]);

            int activeLo, activeHi, returnLo, returnHi;
            if (Bx > 0) {
                p.reach  = Math.abs(Gx2);  
                activeLo = 1;
                activeHi = n/2-1;
                returnLo = n/2+1;
                returnHi = n-1;
            } else {
                p.reach  = Math.abs(Gx0);
                returnLo = 1;
                returnHi = n/2-1;
                activeLo = n/2+1;
                activeHi = n-1;
            }
            double[] returnY = BasicStats.subArray(orbit[4], returnLo, returnHi-returnLo+1, 1);
            //p.height = BasicStats.median(orbit[4],returnLo,returnHi,1);
            p.height = BasicStats.median(returnY);
            double[] activeY = BasicStats.subArray(orbit[4],activeLo,activeHi-activeLo+1,1);
            BasicStats stepY = new BasicStats(activeY);
            double[] dx = BasicStats.getDiff(orbit[4],activeLo,activeHi,0);
            BasicStats stepDx = new BasicStats(dx);
            double[] ky = BasicStats.subArray(orbit[3], returnLo, returnHi-returnLo+1, 1); // knee return height
            BasicStats kneeY = new BasicStats(ky);
            p.bumpyness =  stepY.sd;
            p.dspeed    = stepDx.sd;
            p.kneeHeight = kneeY.min;
            // normalize the reach for a "standardized" step height of 100
            //double footLevel = BasicStats.median(orbit[4],activeLo,activeHi,1);
            double footLevel = BasicStats.median(activeY);
            //double footLevel = stepY.mean;
            p.reach *= -100.0 / footLevel;
            
            //p.returnLen = BasicStats.pathLength(orbit[4], returnLo, returnHi-returnLo+1);
            double [][] returnPath = BasicStats.subArray(orbit[4], returnLo, returnHi-returnLo);
            p.returnSym = returnPathErr(returnPath,footLevel,Gx0,Gx2);

            p.kneeHeight -= footLevel;
            p.height -= footLevel;
            p.nonPhysical = 1.0;  // no penalty... yet
            
            return p;
        }
    }

}
