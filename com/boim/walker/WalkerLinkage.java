// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/WalkerLinkage.java $
// $Id: WalkerLinkage.java 401 2014-02-21 03:13:00Z mrwhat $
package com.boim.walker;

//import com.boim.walker.BadConfigurationList;

import java.io.*;

// Generic walker linkage base
public abstract class WalkerLinkage {
    public double _theta;
    //protected BadConfigurationList _badList;
    //protected double _badListThresh;

    public WalkerLinkage() { _theta=0;
        //_badList = new BadConfigurationList();
        //setBadThresh(2);  // penalize linkage if within this many mm(cm) of an unrealizable configuration
    }
    //public void setBadThresh(double t) {
    //	_badListThresh = t;
    //	_badList.setFuzz(t/20);
    //}
    abstract void setDefault();
    abstract void setState(double [] x);
    abstract double[] getState();
    //public void setOpt1();
    //public void setOpt2();
    //public void setOpt3();
    //abstract double check();  // returns penalty (>1) for how IMPOSSIBLE the geometry is
    abstract double undesirable();  // mesure of how "undesirable" the geometry is
    abstract void scale(double s);
    public double clearanceDistance() { return 1.0; } // polymorph this to measure how far things are from clanking
    public   void setTheta(double x) { _theta = x; }
    public abstract double[] getPos(char node);
    public abstract void printOrbit(int nSteps, PrintStream f);
    public abstract void printOrbitFull(int nSteps, PrintStream f);
    public abstract void print(PrintStream f);
    public abstract void update();
    public   void update(double theta) { _theta = theta; update(); }
    public abstract void flip(); // mirror linkage about Y axis
    
    // Find the vertex of a triangle at the given distances, from the given
    // other vertices, such that the cross product from the new vertex to the
    // first vertex, with the vector from the new vertex to the second vertex
    // is pointing in +Z
    public static double[] triVertex(double[] a, double ac, double[] b, double bc)
    {
        double dx = b[0]-a[0];  // vector from a to b
        double dy = b[1]-a[1];
        double d2 = dx*dx + dy*dy;
        double d  = Math.sqrt(d2); // dist between a and b

        // convert vector a->b to normalized direction from a to b
        dx /= d;
        dy /= d;

        // dist along (dx,dy) to the line connecting the two points on both
        //    circle radius ac about a and
        //    circle radius ab about b
        double da = (ac*ac - bc*bc + d2)/(2*d);

        // distance from midpoint between a and b to intersection
        if (da >= ac) throw(new ArithmeticException("Non-Physical Linkage"));
        double dp = Math.sqrt(ac*ac - da*da);

        // vector from a to mid-point between solution points
        double cx = da*dx;
        double cy = da*dy;

        // vector from a+(cx,cy) to solution points
        double px = -dp*dy;
        double py =  dp*dx;

        double[] c = {cx+px, cy+py};  //c-a

        // we want the solution where cross(b-a,c-a)>0
        double cz = dx*c[1] - dy*c[0]; // cross product, in Z direction
        if (cz > 0) {
            c[0] += a[0];
            c[1] += a[1];
        } else {
            c[0] = cx + a[0] - px;
            c[1] = cy + a[1] - py;
        }
        return c;
    }
}
