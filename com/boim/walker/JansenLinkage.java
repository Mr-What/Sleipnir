// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/JansenLinkage.java $
// $Id: JansenLinkage.java 412 2014-02-26 16:24:47Z mrwhat $

package com.boim.walker;
import java.io.*;
import com.boim.util.*;

public class JansenLinkage extends WalkerLinkage {
    public double _Bx;  // location of fixed node B on x axis (usually negative)
    public double _Ay;  // location of crank center on y axis (usually positive)
    public double _AC;  // crank-arm length
    public double _BD, _BE, _BH; // linkage lengths to fixed node B
    public double _CD, _CH; // lenfths of linkages to crank arm
    public double _DE, _EF, _FG, _FH, _GH; // other linkage lengths

    private double[] _C, _D, _E, _F, _G, _H;  // node positions

    public JansenLinkage()
    {
    	setDefault();
    	_C = new double[] {0,0};
    	_D = new double[] {0,0};
    	_E = new double[] {0,0};
    	_F = new double[] {0,0};
    	_G = new double[] {0,0};
    	_H = new double[] {0,0};
    	//_badList.load("JansenBadList.dat");
        update();
    }

    public void setDefault()
    {
        /* Jansen's favorite, as published
        _Bx = -38;
        _Ay = 7.8;
        _AC = 15;
        _BD = 41.5;
        _BE = 40.1;
        _BH = 39.3;
        _CD = 50;
        _CH = 61.9;
        _DE = 55.8;
        _EF = 39.4;
        _FG = 65.7;
        _FH = 36.7;
        _GH = 49;
        */
        
        _AC = 17.5;
        // My favorite, so far, as found from my optimizer
        // This one has rounder, smoother steps, and seems
        // to be fairly robust to linkage lock
        /*
        _Ay=6.1;  _Bx=-48; 
        _BH=43.2; _EF=46.35;
        _CD=59;   _CH=73.2;
        _BD=48.6; _BE=46.7; _DE=65.4;
        _FG=77;   _FH=41.4; _GH=56.2;
         */
        
        setCfgD();
        _theta = 0;
    }

    public void setCfgD()
    {
        
        _AC = 17.5;
        
        // Configuration "D", favorite as of 130909, for AC=17.5
        _Ay =  1.38; _Bx = -51.33;
        _BD = 48   ; _BE = 46.23; _BH = 44.2 ;
        _CD = 59.79; _CH = 73.6 ; _DE = 67.47;
        _EF = 47.47; _FG = 77.51;
        _FH = 41.63; _GH = 54.86;

        _theta = 0;
    }

    public void flip() { _Bx *= -1; }
    
