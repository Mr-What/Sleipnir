// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/optimize/NelderMeadSimplex.java $
// $Id: NelderMeadSimplex.java 149 2013-08-09 16:05:25Z aaron $

// had bug in port from octave nmsmax.
// re-doing based off of Wikipedia article.

package com.boim.optimize;
import java.util.Random;

// Nelder-Mead Simplex direct search optimization method.
public class NelderMeadSimplex {

    public double[] _verySmall;  // STOPIT(1) : stop when simplex smaller than this
    public int _maxEval; // STOPIT(2) : stop at this many evaluations
    public double _reflect;  // reflection factor
    public double _expand;  // expansion factor
    public double _contract;  // contraction factor
    public double _shrink;  // shrinkage factor
    public double _relSpreadLimit;  // stop when simplex rel error less than this
    public double _spreadFactor;  // gain factor for smoothing spread estimate
    public double _startStep;  // starting step, multiplier of _verySmall

    public double _prevBest;  // cache of last best metric eval.
    public int _prevIterations;  // no iterations for last optimize
    
    private int _direction;
    private double _spread;  // spread of quality metric, over simplex
    public int _verbose;  // 0==silent, higher number, more info
    static private Random _rand = null;
    
    public NelderMeadSimplex() {
        _verySmall = new double[] {.001};
        _maxEval = 999999;
        _direction=1;
        _reflect = 1;
        _expand = 2;
        _contract = -.5;
        _shrink = .5;
        _spread = -1;
        _relSpreadLimit = 0.001;
        _spreadFactor = 0.4;
        _startStep = 1000;
        _verbose = 2;
    }
    
    public void searchForMaxima() { _direction= 1; }
    public void searchForMinima() { _direction=-1; }

    public double[] optimize(QualityMetric qMetric, double[] x0) {
        checkVerySmall(x0.length);  // make sure termination tolerance is set
        int n = x0.length;
        double[][] V = initSimplex(x0);
        double[] f = new double[n+1];
        int i;
        for(i=0;i<=n;i++) f[i] = _direction*qMetric.metric(V[i]);
        int nf=n+1;               // count of function evaluations

        while(true) {
            int[] revIdx = descendingOrder(f);
            f = reorder(f,revIdx);
            V = reorder(V,revIdx);
            
            double spread = f[0]-f[n];  // quality range in simples
            double simSiz = simplexSize(V);
            //System.err.printf("qSpread %.6g  prev %.6g    Simplex size : %.4g%n",spread,_spread,simSiz);System.err.flush();
            
            if (_spread < 0) _spread = 2*spread;  // initialize spread est.
            if ((spread/_spread)>(1-_relSpreadLimit)) {
            	// spread is not reducing much, see if simplex is small too
                if (simSiz < .1) {  // compare spread of simplex, relative to _verySmall
                    if (_verbose > 1)
                        System.out.printf("Not improving significantly and simplex is small, done in %d evaluations.%n",nf);
                    _prevIterations = nf;
                    _prevBest = f[0];
                    return(V[0]);
                }
            }
            // Let spread update with some lag
            _spread = _spreadFactor * spread + (1-_spreadFactor) * _spread;

            if (nf > _maxEval) {
                if (_verbose > 0)
                    System.err.printf("failed to converge after %d evaluations.%n",nf);
                _prevIterations = nf;
                _prevBest = f[0];
                return(V[0]);
            }
            if (simSiz < .001) {  // compare spread of simplex, relative to _verySmall
                if (_verbose > 1)
                    System.out.printf("Simplex is very small, done in %d evaluations.%n",nf);
                _prevIterations = nf;
                _prevBest = f[0];
                return(V[0]);
            }

            double[] vbar = rowMean(V,n);  // mean, best n rows

            // reflect about mean
            double[] xr = vbar.clone();
            for(i=0;i<n;i++)xr[i]=(1+_reflect)*vbar[i]-_reflect*V[n][i];
            double fr = _direction*qMetric.metric(xr);  nf++;

            if (fr > f[0]) {
            	// this is best point so far.  check expanded point
            	double[] xe = vbar.clone();
            	for(i=0;i<n;i++) xe[i] = (_expand+1)*vbar[i] - _expand*V[n][i];
            	double fe = _direction*qMetric.metric(xe); nf++;
            	if (fe > fr) {
            		V[n] = xe;
            		f[n] = fe;
            		//System.err.println("expand");System.err.flush();
            		//System.err.print('e');System.err.flush();
            	} else {
            		V[n] = xr;
            		f[n] = fr;
            		//System.err.println("reflect best");System.err.flush();
            	}
            	continue;
            }

            if (fr > f[n-1]) {
            	// reflected is better than second worst, but not a new best,
            	// replace worst with reflected, and continue.
            	V[n] = xr;
            	f[n] = fr;
            	//System.err.println("reflect");System.err.flush();
            	continue;
            }
            
            // reflected is not better than second worst, try contraction
            double [] xc = vbar.clone();
            for(i=0;i<n;i++)xc[i]=(1+_contract)*vbar[i]-_contract*V[n][i];
            double fc = _direction*qMetric.metric(xc); nf++;
            if (fc > f[n]) { // contracted is better than worst, use it
            	V[n] = xc;
            	f[n] = fc;
            	//System.err.println("contract");System.err.flush();
            	continue;
            }
            
            // shrink
            for(i=1;i<=n;i++) {
            	for(int j=0;j<n;j++)
            		V[i][j] = (1-_shrink)*V[0][j] + _shrink*V[i][j];
            	f[i] = _direction*qMetric.metric(V[i]); nf++;
            	//System.err.println("shrink");System.err.flush();
            }
        }
    }

    
    private double[][] initSimplex(double[] x) {
        int n = x.length;
        double[][] V = new double[n+1][];
        int i;
        for(i=0; i <=n; i++) V[i] = x.clone();
        if (_rand == null) _rand = new Random();  // for randomized seed
        for(i=0; i<n; i++) {
        	double z = _rand.nextDouble();
        	if (z < 0.5) {
        		V[i+1][i] -= _startStep * _verySmall[i] * (.5 + z);
        	} else {
        		V[i+1][i] += _startStep * _verySmall[i] * z;
        	}
        }
        //for(i=0; i<n; i++) V[i+1][i] += _startStep * _verySmall[i] * (.1 + r.nextDouble());
        //for(i=0; i<n; i++) V[i+1][i] += 1000 * _verySmall[i];
        return V;
    }
    
