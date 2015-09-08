/**
 * $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/tests/DumpOrbit.java $
 * $Id: DumpOrbit.java 69 2013-05-15 14:41:25Z aaron $
 * 
 */

/**
 * @author aaron
 *
 */

package com.boim.walker.tests;
//import java.util.Arrays;
import  com.boim.walker.*;

public class DumpOrbit {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		WalkerLinkage a;
		String typ = (args.length>0) ? args[0] : "Jansen";
		double[] s = {0};
		if (args.length>6) {
			s = new double[args.length-1];
			for (int i=0; i < s.length; i++) s[i] = Double.parseDouble(args[i+1]);
		}
		if (typ.equalsIgnoreCase("Klann")) {
			KlannLinkage  kl = new KlannLinkage();
			kl.setOpt2();
			if (s.length==12)
				kl.setState(s);
			a=kl;
		} else if (typ.equalsIgnoreCase("Ghassaei")) {
			GhassaeiLinkage gl = new GhassaeiLinkage();
			if (s.length==10)
				gl.setState(s);
			a = gl;
		} else {
			JansenLinkage jl = new JansenLinkage();
			if (s.length==12)
				jl.setState(s);
			a=jl;
		}
		a.printOrbitFull(96, System.out);
		a.flip();
		a.printOrbitFull(96, System.out);
	}
}
