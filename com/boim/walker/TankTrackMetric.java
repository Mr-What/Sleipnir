// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/TankTrackMetric.java $
// $Id: TankTrackMetric.java 139 2013-08-06 16:48:37Z aaron $
//
// Implement a QualityMetric for fit of a foot path to the
// path that would be taken by a tank track
package com.boim.walker;
import  com.boim.optimize.*;

public class TankTrackMetric implements QualityMetric {
    public double[][] _FootPos;  // measurement to match
    public double _x0, _y0, _len, _rate, _d0, _R;
    public double _heightWeight;  // weight height err by this w.r.t. x direction errs

    public TankTrackMetric(double radius)
    {
        _R = radius;  // radius of track wheels
        _heightWeight = 0.5;  // weight height error less on track section
    }

    public void setState(double[] x) {
        _x0   = x[0];
        _y0   = x[1];
        _len  = x[2];
        _rate = x[3];
        _d0   = x[4];
    }
    public double[] getState() {
        double[] x = new double[5];
        x[0] = _x0;
        x[1] = _y0;
        x[2] = _len;
        x[3] = _rate;
        x[4] = _d0;
        return x;
    }

    public void setMeasurement(double[][] G) {
	// will arrange measurement so it starts near (-_R,y0+_R),
	// move in +x direction (mostly)
        int n = G.length;
        if (n < 5) return;  // degenerate
        //for (int i=0; i < G.length; i++) {
        //    if (G[i] == null) {
        //        System.err.println("Why does foot orbit have a null pointer?");
        //    }
        //}
        _FootPos = new double[n][];
        if (G[n-1][0] > G[0][0]) {
            for (int i=0; i < n; i++) {
                _FootPos[i] = G[i].clone();
            }
        } else {
            for (int i=n-1; i >= 0; i--) {
                _FootPos[i] = G[i].clone();
            }
        }
        double xMin = 9e9;
        double yMin = 9e9;
        for (int i=0; i < n; i++) {
            if (_FootPos[i][0] < xMin) xMin = _FootPos[i][0];
            if (_FootPos[i][1] < yMin) yMin = _FootPos[i][1];
        }
        xMin += _R;  // let "zero" be track wheel radius in
        for (int i=0; i < n; i++) {
            _FootPos[i][0] -= xMin;
            _FootPos[i][1] -= yMin;
        }

	// ---- Set initial guess at track fit:

	// length between virtual drive wheel axes
        _len = _FootPos[n-1][0] - _FootPos[0][0] - 2*_R;
        _d0 = 0;
        _x0 = _y0 = 0;
        double totalTrackLen = _len + Math.PI * _R;
        _rate = totalTrackLen / (_FootPos.length-1);
    }

    public double metric(double[] x)
    {
        setState(x);

        double d = 0;
        for (int i=0; i < _FootPos.length; i++) {
            double[] p = getTrackPos(i);
            double dx = _FootPos[i][0] - p[0];
            double dy = _FootPos[i][1] - p[1];
            if ((p[0] > 0) && (p[0] < _len)) {
                // reduce weight of height errors along track
                dy *= _heightWeight;
            }
            d += dx*dx + dy*dy;
        }
        d = Math.sqrt(d/_FootPos.length);  // RMSE
        return d;
    }

    // compute position along an ideal tank track at this sample number
    public double[] getTrackPos(int i)
    {
	double x = i*_rate+_d0;
	double[] p = {_x0,_y0};
	if (x < 0) { // assume goes straight up after tank track
	    p[0] -= _R;
	    p[1] += _R-x;
	    return p;
	}
	double d = Math.PI * _R / 2;
	if (x <= d) {
	    double a = x / _R;
	    p[0] -= _R *    Math.cos(a);
	    p[1] += _R * (1-Math.sin(a));
	    return p;
	}
	x -= d;  // x is now dist along bottom of track
	if (x <= _len) {
	    p[0] += x;
	    return p;
	}
	x -= _len;  // x is now distance up second pulley
	p[0] += _len;
	if (x <= d) {
	    double a = x / _R;
	    p[0] +=  _R*       Math.sin(a);
	    p[1] +=  _R*(1.0 - Math.cos(a));
	    return p;
	}
	p[0] += _R;
	p[1] += _R;
	p[1] += x - d;
	return p;
    }

}