    static private double[] reorder(double[] x, int[] idx) {
        double[] y = new double[idx.length];
        for(int i=0; i < idx.length; i++) y[i] = x[idx[i]];
        return y;
    }
    static private double[][] reorder(double[][] x, int[] idx) {
        double[][] y = new double[idx.length][];
        for(int i=0; i < idx.length; i++) y[i] = x[idx[i]].clone();
        return y;
    }

    static private double[] rowMean(double[][] V, int n) {  // mean, first n rows
        double[] y = V[0].clone();
        int j;
        for (j=1; j<n; j++) {
            for (int i=0; i < y.length; i++) y[i] += V[j][i];
        }
        for (j=0; j<y.length; j++) y[j] /= n;
        return y;
    }

    private void checkVerySmall(int n) {
        double[] vs = _verySmall;
        _verySmall = new double[n];
        for (int i=0; i<n; i++) {
            _verySmall[i] = (i<vs.length)?vs[i]:vs[vs.length-1];
        }
    }

    // Find max deviation from best answer so far, relative to _verySmall
    private double simplexSize(double[][] V) {
        //v1 = V(:,1);
        // size_simplex = norm(V(:,2:n+1)-v1(:,ones(1,n)),1) / max(1, norm(v1,1));
        double hi = 0;
        int n = V[0].length;
        for(int j=1;j<=n;j++) {
            for (int i=0; i<n; i++) {
                double d = Math.abs(V[0][i]-V[j][i]) / _verySmall[i];
                if (d > hi) hi=d;
            }
        }
        return hi;
    }

    static public int[] descendingOrder(double[] f) {
        int[] idx = new int[f.length];
        int i;
        for (i=0; i < f.length; i++) idx[i]=i;
        for (i=0; i < f.length-1; i++) {
                for (int j=i+1; j < f.length; j++) {
                        if(f[idx[j]] > f[idx[i]]) {
                                int t = idx[i];
                                idx[i] = idx[j];
                                idx[j] = t;
                        }
                }
        }
        return idx;
    }
        
}
