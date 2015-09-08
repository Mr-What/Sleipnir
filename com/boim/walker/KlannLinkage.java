// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/KlannLinkage.java $
// $Id: KlannLinkage.java 139 2013-08-06 16:48:37Z aaron $
package com.boim.walker;
import java.io.*;

// Assume node B is at origin

public class KlannLinkage extends WalkerLinkage {
    public double _Bx, _By, _Dx, _Dy;  // fixed node locations, A is origin

    //public double _Fang, _Hang;  // fixed angles at nodes F and H (deg)
    public double _EG;  // virtual... no bar here, just dist
    public double _CF;  // may not be bar here.  rocker arm

    public double _AC;  // crank-arm length
    public double _CH;  // crank to rocker arm pivot
    public double _FH;  // leg middle pivot to rocker arm pivot
    public double _BH;  // Linkage from fixed point B to rocker arm pivot
    public double _DE;  // Fixed point D to leg top
    public double _EF;  // leg center to leg top
    public double _FG;  // leg center to foot

    //private double _theta;  // crankarm angle, radians
    private double[] _C, _E, _F, _G, _H;  // node positions
    public boolean _octFormat;  // print state in format convenient for octave/MATLAB
    
    public KlannLinkage()
    {
    	setDefault();
    	_C = new double[] {0,0};
    	_E = new double[] {0,0};
    	_F = new double[] {0,0};
    	_G = new double[] {0,0};
    	_H = new double[] {0,0};
        update();
    }
    public KlannLinkage(String[] args)
    {
    	setDefault();
    	double[] s = new double[12];
    	for (int i=0; i < 12; i++) s[i] = Double.parseDouble(args[i]);
    	setState(s);
        update();
    }

    public void setDefault()
    {
        //_Fang = 150;  // (deg) fixed leg "knee" angle
        //_Hang = 167.1578;
        _Bx = -.599;  _By = -.176;
        _Dx = .366+_Bx;  _Dy = .792+_By;
        _AC = .268;
        _CH = .59;
        _EG = 1.732;  // virtual... no bar here, just dist
        _CF = 1.1051;  // may not be bar here.  rocker arm
        _FH = 0.52205;  // leg middle pivot to rocker arm pivot
        _BH = .3204;  // Linkage from fixed point B to rocker arm pivot
        _DE = .5176;  // Fixed point D to leg top
        _EF = .89656;  // leg center to leg top
        _FG = .89654;  // leg center to foot
        _theta = 0;
    }
    
    public void flip() { _Bx *= -1; _Dx *= -1; }
    
