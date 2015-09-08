// Simple QualityMetric to test NelderMeadSimplex algorithm
package com.boim.optimize.tests;
import com.boim.optimize.*;
import java.util.Random;

public class TestMetric2 implements QualityMetric {
    public double[] x0, sx;
    public int n;

    public TestMetric2()
    {
        n = 12;
        x0 = new double[n];
        sx = new double[n];
        Random r = new Random();
        for (int i=0; i < n; i++) {
            x0[i] = i;
            sx[i] = 0.01 * (0.1+r.nextDouble());
        }
    }

    public double metric(double[] x)
    {
        double z = 0;
        for (int i=0; i<n; i++) {
            double xx = (x[i] - x0[i]) * sx[i];
            z += xx*xx;
        }
        System.out.printf("%.6g   ", z);
        for (int i=0; i < n; i++) System.out.printf(" %.5f",x[i]);
        System.out.println();System.out.flush();
        return(-z);
    }
}
