/**
 * $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/tests/plotJansen.java $
 * $Id: plotJansen.java 400 2014-02-21 00:14:43Z mrwhat $
 * 
 */

/**
 * @author aaron
 *
 */

package com.boim.walker.tests;
//import java.util.Arrays;
import  com.boim.walker.*;

public class plotJansen {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		JansenLinkage a = new JansenLinkage();
		a.plotOrbit(128,2,"jansenOrbit.svg",null);
		a.plotOrbitAnim(3,"D%03d.svg");
	}
}
