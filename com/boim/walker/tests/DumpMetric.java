/**
 * $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/tests/DumpMetric.java $
 * $Id: DumpMetric.java 60 2013-05-12 17:38:06Z aaron $
 * 
 */

/**
 * @author aaron
 *
 */

package com.boim.walker.tests;
//import java.util.Arrays;
import java.io.*;
import  com.boim.walker.*;

public class DumpMetric {

    /**
     * @param args
     */
    public static void main(String[] args) {
        WalkerLinkage a;
        String typ = (args.length>0) ? args[0] : "Jansen";
        double[] s = {0};
        if (args.length==13) {
            s = new double[12];
            for (int i=0; i < 12; i++) s[i] = Double.parseDouble(args[i+1]);
        }
        
        
        if (typ.equalsIgnoreCase("Klann")) {
            KlannLinkage  kl = new KlannLinkage();
            kl.setOpt2();
            if (s.length==12)
                kl.setState(s);
            a=kl;
        } else {
            JansenLinkage jl = new JansenLinkage();
            if (s.length==12)
                jl.setState(s);
            a=jl;
        }
        
        WalkerMetric b = new WalkerMetric(a);
        double score = b.metric(b.getState());
        //a.print(System.out);
        System.out.format("%.6g %s%n",score,b.desc);

        PrintStream out;
        try {out = new PrintStream(new File("orbit.dat"));}
        catch(Exception e){out = System.out;}
        a.printOrbitFull(96, out);
        a.flip();
        a.printOrbitFull(96, out);
        out.close();

        
    }
}
