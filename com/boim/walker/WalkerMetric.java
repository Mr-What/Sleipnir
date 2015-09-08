// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/WalkerMetric.java $
// $Id: WalkerMetric.java 402 2014-02-21 17:20:14Z mrwhat $
// Implement a QualityMetric for optimization of a Walker linkage.
// This should be abstract, but for now it may have a little
// code specific to Klann or Jansen linkages
package com.boim.walker;
import java.util.Arrays;

import  com.boim.optimize.*;

public class WalkerMetric implements QualityMetric {
    public WalkerLinkage _linkage;
    public int _nSteps;
    public double _contactThresh; // how close to ground to be "on ground"
    public double _crankLen;  // let crank length be fixed.
    public String desc;

    public double _reachWeight, _dutyCycleWeight, _clearanceDistanceWeight,
          _stepHeightWeight, _lenWeight, _trackWeight, _orbitLenWeight;
    // _footSpeedWeight, _flatnessWeight
    
    public TankTrackMetric   _stepMetric;
    public NelderMeadSimplex _stepOptimizer;

    public WalkerMetric(WalkerLinkage wl)
    {
        _linkage = wl;
        _nSteps = 128;
        _contactThresh = 4;   // cm from lowest to be considered on ground
        _crankLen = 17.5;  // cm
//        _linkage.scale(_crankLen/_linkage._AC);
        _reachWeight = 2;     // how much to weight each stat in metric
        _dutyCycleWeight = 8;
        //_footSpeedWeight = 2;
        //_flatnessWeight = 3;
        _stepHeightWeight = 3;
        _lenWeight = 1;
        _trackWeight = 3;
        _orbitLenWeight = 1;
        _clearanceDistanceWeight = 1;
        _stepMetric = new TankTrackMetric(_contactThresh);
        _stepOptimizer = new NelderMeadSimplex();
        _stepOptimizer.searchForMinima();
        _stepOptimizer._verbose=0;  // turn off ALL disgnostic output
	_stepOptimizer._startStep = 50;  // very small initial search step, relative to _verySmall.  Initial guess should be good
	_stepOptimizer._verySmall =  new double [] {0.01, 0.01, 0.01, 0.001, 0.01}; // xoffset(cm), yoffset(cm), stride-length(cm), stride-rate(cm/step), initial-step-offset(cm)
    }

    private class StrideStats {
        public double xHi, xLo, dxMean, dxVar, dutyCycle, yVar, stepMedian, orbitLen;
        public int startIdx, stopIdx;  // index (modulo) where ground contact starts and stops
        public double _stepPath[][];

        StrideStats(double[][] G, double yMin, double contactTol) {
            orbitLen = orbitLength(G);
            double yThresh = yMin+contactTol;  // yMin is negative... move up for ground contact threshhold
            double[] dx = findDutyCycle(G, yThresh);
            int nActiveSteps = stopIdx-startIdx;
            if (nActiveSteps < 0) nActiveSteps += G.length;
            nActiveSteps++;
//System.err.format("Step range %d..%d (%d)%n", startIdx, stopIdx, nActiveSteps);
            dutyCycle = ((double)nActiveSteps) / G.length;
            _stepPath = new double[nActiveSteps][];
            xHi = xLo = dxMean = 0;
            stepMedian = 1;
            dxVar = yVar = 100;
            int n=0;
            dxVar = yVar = 0;
            xHi = -999;
            xLo =  999;
            if (startIdx < 0) return;  // degenerate
            double sw=0;  // sum of weights, for WEIGHTED stats
            double yBar = 0;
            int i = startIdx-1;
            // do Y stats over duty cycle only
            while (i != stopIdx) {
                i++;
                if (i >= G.length) i=0;

                // weight relative to how close we are to bottom of step
                double w = (yThresh-G[i][1]+0.4*contactTol)/(contactTol*1.4);
                double y = G[i][1];
                if (n < nActiveSteps)
                    _stepPath[n++] = G[i].clone();
                else
                    System.err.println("How did n get out of range?");
                if (G[i][0] < xLo) xLo = G[i][0];
                if (G[i][0] > xHi) xHi = G[i][0];
                yBar += w*y;
                yVar += w*y*y;
                sw += w;
            }
            if (dutyCycle < 0.4) {
                yVar = 100;
                return; // degenerate
            }
            yBar /= sw;
            yVar = (yVar/sw) - (yBar*yBar);
            // do dx stats for any position under the threshhold
            sw=0;
            for (n=i=0; i < G.length; i++) {
                if (G[i][1] < yThresh) {
                    // weight relative to how close we are to bottom of step
                    double w = (yThresh-G[i][1]+0.4*contactTol)/(contactTol*1.4);
                    //double y = G[i][1];
                    //if (G[i][0] < xLo) xLo = G[i][0];
                    //if (G[i][0] > xHi) xHi = G[i][0];
                    double dxi = dx[i];
                    dxMean += w*dxi;
                    dxVar += w*dxi*dxi;
                    sw += w;
                    n++;
                }
            }
            dxMean /= sw;
            dxVar = (dxVar/sw)-(dxMean*dxMean);
            
            // compute median step height, when NOT in ground contact
            double[] yStep = new double[G.length-nActiveSteps];
            i = stopIdx+1;
            if (i >= G.length) i=0;
            n=0;
            while (i != startIdx) {
                double y = G[i][1];
                if (y==0) // error code
                    return;
                yStep[n++] = y-yBar;
                i++;
                if (i >= G.length) i=0;
            }
            Arrays.sort(yStep);
            stepMedian = yStep[(G.length-nActiveSteps)/2];
        }

