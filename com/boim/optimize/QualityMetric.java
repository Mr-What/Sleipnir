// This is a quality metric used in an optimizer.
package com.boim.optimize;

public interface QualityMetric {
    double metric(double[] x);
}
