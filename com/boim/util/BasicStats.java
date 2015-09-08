// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/util/BasicStats.java $
// $Id: BasicStats.java 407 2014-02-23 19:39:32Z mrwhat $
// Basic statistics of a double array, mean, sd, max, min, and some support static methods

package com.boim.util;
import java.util.Arrays;

public class BasicStats {
    public double min,max,mean,sd;

    public BasicStats(double[] z) {
	update(z);
    }

    public void update(double[] z) {
	int n = z.length;
	double sx  = 0;
	double sx2 = 0;
	min =  9e9;
	max = -9e9;
	for (int i=0; i < n; i++) {
	    double x = z[i];
	    sx += x;
	    sx2 += x*x;
	    if (x < min)
		min = x;
	    if (x > max)
		max = x;
	}
	mean = sx / n;
	sd = Math.sqrt(sx2/n - mean*mean);
    }
    
    // ---------------------------------------------------------------- statics

    // extract one dimension of a 2D array
    public static double[] subArray(double[][] z, int iLo, int n, int dim) {
        double[] x = new double[n];
        for (int i=0; i < n; i++) { x[i] = z[iLo+i][dim]; }
        return x;
    }

    // extract subset a 2D array
    public static double[][] subArray(double[][] z, int iLo, int n) {
        double[][] x = new double[n][];
        for (int i=0; i < n; i++) { x[i] = z[iLo+i]; }
        return x;
    }

    // standard euclidean distance
    public static double dist(double[] a, double[] b) {
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

    /// Distance of point p from line segment ab
    // assumes 2-element vectors
    public static double dist(double[] p, double[] a, double[] b) {
        double[] ab = {b[0]-a[0], b[1]-a[1]};
        double[] ap = {p[0]-a[0], p[1]-a[1]};
        double abNorm = Math.sqrt(ab[0]*ab[0] + ab[1]*ab[1]);
        ab[0] /= abNorm;  ab[1] /= abNorm;
        double pab = ap[0]*ab[0] + ap[1]*ab[1];
        double d = -1.0;
        if (pab <= 0) {
            d = dist(p,a);
        } else if (pab >= abNorm) {
            d = dist(p,b);
        } else {
            double[] pp = {ab[0]*pab, ab[1]*pab};  // projection of ap onto ab
            d = dist(ap,pp);
        }
        return d;
    }

    public static double getYmin(double[][] p) {
        double yMin = p[0][1];
        for (int i=1; i < p.length; i++) {
            if (p[i][1] < yMin)
                yMin = p[i][1];            
        }
        return yMin;
    }

    public static double median(double[][] p, int lo, int hi, int dim) {
        int n = hi-lo+1;
        double[] x = new double[n];
        int m = 0;  // number of good values
        for (int i=lo; i <= hi; i++) {
        	double xi = p[i][dim];
        	if (!Double.isNaN(xi))
        		x[m++] = xi;
        }
        Arrays.sort(x);  // nan treated like +inf
        int n0 = m/2;
        int n1 = (m-1)/2;
        double med = 0.5 * (x[n0] + x[n1]);
        return med;
    }

    public static double median(double[] p) {
        int n = p.length-1;
        double[] x = p.clone();
        Arrays.sort(x);  // nan treated like +inf
        while((n>0) && Double.isNaN(x[n]))  // ignore NaN's
        	n--;
        int n0 = (n+1)/2;
        int n1 = n/2;
        double med = 0.5 * (x[n0] + x[n1]);
        return med;
    }

    public static double[] getDiff(double[][] p, int nStart, int nStop, int dim) {
        int n = nStop-nStart+1;
        double[] dx = new double[n-1];
        for(int i=1; i < n; i++) {
            dx[i-1] = p[nStart+i][dim] - p[nStart+i-1][dim];
        }
        return dx;
    }

    public static double pathLength(double[][] z, int nStart, int n) {
        double len = 0;
        for (int i=1; i < n; i++) {
            len += dist(z[nStart+i],z[nStart+i-1]);
        }
        return len;
    }
    public static double pathLength(double[][] z) {
        int n = z.length;
        double len = 0;
        for (int i=1; i < n; i++) {
            len += dist(z[i],z[i-1]);
        }
        return len;
    }

}