    public void setOpt1() {
    	// seeded opt with default, and got:
    	_Bx=-45.570;
    	_Ay=7.146;
    	_AC=17.500;
    	_BD=49.872;
    	_BE=33.472;
    	_BH=48.301;
    	_CD=59.833;
    	_CH=76.936;
    	_DE=69.001;
    	_EF=48.221;
    	_FG=78.090;
    	_FH=42.482;
    	_GH=50.628;
  /*  	
    	// seeded with above, got 1.16e18
    	_Bx=-42.013;
    	_Ay=7.904;
    	_AC=17.500;
    	_BD=51.584;
    	_BE=31.930;
    	_BH=51.379;
    	_CD=43.823;
    	_CH=76.623;
    	_DE=76.493;
    	_EF=34.393;
    	_FG=83.158;
    	_FH=33.320;
    	_GH=55.618;
    	
    	// seeded with above, got 3.6e19
    	_Bx=-40.401;
    	_Ay=9.096;
    	_AC=17.500;
    	_BD=50.204;
    	_BE=32.356;
    	_BH=51.437;
    	_CD=42.862;
    	_CH=75.353;
    	_DE=76.328;
    	_EF=34.954;
    	_FG=83.112;
    	_FH=32.721;
    	_GH=56.818;
    	
    	// seeded with above, 2.16e20
    	_Bx=-41.051;
    	_Ay=9.312;
    	_AC=17.500;
    	_BD=50.203;
    	_BE=32.282;
    	_BH=51.058;
    	_CD=43.050;
    	_CH=75.663;
    	_DE=76.370;
    	_EF=35.113;
    	_FG=83.085;
    	_FH=32.406;
    	_GH=56.979;
*/
    }
    // increase/decrease current size by given scale factor
    public void scale(double s)
    {
        _Bx *= s;
        _Ay *= s;
        _AC *= s;
        _BD *= s;
        _BE *= s;
        _BH *= s;
        _CD *= s;
        _CH *= s;
        _DE *= s;
        _EF *= s;
        _FG *= s;
        _FH *= s;
        _GH *= s;
    }

/*
    public double check() {

    	// code to check realizability of geometry.
    	// return >1 for HOW unreasonable the geometry is.

        // NORMALIZED distance to closest "bad" configuration
    	double dist = (_badList==null)?1.0:
    	    _badList.closest(getState()) / _badListThresh;
    	if (dist >= 1.0)
           return(1.0);
        if (dist < 1e-4) return(1e8);
        return(1.0/(dist*dist));
    }
*/
    public double undesirable() {
    	double d = 0;
    	// Give a number (in cm... basically) showing how far
    	// out of "desirable" some node locations are at this angle

    	// If foot crosses axis, this is bad.
    	double x = _G[0];
    	if (_Bx > 0) x = -x;
    	x += 2;
    	if (x > 0)
    		d += x;
    
    	// If foot gets higher than any node, this is undesirable.
    	// most often occurs with H and F
    	x = _G[1] - _F[1];
    	if (x > 0)
    		d += x;
    	x = _G[1] - _H[1];
    	if (x > 0)
    		d += x;
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
        for (int i=0; i < nSteps; i++)
            {
                update(2 * Math.PI * i / nSteps);
                for (char node = 'A'; node <= 'H'; node++)
                    {
                        double[] a = getPos(node);
                        if (node != 'A') f.print('\t');
                        f.format("%.3f %.3f",a[0],a[1]);
                    }
                f.println();
            }
    }
    
    // sets up a plot group in SVG, which needs an end() when you are done.
    // Assumes that overall SVG plot was "scale" pixels/unit in the cartesian Jansen configuration plot region
    static public void setWalkerGrid(SVGPlot p, int flags) {
    	p.desc("Plot coordinates and grid for standard Jansen Walker configuration plots");
        p.startg("style=\"fill:none; stroke-width:1; stroke-linejoin:miter; stroke-linecap:butt; stroke:magenta\" transform=\"scale(1,-1)\"");
    	if ((flags&1)==1) {
    	   p.startpath("stroke=\"black\" stroke-width=\".6\" stroke-dasharray=\"2,3\"");
    	   p.pM(-150+4,0); p.pl(300,0);
    	   p.pM(0,-125-1); p.pl(0,200); p.end();
    	}
    	if ((flags&2)==2) {
    		p.startpath("stroke=\"rgb(0,180,0)\" stroke-width=\"0.2\" stroke-dasharray=\"2,4,1,4\"");
    		p.pM(-150,  50); p.pl(300,0);
    		p.pM(-150, -50); p.pl(300,0);
    		p.pM(-150,-100); p.pl(300,0);
    		p.pM(-100,-125); p.pl(0,200);
    		p.pM( -50,-125); p.pl(0,200);
    		p.pM(  50,-125); p.pl(0,200);
    		p.pM( 100,-125); p.pl(0,200);
    		p.end();
    	}
    	// now in walker grid coordinates, end this group when done
    	p.circle(0,0,2);
    	//text(-100,60,0,10,"red","Is this flipped?");
    }
    
