// Run simple test on simplex optimizer
package com.boim.optimize.tests;

//import java.io.*;
import com.boim.optimize.*;
import java.util.Random;
public class Test2 {
    public static void main(String[] args) {
        TestMetric2 a = new TestMetric2();
        NelderMeadSimplex b = new NelderMeadSimplex();
        //b._reflect = 0.77;  // reduced from 1.  When walking away from worst, take slightly smaller step
        b._expand  = 1.77;   // when expanding, don't quite double, as is usual
        //b._contract = -.73;  // don't quite contract in half
        b._shrink = .63;  // don't quite shrink in half
        double[] x = new double[a.n];
        Random r = new Random();
        for (int i=0; i < a.n; i++) x[i] = r.nextGaussian()*2;
        x = b.optimize(a,x);
        System.out.print("Maxima at :");
        for (int i=0; i < a.n; i++) System.out.printf(" %.6f", x[i]);
        System.out.println();
    }
}