    // optimized default linkage for 17.5cm crank arm, metric 1
    public void setOpt1()
    {
        /* first try
    	_Bx = -37.4165; _By = -11.2785;
    	_Dx = -18.6133; _Dy =  39.1785;
    	_AC=17.5;
    	_BH=23.7897;
    	_CF=72.3789;
    	_CH=40.2854;
    	_DE=35.7128;
    	_EF=59.0415;
    	_EG=114.9996;
    	_FG=56.2900;
    	_FH=32.0954;
    	*/
        // favorite as of 5/17/2013
        _AC=17.5;
        _Bx=-38.8; _By=-12.5;
        _Dx=-14.6; _Dy=41.9;
        _BH=23.7;
        _CF = 73.4;
        _CH = 38.8;
        _DE = 34.1;
        _EF = 57.7;
        _EG = 111.7;
        _FG = 59;
        _FH = 35.2;
        //-38.8 -12.5 -14.6 41.9 23.7 73.4 38.8 34.1 57.7 111.7 59 35.2
    }
    // optimized default linkage for 17.5cm crank arm, metric 2
    // added more non-physical penalties, and measured "Flatness"
    // of "active" part of stride
    public void setOpt2()
    {
    	_AC=17.5;  // constant setting on optimizer

    	_Bx = -36.1770;  _By = -12.2232;
    	_Dx = -14.8165;  _Dy =  40.1983;
    	_BH=25.7181;
    	_CF=66.8009;
    	_CH=36.4466;
    	_DE=37.6670;
    	_EF=56.2830;
    	_EG=111.4058;
    	_FG=58.3305;
    	_FH=31.6180;  // slightly non-physical.  E crosses D axis
    	
    	_Bx = -37.6707; _By = -12.5217;
    	_Dx = -16.4823; _Dy =  40.7626;
    	_BH=25.3110;
    	_CF=71.2671;
    	_CH=38.5052;
    	_DE=33.9067;
    	_EF=57.4020;
    	_EG=112.4047;
    	_FG=58.7901;
    	_FH=33.8532;
    	
    	// more tweaking of metric...
    	_Bx = -41.1110; _By = -14.3165;
    	_Dx = -20.5474; _Dy =  40.0771;
    	_BH=24.5489;
    	_CF=72.7508;
    	_CH=41.7440;
    	_DE=33.0592;
    	_EF=60.3454;
    	_EG=117.3521;
    	_FG=61.4408;
    	_FH=32.0696;
    	
    	// prevent node E from crossing axis
    	//    not a very flat step
    	_Bx = -39.1138;  _By = -11.4925;
    	_Dx = -15.2146;  _Dy =  40.2239;
    	_BH=20.9216;
    	_CF=72.1614;
    	_CH=38.5261;
    	_DE=33.7985;
    	_EF=58.5440;
    	_EG=113.0970;
    	_FG=58.5427;
    	_FH=34.0901;
    	
    	// tried to increase step flatness on above, but
    	// started converging near non-physical likages again.
    	_Bx = -37.1133; _By = -13.2144;
    	_Dx = -18.7900; _Dy =  39.3938;
    	_BH=23.4208;
    	_CF=72.2016;
    	_CH=40.4387;
    	_DE=32.5528;
    	_EF=60.0564;
    	_EG=118.7846;
    	_FG=58.7282;
    	_FH=31.9046;
    	
    	// had error in code to check E crossing axes.  fixed:
    	_Bx = -36.6771;  _By = -11.8165;
    	_Dx = -11.6454;  _Dy = 45.3425;
    	_BH=24.6959;
    	_CF=70.1769;
    	_CH=39.8880;
    	_DE=32.5176;
    	_EF=53.7343;
    	_EG=110.0125;
    	_FG=57.1142;
    	_FH=31.2540;
    	
    	// seeded with above, new metric.  more weight on stride flatness, const dx, and WEIGHTED
    	_Bx = -36.3905;  _By = -13.5268;
    	_Dx = -11.4023;  _Dy = 45.2162;
    	_AC=17.5000;
    	_BH=26.8938;
    	_CF=70.7024;
    	_CH=40.9094;
    	_DE=36.5919;
    	_EF=53.6512;
    	_EG=112.3984;
    	_FG=58.9363;
    	_FH=31.2528;
    	
    	// slightly new metric.  more weight on foot speed constinceny
    	// score 2.4e8
    	_Bx = -35.3114;  _By = -13.2342;
    	_Dx = -12.0092;  _Dy = 46.4441;
    	_AC=17.5000;
    	_BH=27.0529;
    	_CF=70.5805;
    	_CH=40.6743;
    	_DE=36.2510;
    	_EF=53.5678;
    	_EG=112.4683;
    	_FG=58.9005;
    	_FH=31.1574;
    	
    	// even more weight on foot speed, score 3.1e9
    	_Bx = -34.7326;  _By = -14.1046;
    	_Dx = -11.9342;  _Dy = 46.6916;
    	_AC=17.5000;
    	_BH=27.0449;
    	_CF=70.9096;
    	_CH=41.2391;
    	_DE=36.0792;
    	_EF=54.2367;
    	_EG=113.0327;
    	_FG=58.8777;
    	_FH=29.7236;
    	
    	// RADNOM seeded with above (the one with score 3.1e9)
    	// and got the following:
    	/*
    	_Bx = -34.4266;  _By = -13.4548;
    	_Dx = -11.4798;  _Dy = 45.8963;
    	_AC=17.5000;
    	_BH=26.2525;
    	_CF=70.9735;
    	_CH=41.2877;
    	_DE=36.3272;
    	_EF=54.2643;
    	_EG=112.9909;
    	_FG=58.7360;
    	_FH=29.8757;
    	
    	_Bx = -34.1317;  _By = -13.3960;  // 6.7e10
        _Dx = -11.7250;  _Dy = 46.7386;
        _AC=17.5000;
        _BH=26.9043;
        _CF=70.8763;
        _CH=41.3426;
        _DE=35.8469;
        _EF=54.1765;
        _EG=113.0123;
        _FG=58.8358;
        _FH=29.7476;
        
        //1.85e11
        _Bx = -34.7121;  _By = -11.6565;
        _Dx = -12.1059;  _Dy = 48.4502;
        _AC=17.5000;
        _BH=26.8280;
        _CF=70.7740;
        _CH=41.3259;
        _DE=32.6874;
        _EF=54.3018;
        _EG=112.9694;
        _FG=58.8174;
        _FH=29.9017;
 
        */
    	
    	
    }
    
