/*
$URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/SplitList.java $
$Id: SplitList.java 402 2014-02-21 17:20:14Z mrwhat $

Simple class to split a list of vectors around the vector closest to the mean
*/

package com.boim.walker;

import java.util.*;

import com.boim.util.BasicStats;

public class SplitList {
    public double[] center;
    public double[][] a,b;
    public double[] mu,var;
        
    public SplitList(double[][] c) {
        int n = c.length;
        computeStats(c);
        int closestIdx = findClosest(mu,c);
        center = c[closestIdx];
        int maxIdx = findMaxIdx(var);
        double x = center[maxIdx];
        c[closestIdx] = c[0];  // replace center with first for rest of processing
        LinkedList<double[]> qa = new LinkedList<double[]>();
        LinkedList<double[]> qb = new LinkedList<double[]>();
        for (int k=1; k < n; k++) {
            if (c[k][maxIdx] < x) {
                qa.add(c[k]);
            } else {
                qb.add(c[k]);
            }
        }
        a = qa.toArray(new double[0][]);
        b = qb.toArray(new double[0][]);
    }

    private void computeStats(double[][] c){
        int n = c.length;
        int len = c[0].length;
        double[] sx  = new double[len];
        double[] sx2 = new double[len];
        mu = new double[len];
        var = new double[len];
        for (int k = 0; k < n; k++) {
            for (int i=0; i < len; i++) {
                double x = c[k][i];
                sx[i] += x;
                sx2[i] += x*x;
            }
        }
        for (int k=0; k < len; k++) {
            mu[k] = sx[k] / n;
            var[k] = sx2[k]/n - mu[k]*mu[k];
        }
    
    }

    public static int findClosest(double[] x, double[][] c) {
        int n = c.length;
        double lo = 9e32;
        int iLo = -1;
        for (int i=0; i <n; i++) {
            double d = BasicStats.dist(x, c[i]);
            if ((d < lo) && (d >= 0)) {
                iLo = i;
                lo = d;
            }
        }
        return iLo;
    }

    public static int findMaxIdx(double[] x) {
        int n = x.length;
        int hi = 0;
        for (int i=1;i<n;i++) {
            if (x[i] > x[hi])
                hi = i;
        }
        return hi;
    }
}
