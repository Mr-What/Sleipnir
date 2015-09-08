// Simple QualityMetric to test NelderMeadSimplex algorithm
package com.boim.optimize.tests;
import com.boim.optimize.*;

public class TestMetric implements QualityMetric {
    public double x0,sx,y0,sy;

    public TestMetric()
    {
        x0=3;sx=.1;
        y0=4;sy=.2;
    }

    public double metric(double[] x)
    {
        double xx = (x[0]-x0)*sx;
        double yy = (x[1]-y0)*sy;
        double z = xx*xx * yy*yy;
        return(-z);
    }
}