    // same code (so far) as Opt2, but trying different seeds to get
    // better local maxima solution
    public void setOpt3()
    {
    	_AC=17.5;  // constant setting on optimizer

    	_Bx = -38.5129;  _By = -11.4161;
    	_Dx = -28.3526;  _Dy = 40.5843;
    	_BH=21.1770;
    	_CF=71.8644;
    	_CH=39.3474;
    	_DE=34.1071;
    	_EF=58.6816;
    	_EG=113.9237;
    	_FG=55.9323;
    	_FH=32.6449;
    	
    	// clean opt after tweaking above as seed: score 60000
    	_Bx = -39.6555;  _By = -11.6625;
    	_Dx = -30.3383;  _Dy = 40.9992;
    	_AC=17.5000;
    	_BH=22.2624;
    	_CF=74.8447;
    	_CH=41.3536;
    	_DE=34.2683;
    	_EF=58.5766;
    	_EG=113.9988;
    	_FG=55.6556;
    	_FH=33.6410;
    	
    	// tweaked above similarly, score 98000
    	_Bx = -40.7540;  _By = -11.6610;
    	_Dx = -31.7239;  _Dy = 41.0013;
    	_AC=17.5000;
    	_BH=22.6364;
    	_CF=77.8579;
    	_CH=43.3393;
    	_DE=34.2591;
    	_EF=58.4831;
    	_EG=114.1304;
    	_FG=55.6474;
    	_FH=34.6171;
/*
    	// again, score 156500
    	_Bx = -41.9399;  _By = -11.9852;
    	_Dx = -33.4443;  _Dy = 40.6520;
    	_AC=17.5000;
    	_BH=24.3653;
    	_CF=80.8603;
    	_CH=45.3358;
    	_DE=34.0331;
    	_EF=58.4868;
    	_EG=114.1364;
    	_FG=55.6498;
    	_FH=35.7012;
    	
    	// seeded with above, EXACTLY, negligibly different, score 183000
    	_Bx = -41.9545;  _By = -11.9865;
    	_Dx = -33.0361;  _Dy = 40.6840;
    	_AC=17.5000;
    	_BH=24.3723;
    	_CF=80.8603;
    	_CH=45.3343;
    	_DE=34.0658;
    	_EF=58.4891;
    	_EG=114.1386;
    	_FG=55.6496;
    	_FH=35.7018;
*/
    }
    	
    // make sure parameters are withing limits.
    // return a value > 1.0 if parameters needed to be tweaked
    // to be realizable.  The greater the check "penalty"
    // the more parameters needed to be tweaked.
    public double check()
    {
    	double penalty = 1.0;
        // do checks that linkage is realizable here.
    	if (_CF >= _CH+_FH) {
    		double s = 0.95 * (_CH+_FH) / _CF;
    		penalty /= s*s;
    		_CF *= s;
    	}

        double d = (_Bx < 0) ? -_Dx : _Dx;
        d = d - 2;
        if (d > 0) penalty += Math.sqrt(d);  // D on wrong side of axis, should be with B

    	return(penalty);
    }

    // Check for "undesirable" geometry at current position
    public double undesirable()
    {
        double [] x = getPos('E');
        if (_Dx < 0) x[0] *= -1;
        double de = 2-x[0];  // limit how close leg tip can get to axis
        if (de < 0) de=0;
        
        x = getPos('G');
        double d = -_AC-x[1];  // check if foot gets above crank
        if (d < 0) de += d;
        
        // this is called for ALL positions, need elsewhere for just walking
        //x = getPos('G');
        //double d = G[1] + 10;
        //if (d > 0) de += d;  // penalty for high foot in "walking" position
        
        return de;
    }

    // increase/decrease current size by given scale factor
    public void scale(double s)
    {
        _Bx *= s;
        _By *= s;
        _Dx *= s;
        _Dy *= s;
        _AC *= s;
        _CH *= s;
        _EG *= s;  // virtual... no bar here, just dist
        _CF *= s;  // may not be bar here.  rocker arm
        _FH *= s;  // leg middle pivot to rocker arm pivot
        _BH *= s;  // Linkage from fixed point B to rocker arm pivot
        _DE *= s;  // Fixed point D to leg top
        _EF *= s;  // leg center to leg top
        _FG *= s;  // leg center to foot
    }

