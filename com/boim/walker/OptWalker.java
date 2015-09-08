// Run simple test on simplex optimizer
package com.boim.walker;

import java.io.*;
import com.boim.optimize.*;
import com.boim.util.*;
import java.util.*;

public class OptWalker {
	//private BufferedWriter octIn;
    private static Random rand;
	
    public static void main(String[] args) {
    	WalkerLinkage linkage;
    	String linkageType = (args.length > 0) ? args[0] : "Klann";
    	String plotCmd;
    	if (linkageType.equals("Klann")) {
    		KlannLinkage l = new KlannLinkage();
    		l.scale(17.5/l._AC);  // scale to standard crank arm.
    		//l.setOpt2();
    		linkage = l;
    		plotCmd = "plotKlannConfig";
    	} else {
    		JansenLinkage l = new JansenLinkage();
            //l.setOpt1();
    		l.scale(17.5/l._AC);
    		linkage = l;
    		plotCmd = "plotJansenConfig";
    	}
    	WalkerMetric a = new WalkerMetric(linkage);
        double[] x = a.getState();
        double[] seedState = x.clone();
        
        System.out.println("input Configuration :");
        a._linkage.print(System.out);

        PrintStream maximaOut;
        try {maximaOut = new PrintStream(new File("maxima.dat")); }
        catch(Exception e){ maximaOut = System.out; }
        

        // Set up an octave process for plotting
        //       (Set oct to null to disable plotting)
        ProcessPipe oct = new ProcessPipe("octave");
        if (oct != null) {
            oct.send("cd ~/Jansen/trunk\npwd\n");
            oct.printResp(System.err);
        }

        BadConfigurationList reported = new BadConfigurationList();
        double reportedThresh = 0.5;  // do not report if this close to a previous report
        
        NelderMeadSimplex b = new NelderMeadSimplex();
        b._maxEval = 99999;
        b._expand = 1.7;  // expand a little slower, perhaps we'll do it more often
        //b._startStep = 400;  // smaller starting step
        double searchStep = 400;  // initial step multiplier to use for large-scale search
        double checkStep = 5;  // initial step multiplier used to re-check answers
        double recheckThresh = 0.2;  // close enough on answer re-check, euclidean dist linkage lengths
        
        double best=1;
        int n=0;
        int nSkipped=0;
        boolean reset = false;  // backdoor to reset linkage when debugging
        double changeProb = 0.16;
        double stepSD = .7;
        double gravity = 0.2;  // value (0..1) for how much attraction there is to seed solution in search
        double scale = 0.8;  // scale down "max" by this for every solution, to report after degenerate high score
        int nRechecks = 5;  // number of times to verify an optimization
        int nFailedRechecks = 0;
        while(true) {
            x = randomize(x,changeProb,stepSD);

        	// make sure a configuration is (locally) maximal before reporting it
        	int nCheck = 0;
        	double score = 0;
        	double currentMaxima = 0;
        	while (nCheck < nRechecks) {
                b._startStep = searchStep;  // initial step multiplier to use for large-scale search
                x = b.optimize(a,x);
                score = a.metric(x);
                if (Double.isNaN(score)) {
                    reset = true;
                    score=0;
                }
                System.out.format("%g/%g%n",score,best);
                if (score > currentMaxima) {
                    currentMaxima = score;
                    double checkDist = 0;
                    double[] x0 = x.clone();
                    b._startStep = checkStep;  // small step to use for re-check search
                    while ((nCheck <= nRechecks) && (checkDist < recheckThresh)) {
                        x = randomize(x0,changeProb,0.05);  // very small random tweak for re-check
                        x = b.optimize(a,x);
                        checkDist = PointNode.dist(x,x0);
                        nCheck++;
                    }
                    if (nCheck < nRechecks) {// re-check failed
                        nCheck=0;
                        nFailedRechecks++;
                        currentMaxima=0;
                    }
                }
                best *= scale;  // let this shrink to "reset" occationally
                best=1; // show every "optimim", for now
                if (reset) { 
                    reset=false;
                    a._linkage.setDefault();
                    x = a.getState();
                    best = 0.001;
                    currentMaxima=0;
                }
     	    }

            //a._linkage.print(System.out);
            //double score = a.metric(x);
        	// print out EVERY checked maxima, but only do on-the-fly plot if it was a recent "best"
            ////if (score > best) {
        	maximaOut.printf("%.6g  ", score);
        	for (int i=0; i < x.length; i++) maximaOut.printf(" %.3f", x[i]);
        	maximaOut.println(); maximaOut.flush();
        	if (score > best) {
        	    best = score;

        	    // try to plot (set oct to null for no no plotting)
        	    if (oct != null) {
        	        double dPrev = reported.closest(x);
        	        if (dPrev > reportedThresh) {
        	            reported.add(x);
        	            oct.send(String.format("%s([%.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f],%d)%n",
        	                plotCmd,x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10],x[11],n));
        	            oct.printResp(System.err,"cmdOut");  // this does not wait til "done", but does keep us from getting more than 1 plot ahead
        	        } else
        	            nSkipped++;
        	    }
        	    n++;
        	}
        	
        	// had some trouble with adjustable scale rate, abandoned this:
        	//scale = 4+Math.log10(score);
        	//if (scale < 1) scale=1;
        	//scale /= Math.log10(best);
        	if (scale > .95) scale=.95;
        	if (scale < 0.001) scale = 0.001;
            best *= scale;  // let this shrink to "reset" occationally

        	// scoot towards seed so we don't get too crazy
            for (int i=0; i < x.length; i++) x[i] = gravity*seedState[i] + (1-gravity)*x[i];
            
            // dump out orbit for diagnostics and plotting.
            /*
            PrintStream out;
            try {out = new PrintStream(new File("orbit.dat"));}
            catch(Exception e){out = System.out;}
    	    a._linkage.printOrbitFull(96, out);
		    a._linkage.flip();
		    a._linkage.printOrbitFull(96, out);
		    out.close();
		    */
        }  // end while(true)
    }    // end main()

    /// add some random noise (gaussian) to a vector
    public static double[] randomize(double[] xx, double changeProb, double stepSD) {
        if (rand == null)
            rand = new Random(System.currentTimeMillis());

        double[] x = xx.clone();
        for (int i=0; i < x.length; i++) {
            if (rand.nextDouble() < changeProb) {
                x[i] += stepSD*rand.nextGaussian();
            }
        }
        return x;
    }

} // end OptWalker class

