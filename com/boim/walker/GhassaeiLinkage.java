// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/GhassaeiLinkage.java $
// $Id: GhassaeiLinkage.java 69 2013-05-15 14:41:25Z aaron $
//
// Walking linkage as suggested in paper by Amanda Ghassaei,
// 20 April, 2011, Pamona College, under Profs Choi and Whitaker.
//

package com.boim.walker;
import java.io.*;


public class GhassaeiLinkage extends WalkerLinkage {
    public double _Bx;  // location of fixed node B on x axis (usually negative)
    public double _Ay;  // location of crank center on y axis (usually positive)
    public double _AC;  // crank-arm length
    public double _BD, _BE, _DE; // defines fixed angle rocker anchored at fixed node B
    public double _BF;
    public double _CD, _CF; // lenfths of linkages to crank arm
    public double _EG, _FG; // links to foot hinge at G

    private double[] _C, _D, _E, _F, _G;  // node positions

    public GhassaeiLinkage()
    {
    	setDefault();
    	_C = new double[] {0,0};
    	_D = new double[] {0,0};
    	_E = new double[] {0,0};
    	_F = new double[] {0,0};
    	_G = new double[] {0,0};
        update();
    }

    public void setDefault()
    {
        _Ay = 53*Math.sin(.085);
        _Bx =-53*Math.cos(.085);
        _AC = 26;
        _BD = _BE = _BF = 77;
        _EG = _FG = 75; // links to foot hinge at G
        _CD = _CF = 56; // lenfths of linkages to crank arm
        _DE = _BE - _BD*Math.cos(2.97); // defines fixed angle rocker anchored at fixed node B
        _theta = 0;
    }

    public void flip() { _Bx *= -1; }
    
    // increase/decrease current size by given scale factor
    public void scale(double s)
    {
        _Bx *= s;
        _Ay *= s;
        _AC *= s;
        _BD *= s;
        _BE *= s;
        _BF *= s;
        _EG *= s;
        _FG *= s;
        _CD *= s;
        _CF *= s;
        _DE *= s;
    }

    public double check() {
    	// code to check realizability of geometry.
    	// return >1 for HOW unreasonable the geometry is.
    	return(1.0);
    }
    public double undesirable() {
    	double d = 0;
    	return d;
    }

    
    public double[] getPos(char node)
    {
        double[] p = {0,0};
        switch(node)
            {
            case 'A': p[1] = _Ay; break;
            case 'B': p[0] = _Bx; break;
            case 'C': p=_C; break;
            case 'D': p=_D; break;
            case 'E': p=_E; break;
            case 'F': p=_F; break;
            case 'G': p=_G; break;
            default: System.err.print(node);
                System.err.println(" is not a valid node name [A..G]"); 
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
        for (int i=0; i < nSteps; i++)
            {
                update(2 * Math.PI * i / nSteps);
                for (char node = 'A'; node <= 'G'; node++)
                    {
                        double[] a = getPos(node);
                        if (node != 'A') f.print('\t');
                        f.format("%.3f %.3f",a[0],a[1]);
                    }
                f.println();
            }
    }

    public void print(PrintStream f)
    {
        f.format("_Bx=%.3f;%n_Ay=%.3f;%n",_Bx,_Ay);
        f.format("_AC=%.3f;%n_BD=%.3f;%n_BE=%.3f;%n_BF=%.3f;%n",_AC,_BD,_BE,_BF);
        f.format("_CD=%.3f;%n_CF=%.3f;%n_DE=%.3f;%n_EG=%.3f;%n_FG=%.3f;%n",
                 _CD, _CF, _DE, _EG, _FG);
    }

    // compute all node positions given current linkage lengths, fixed points, and crankshaft angle
    public void update()
    {
        _C[0] = _AC * Math.cos(_theta);
        _C[1] = _AC * Math.sin(_theta) + _Ay;
        double[] B = {_Bx,0};
        try {
            if (_Bx > 0)
            {
                _D = triVertex(_C,_CD, B,_BD);
                _E = triVertex(_D,_DE, B,_BE);
                _F = triVertex( B,_BF,_C,_CF);
                _G = triVertex(_E,_EG,_F,_FG);

            } else {
                _D = triVertex( B,_BD,_C,_CD);
                _E = triVertex( B,_BE,_D,_DE);
                _F = triVertex(_C,_CF, B,_BF);
                _G = triVertex(_F,_FG,_E,_EG);
            }
        }
        catch(Exception e) {
        	//System.err.println(e.getMessage());
        	_G[0] = _G[1] = 0; // show foot at imposible location for err
        }
    }

    public void setState(double[] x) {
        //_AC = _crankLen;   // assume _AC is a constant w.r.t. state
        _Ay = x[0];
        _Bx = x[1];
        _BD = x[2];
        _BE = x[3];
        _BF = x[4];
        _CD = x[5];
        _CF = x[6];
        _DE = x[7];
        _EG = x[8];
        _FG = x[9];
    }
    public double[] getState() {
        double[] x = new double[10];
        x[0] = _Ay;
        x[1] = _Bx;
        x[2] = _BD;
        x[3] = _BE;
        x[4] = _BF;
        x[5] = _CD;
        x[6] = _CF;
        x[7] = _DE;
        x[8] = _EG;
        x[9] = _FG;
        return x;
    }
}