        private double orbitLength(double[][] G) {
            double dTot = dist(G[0],G[G.length-1]);
            for (int i=1; i < G.length; i++)
                dTot += dist(G[i-1],G[i]);
            return dTot;
        }
        
        public double dist(double[] a, double[] b) {
            if (a.length != b.length)
                return -1.0;
            double d = 0;
            for (int i=0; i < a.length; i++) {
                double di = a[i] - b[i];
                d += di*di;
            }
            d = Math.sqrt(d);
            return d;
        }
        
        private double[] findDutyCycle(double[][] G, double yThresh) {
            // let's define duty cycle to part of cycle where foot is
            // moving in the "forward" direction, AND is below yThresh.
            int n = G.length;
            double[] dx = new double[n];
            dx[0] = G[1][0] - G[n-1][0];  // use both neighbors, actually 2*dx
            dx[n-1] = G[0][0] - G[n-2][0];
            double dxWalking = 0;  // average of dx while foot is low, assume this is "walking" direction
            int i;
            for (i=1; i < n-1; i++) {
                dx[i] = G[i+1][0] - G[i-1][0];
                if (G[i][1] < yThresh) dxWalking += dx[i];
            }
            
            stopIdx = startIdx = -1;
            // start in a non-walking part of cycle
            for (i=0; i < n; i++) {
                if (G[i][1] > yThresh) {
                    startIdx = i;
                    break;
                }
            }
            if (i >= n) {
                startIdx = stopIdx = -1;  // degenerate cycle
                return dx;
            }
            // search forward until we see a walking sample
            for (i=0; i < n; i++) {
                        int i0    = moduloCount(i+startIdx,n);
                        if ( (dx[i0] * dxWalking > 0) && (G[i0][1] < yThresh) ) {
                            startIdx = i0;
                            break;
                        }
            }
            if (i >= n) {
                startIdx = stopIdx = -1;  // degenerate cycle
                return dx;
            }
            // keep scanning forward until we see a non-walking sample
            for (i=0; i < n; i++) {
                int i0    = moduloCount(i+startIdx,n);
                if ( (dx[i0] * dxWalking > 0) && (G[i0][1] < yThresh) ) {
                    stopIdx = i0;
                } else {
                    break;
                }
            }
            return dx;
        }

        private int moduloCount(int ii, int n) {
            int i = ii;
            while (i >= n) i -= n;
            while (i <  0) i += n;
            return i;
        }
    }
    