    public void setState(double[] x) {
    	_Bx = x[0];
    	_By = x[1];
    	_Dx = x[2];
    	_Dy = x[3];
    	//_AC = _crankLen;  // assume AC is fixed when optimizing
    	_BH = x[4];
    	_CF = x[5];
    	_CH = x[6];
    	_DE = x[7];
    	_EF = x[8];
    	_EG = x[9];
    	_FG = x[10];
    	_FH = x[11];
    }
    public double[] getState() {
    	double[] x = new double[12];
    	x[0] = _Bx;
    	x[1] = _By;
    	x[2] = _Dx;
    	x[3] = _Dy;
    	x[4] = _BH;
    	x[5] = _CF;
    	x[6] = _CH;
    	x[7] = _DE;
    	x[8] = _EF;
    	x[9] = _EG;
    	x[10]= _FG;
    	x[11]= _FH;
    	return x;
    }

    public double[] getPos(char node)
    {
        double[] p = {0,0};
        switch(node)
            {
            case 'A': break;
            case 'B': p[0] = _Bx; p[1] = _By; break;
            case 'C': p=_C; break;
            case 'D': p[0] =_Dx; p[1] = _Dy; break;
            case 'E': p=_E; break;
            case 'F': p=_F; break;
            case 'G': p=_G; break;
            case 'H': p=_H; break;
            default: System.err.print(node);
                System.err.println(" is not a valid node name [A..H]"); 
            }
        return p;
    }


    public void printOrbit(int nSteps, PrintStream f)
    {
        for (int i=0; i < nSteps; i++)
            {
                update(2 * Math.PI * i / nSteps);
                double[] g = getPos('G');
                f.format("%.3f\t%.3f%n",g[0],g[1]);
            }
    }

    public void printOrbitFull(int nSteps, PrintStream f)
    {
        //// first line is B, D
        //f.format("%.4f %.4f\t%.4f %.4f\t0 0\t0 0\t0 0%n",_Bx,_By,_Dx,_Dy);
    	String fmt = new String("\t%8.3f %8.3f");
    	double[] a;
    	for (int i=0; i < nSteps; i++) {
       	    f.format("%8.3f %8.3f",_Bx,_By);
            update(2 * Math.PI * i / nSteps);
      	    f.format(fmt,_C[0],_C[1]);
       	    f.format(fmt,_Dx,_Dy);
            for (char node = 'E'; node <= 'H'; node++) {
               	a = getPos(node);
               	f.format(fmt,a[0],a[1]);
            }
            f.println();
        }
    }

    public void print(PrintStream f)
    {
    	if (_octFormat) {
    		// convenient format for octave/MATLAB
            f.format("A=[0,0];B=[%.4f,%.4f];D=[%.4f,%.4f];%n",_Bx,_By,_Dx,_Dy);
            f.format("AC=%.4f;%nBH=%.4f;%nCF=%.4f;CH=%.4f;%n",_AC,_BH,_CF,_CH);
            f.format("DE=%.4f;%nEF=%.4f;%nEG=%.4f;FG=%.4f;%nFH=%.4f;%n",_DE,_EF,_EG,_FG,_FH);
    	} else {
    		// convenient format for cut/paste into a method of this class
            f.format("_Bx = %.4f;  _By = %.4f;%n",_Bx,_By);
            f.format("_Dx = %.4f;  _Dy = %.4f;%n",_Dx,_Dy);
            f.format("_AC=%.4f;%n_BH=%.4f;%n_CF=%.4f;%n_CH=%.4f;%n",_AC,_BH,_CF,_CH);
            f.format("_DE=%.4f;%n_EF=%.4f;%n_EG=%.4f;%n_FG=%.4f;%n_FH=%.4f;%n",_DE,_EF,_EG,_FG,_FH);
    	}
    }

    // compute all node positions given current linkage lengths, fixed points, and crankshaft angle
    public void update()
    {
        _C[0] = _AC * Math.cos(_theta);
        _C[1] = _AC * Math.sin(_theta);
        double[] B = {_Bx,_By};
        double[] D = {_Dx,_Dy};
        try {
            if (_Bx < 0) {
                _H = triVertex( B,_BH,_C,_CH);
                _F = triVertex(_H,_FH,_C,_CF);
                _E = triVertex(_F,_EF, D,_DE);
                _G = triVertex(_E,_EG,_F,_FG);
            } else {
                _H = triVertex(_C,_CH, B,_BH);
                _F = triVertex(_C,_CF,_H,_FH);
                _E = triVertex( D,_DE,_F,_EF);
                _G = triVertex(_F,_FG,_E,_EG);
            }
        } catch(Exception e) {
        	//System.err.println(e.getMessage());
        	_G[0] = _G[1] = 0;  // show foot at impossible location for err
        }
    }
}
