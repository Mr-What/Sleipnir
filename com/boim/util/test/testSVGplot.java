// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/util/test/testSVGplot.java $
// $Id: testSVGplot.java 368 2014-01-30 15:31:35Z mrwhat $
//
// Low-level utility to print SVG plot files
package com.boim.util.test;
//import java.io.*;
//import java.util.Stack;
import com.boim.util.*;
//import java.util.*;

public class testSVGplot {
	
    public static void main(String [] args) {
    	SVGPlot p = new SVGPlot("testGrid.svg", 300, 200);
    	p.setWalkerGrid(1);
//	0.000 6.082     -47.616 0.000
    	//16.168 12.779   -32.426 46.117  -91.096 17.052  -72.729 -25.327 -42.951 -96.299 -34.161 -40.877
    	float[][] node = {{16.168f,12.779f},{-32.426f,46.117f},{-91.096f,17.05f},{-72.729f,-25.327f},{-42.951f,-96.299f},{-34.161f,-40.877f}};
    	p.plotJansen(6.082f, -47.616f, node, true);
    	p.finish();
    }
}