    static public void plotJansen(SVGPlot p, float ay, float bx, float[][] node,
            String color, float lineWidth, int flags) {
    	p.desc("Walking Linkage Position instance");
    	double dy = node[0][1] - ay;
    	float ac = (float)Math.sqrt(dy*dy + (double)node[0][0]*node[0][0]);
    	if ((flags&1)==1) p.circle(0,ay,ac,"rgb(200,200,0)",.5f,"none");
    	p.startpath(String.format("stroke=\"%s\" stroke-width=\"%.1f\" stroke-linejoin=\"round\" stroke-linecap=\"round\"",color,lineWidth));
    	if ((flags&4)==4) { // do not draw AC
            p.pM(node[0][0],node[0][1]);
    	} else { // draw AC too
            p.pM(0,ay);
            p.pL(node[0][0],node[0][1]); 	    
    	}
    	for (int i=1; i<=5; i++) p.pL(node[i][0],node[i][1]);
    	p.pL(node[0][0],node[0][1]);  // return to C
    	p.pM(node[3][0],node[3][1]);  p.pL(node[5][0],node[5][1]); // FH
    	p.pM(node[1][0],node[1][1]);  p.pL(bx,0);  p.pL(node[5][0],node[5][1]); //DB,BH
    	p.pM(node[2][0],node[2][1]);  p.pL(bx,0);  //EB
    	p.end();
    	if ((flags&2)==2) {
    		int pt = 10;  // font points
    		String c = "rgb(255,0,255)"; // color
    		p.text(node[0][0]+2,node[0][1]  ,0,pt,c,"C");
    		p.text(node[1][0]  ,node[1][1]+5,0,pt,c,"D");
    		p.text(node[2][0]-8,node[2][1]+3,0,pt,c,"E");
    		p.text(node[3][0]-9,node[3][1]-2,0,pt,c,"F");
    		p.text(node[4][0]-5,node[4][1]-9,0,pt,c,"G");
    		p.text(node[5][0]+3,node[5][1]-5,0,pt,c,"H");
    		p.text(-10,ay-3,0,pt,c,"A");
    		p.text(bx+5 ,0,0,pt,c,"B");
        	p.circle(0,ay,2,"black",.3f,"none");
        	p.circle(bx,0,3,"black",.8f,"none");
    	}
    }
    