    public double metric(double[] x)
    {
        setState(x);

        double nonPhysicalPenalty = 1.0;//_linkage.check(); // >1 if paramaters (nearly) exceed physical limits
        boolean nonPhysical = false;  // true if THIS linkage found to be non-physical
        double GyMin = 999;
        double GyMax =-999;
        double GxMin = 999;
        double GxMax =-999;
        double undesirableGeometry = 0;
        
        // This was added specificly to keep Jansen CH link away from B axle.
        // if there is not a similar bumping-into-other links on other linkages, just have this method
        // always return 1.0
        double linkClearanceDist = 99;  // how far links are from bumping into each other
        
        double[][] G = new double[_nSteps][2];
        int i;
        for (i=0; i < _nSteps; i++) {
            double theta = (i * 2 * Math.PI) / _nSteps;
            _linkage.update(theta);
            
            double cd = _linkage.clearanceDistance();
            if (cd < linkClearanceDist)
                linkClearanceDist = cd;  // note closest (worst) clearance
            
            G[i] = _linkage.getPos('G');
            if (G[i][1] == 0) { // non-physical
                nonPhysicalPenalty *= 1.1;
                if (!nonPhysical) { // check if already added
//                    nonPhysical = true;  _linkage._badList.add(getState());
                }
            } else {
                if (G[i][1] < GyMin) GyMin = G[i][1];
                if (G[i][1] > GyMax) GyMax = G[i][1];
                if (G[i][0] < GxMin) GxMin = G[i][0];
                if (G[i][0] > GxMax) GxMax = G[i][0];

                // Check for "undesirable" geometry at current crank angle
                double de = _linkage.undesirable();
                if (de > 0)
                    undesirableGeometry += de; //Math.pow(de,.25)*0.01;
            }
        }
        //double stridePeak = GyMax-GyMin;
        double thresh = GyMin;
        if (thresh > -20) {
                // for these walkers, anything higher than that
                // must be from an error, that reports 0,0 foot location
                thresh = -20;
        }
        StrideStats stat = new StrideStats(G,thresh,_contactThresh);

        double trackQ = 99;
        double len = 1;
        double reach = 1;
        if (stat.startIdx >= 0) {
            // use a metric of how tank-like the stride is instead
            // of the footSpeed/flatness measures
            _stepMetric.setMeasurement(stat._stepPath);
            double[] stepStats = _stepMetric.getState();
            stepStats = _stepOptimizer.optimize(_stepMetric,stepStats);

            trackQ = _stepMetric.metric(stepStats); 

            // try to make metric a "quality" metric, the larger the better
            len = stat.xHi-stat.xLo;  // stride length
            //len = Math.abs(stepStats[2]);  // flat part of track-model fit
            
            // for now, default linkages are always LHP.
            // so the worst reach position is:  (we want this far from axis)
            reach = Math.abs(stat.xHi / GyMin);
            
            // we should try to add a metric for how simple/smooth
            // the return path is, to avoid those over-fits with odd foot motion
        }
        double reachFactor = (reach < .01) ? 1 : Math.pow(reach*100,_reachWeight);
        double dutyCycleFactor = Math.pow(stat.dutyCycle,_dutyCycleWeight);
        //double footSpeedFactor = Math.pow(stat.dxVar,_footSpeedWeight);
        //double flatnessFactor  = Math.pow(stat.yVar,_flatnessWeight);
        double stepHeightFactor = Math.pow(stat.stepMedian,_stepHeightWeight);   // need to weight this heavily for Jansen, which tends toward a flat step.
        double lenFactor = Math.pow(len, _lenWeight);
        double trackQfactor = Math.pow(trackQ,_trackWeight);
        double orbitLenFactor = Math.pow(stat.orbitLen, _orbitLenWeight);  // attempt at avoiding odd, high foot motions... worked only somewhat.
        double clearanceFactor = Math.pow(linkClearanceDist, _clearanceDistanceWeight);
        double q = lenFactor * reachFactor;
        q *= stepHeightFactor;
        q *= dutyCycleFactor;
        //q /= footSpeedFactor;   // consistency of stride speed
        //q /= flatnessFactor;  // flatness of stride
        q /= trackQfactor;
        q /= orbitLenFactor;
        q *= clearanceFactor;

        // provide a metric "Description" which might be
        // helpful to humans needing to interpret linkage "quality"
        // is a less rigorous manner
        //desc = String.format("duty=%.1f speedSD=%.1f flatSD=%.2f reach=%.1f stepHeight=%.1f len=%.1f",
        //        stat.dutyCycle*100,
        //        Math.sqrt(stat.dxVar)*_nSteps, // variance/cycle (not step)
        //        Math.sqrt(stat.yVar),reach*100,stat.stepMedian,len);
        desc = String.format("duty=%.1f trackFit=%.2f reach=%.1f stepHeight=%.1f len=%.1f",
                stat.dutyCycle*100,trackQ,reach*100,stat.stepMedian,len);
        
        if (nonPhysicalPenalty > 1.0) {
            double pp = intPow(nonPhysicalPenalty, 4);
            q /= pp;
        }
        if (undesirableGeometry > 1.0) {
            double pp = Math.pow(undesirableGeometry,.2);
            q /= pp;
        }
        //System.out.printf("%g %f %f %f %f %f %f %f %f %f %f %f %f%n",
        //              q,x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10],x[11]);
        return(q);
    }
    
    public static double intPow(double x, int k)
    {
        if (k<=0) return(1.0);
        double z = x;
        for (int i=1; i < k; i++) z *= x;
        return z;
    }
    
    public void setState(double[] x) {
        _linkage.setState(x);
    }
    public double[] getState() {
        double[] x = _linkage.getState();
        return x;
    }
}
