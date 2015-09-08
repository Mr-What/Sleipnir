// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/util/PointNode.java $
// $Id: PointNode.java 221 2013-09-09 13:23:09Z aaron $
//
// Node to create a tree of vectors (points), multi-dimensional, for fast searching
package com.boim.util;

import java.io.PrintStream;

public class PointNode {
    public double[] x;
    public int splitDim;
    public PointNode lt,ge;

    public PointNode() {
	splitDim=-1;  // undefined
	// leave rest as null, which is appropriate
    }
    public PointNode(double[] z) {
	splitDim=-1;  // undefined
	x = z.clone();
    }

    public double closest(double[] z, double closestSoFar) {
        double d = dist(z,x);
        if (d < 0)
            return closestSoFar;  // error occurred
        if (d<closestSoFar)
            closestSoFar = d;
        if (splitDim < 0)
            return closestSoFar;
        double di = Math.abs(z[splitDim]-x[splitDim]);
        double c0 = closestSoFar;
        if ((lt != null) && ((di <= c0) || (di < 0))) {
            double c = lt.closest(z,closestSoFar);
            if (closestSoFar > c)
                closestSoFar = c;
        }
        if ((ge != null) && ((di <= c0) || (di >= 0))) {
            double c = ge.closest(z,closestSoFar);
            if (closestSoFar > c)
                closestSoFar = c;
        }
        return closestSoFar;
    }

    public void add(double[] z, double fuzz) {
        if (x.length != z.length)
            return;  // error, mismatched dimensionality
        if (splitDim < 0) // choose dimension to split
            splitDim = greatestDimensionDifference(x,z);
        double d = z[splitDim] - x[splitDim];
        if (d < 0) {
            if (lt == null) {
                if (fuzz>0) {
                    double dz = dist(z,x);
                    if (dz < fuzz)
                        return;  // close enough to this,  don't repeat
                }
                lt = new PointNode(z);
            } else
                lt.add(z,fuzz);
        } else {
            if (ge == null) {
                if (fuzz>0) {
                    double dz = dist(z,x);
                    if (dz < fuzz)
                        return;  // close enough to this,  don't repeat
                }
                ge = new PointNode(z);
            } else
                ge.add(z);
        }
    }
    
    public void add(double[] z) {
        add(z,0);
    }

    public static int greatestDimensionDifference(double[] a, double[] b) {
	if (a.length != b.length)
	    return -1;
	if (a.length < 1)
	    return -2;
	int iMax = 0;
	double dMax  = Math.abs(a[0]-b[0]);
	for (int i=1; i < a.length; i++) {
	    double d = Math.abs(a[i]-b[i]);
	    if (d > dMax) {
		dMax = d; iMax = i; }
	}
	return iMax;
    }

    public static double dist(double[] a, double[] b) {
	if (a.length != b.length)
	    return -1.0;
	double d = 0;
	for (int i=0; i < a.length; i++) {
	    double di = a[i]-b[i];
            if (Double.isNaN(di))
                return(-2.0);
	    d += di*di;
	}
	d = Math.sqrt(d);
	return d;
    }

    static public void print(String fmt0, double[] a, PrintStream s) {
        s.printf(fmt0,a[0]);
        String fmt = '\t' + fmt0;
        for(int i=1; i < a.length; i++) s.printf(fmt, a[i]);
        s.println();
    }
}
