// Run simple test on simplex optimizer
package com.boim.optimize.tests;

//import java.io.*;
import com.boim.optimize.*;

public class Test1 {
    public static void main(String[] args) {
        QualityMetric a = new TestMetric();
        NelderMeadSimplex b = new NelderMeadSimplex();
        double[] x = {1,1};
        x = b.optimize(a,x);
        System.out.printf("Maxima at :%.9f %.9f%n",x[0],x[1]);
    }
}
