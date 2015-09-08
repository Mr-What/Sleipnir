/**
$URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/tests/AnimOrbit.java $
$Id: AnimOrbit.java 412 2014-02-26 16:24:47Z mrwhat $
@author aaron

Takes a standard state vector (for 17.5mm/cm crank arm) and animates
a walking cycle
*/

package com.boim.walker.tests;
import  com.boim.walker.*;

public class AnimOrbit {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length != 13) {
			System.err.printf("Usage : <AnimOrbit.main> outFileFormat Ay Bx BD BE BH CD CH DE EF FG FH GH\n\tas scaled for AC=17.5\n");
			return;
		}
		double[] s = new double[args.length-1];
		String outFileFmt = args[0];
		for (int i=0; i < s.length; i++) s[i] = Double.parseDouble(args[i+1]);
		JansenLinkage jl = new JansenLinkage();
		jl.scale(17.5/jl._AC);
		jl.setState(s);
		jl.plotOrbitAnim(3, outFileFmt);
	}
}