    public float [][] nodeLocations() {
    	float [][] x = {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}};
        int j=0;
        for (char node = 'C'; node <= 'H'; node++, j++) {
            double [] y = getPos(node);
            x[j][0] = (float)y[0]; x[j][1] = (float)y[1];
        }
        return x;
    }

    public void plotOrbit(int nSteps, int plotRate, String fileName, String[] desc)
    {
    	SVGPlot p = new SVGPlot(fileName, 4*300, 4*200,-150,-75,300,200);
        setWalkerGrid(p, 3);
    	float [][] x = {{0,0},{0,0},{0,0},{0,0},{0,0},{0,0}};
        float [][] G = new float[nSteps][];
        float [][] F = new float[nSteps][];
    	int i;
        for (i=0; i < nSteps; i++) {
        	for (int k=0; k < 2; k++) {
        		flip();
                update(2 * Math.PI * i / nSteps);
                x = nodeLocations();
                if ((i % plotRate)==0)
                	plotJansen(p,(float)_Ay,(float)_Bx,x,"rgb(0,255,255)",.3f,4);
            }
        	G[i] = x[4];  // store foot locations to hilight after all configs are plotted.
        	F[i] = x[3];  // store knee locations too.  they may be interesting to plot as well
        }
        for (i=0; i < nSteps; i++) {
            p.circle( G[i][0], G[i][1],.6f,"rgb(0,200,0)",.5f,"yellow");
            p.circle(-G[i][0], G[i][1],.6f,"rgb(0,200,0)",.5f,"yellow");
            p.circle( F[i][0], F[i][1],.4f,"#AA6600",.2f,"green");
        }
        
        // plot a random position in bold
    	double ang = 2 * Math.PI * Math.random();
    	update(ang);
    	plotJansen(p,(float)_Ay,(float)_Bx,nodeLocations(),"rgb(0,0,180)",1.2f,1);    flip(); update(ang);
    	plotJansen(p,(float)_Ay,(float)_Bx,nodeLocations(),"rgb(0,0,180)",1.2f,0);
    	flip();
    	
    	if (desc != null) {
            if (desc[0] != null) p.text(-140, 70, 4, "red", desc[0]);
            if (desc[1] != null) p.text(-140, 66, 3, "red", desc[1]);
    	}
    	
//    	String cfg = String.format(
//"AC=%.1f;Ay=%.3f;Bx=%.3f;BD=%.3f;BE=%.3f;BH=%.3f;CD=%.3f;CH=%.3f;DE=%.3f;EF=%.3f;FG=%.3f;FH=%.3f;GH=%.3f;",
//_AC,_Ay,_Bx,_BD,_BE,_BH,_CD,_CH,_DE,_EF,_FG,_FH,_GH);
    	double[] s = getState();
    	String cfg = String.format("%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f",
    	        s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9],s[10],s[11]);
    	p.text(-148,-123, 3, "rgb(0,0,180)", cfg);

        p.finish();
    }

    public void plotOrbitAnim(int dAng, String fileNameFmt) {
    	for (int ang=0; ang < 360; ang+=dAng) {
    	    String fNam = String.format(fileNameFmt,ang/dAng);
    		SVGPlot p = new SVGPlot(fNam, 900, 600,-150,-75,300,200);
    		setWalkerGrid(p, 3);
    		double a =	(ang+90) * Math.PI / 180.;
    		p.text(-140, 65, 0, 5, "magenta", String.format("%3d",ang % 360));
    		update(a);
        	plotJansen(p,(float)_Ay,(float)_Bx,nodeLocations(),"rgb(0,0,200)",1.5f,1);   flip(); update(a);
        	plotJansen(p,(float)_Ay,(float)_Bx,nodeLocations(),"rgb(0,0,200)",1.5f,0);   a += Math.PI;  update(a);
        	plotJansen(p,(float)_Ay,(float)_Bx,nodeLocations(),"rgb(200,0,0)",1.5f,0);   flip(); update(a);
        	plotJansen(p,(float)_Ay,(float)_Bx,nodeLocations(),"rgb(200,0,0)",1.5f,0);
        	p.finish();
    	}
    }

    public void print(PrintStream f)
    {
        f.format("_Bx=%.3f;%n_Ay=%.3f;%n",_Bx,_Ay);
        f.format("_AC=%.3f;%n_BD=%.3f;%n_BE=%.3f;%n_BH=%.3f;%n",_AC,_BD, _BE, _BH);
        f.format("_CD=%.3f;%n_CH=%.3f;%n_DE=%.3f;%n_EF=%.3f;%n_FG=%.3f;%n_FH=%.3f;%n_GH=%.3f;%n",
                 _CD, _CH, _DE, _EF, _FG, _FH, _GH);
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
                _H = triVertex( B,_BH,_C,_CH);
                _F = triVertex(_E,_EF,_H,_FH);
                _G = triVertex(_F,_FG,_H,_GH);
            } else {
                _D = triVertex( B,_BD,_C,_CD);
                _E = triVertex( B,_BE,_D,_DE);
                _H = triVertex(_C,_CH, B,_BH);
                _F = triVertex(_H,_FH,_E,_EF);
                _G = triVertex(_H,_GH,_F,_FG);
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
        _BH = x[4];
        _CD = x[5];
        _CH = x[6];
        _DE = x[7];
        _EF = x[8];
        _FG = x[9];
        _FH = x[10];
        _GH = x[11];
    }
    public double[] getState() {
        double[] x = new double[12];
        x[0] = _Ay;
        x[1] = _Bx;
        x[2] = _BD;
        x[3] = _BE;
        x[4] = _BH;
        x[5] = _CD;
        x[6] = _CH;
        x[7] = _DE;
        x[8] = _EF;
        x[9] = _FG;
        x[10]= _FH;
        x[11]= _GH;
        return x;
    }
    
    // check how far links are from bumping into each other.
    // for now, just dist from CH to B axle
    public double clearanceDistance() {
        double chx = _H[0] - _C[0];  // vector from C to H
        double chy = _H[1] - _C[1];
        double cbx = _Bx - _C[0];    // vector from C to B axle center
        double cby =     - _C[1];
        double chxHat = chx/_CH;
        double chyHat = chy/_CH;
        double dp = cbx*chxHat + cby*chyHat;  // dot prod of cb with chHat == projection dist on ch
        double cpx = _C[0] + dp * chxHat;  // closest point on ch to axle
        double cpy = _C[1] + dp * chyHat;
        cpx -= _Bx;  // cp now vector from closest point to B axis
        double d = cpx*cpx + cpy*cpy;
        d = Math.sqrt(d);
        return d;
    }
}
