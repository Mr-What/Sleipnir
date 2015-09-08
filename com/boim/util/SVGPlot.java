// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/util/SVGPlot.java $
// $Id: SVGPlot.java 413 2014-02-28 16:44:50Z mrwhat $
//
// Low-level utility to print SVG plot files
package com.boim.util;
import java.io.*;
import java.util.Stack;
//import java.util.*;

public class SVGPlot {

	private Stack<String> _endSection;  // stack of end-of-block indicators needed to be output
	private PrintWriter _f;
	
	public int _scale;  // scale drawing up/down for easier display
	
    public SVGPlot(String fileName, float width, float height) {
        if (init(fileName)) return;
                
        _scale = 4;
        
        // write out SVG header here, and set page boundaries
        _f.println("<?xml version=\"1.0\" encoding=\"utf-8\"  standalone=\"no\"?>");
        _f.println("<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">");
        _f.printf("<svg width=\"%.1f\" height=\"%.1f\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">",
                width*_scale,height*_scale); _f.println();
        _endSection.push("</svg>");

        // some stuff which is hard-coded here now may want to soft-code later
        // fill background with a partially transparent shade
        desc("Shaded Background");
        _f.printf("<rect x=\"0\" y=\"0\" width=\"%.1f\" height=\"%.1f\" fill=\"#EEEECC\" fill-opacity=\"0.8\"/>",
                width*_scale,height*_scale); _f.println();
        
        //<g style="fill:none; stroke-width:4; stroke-linejoin:miter; stroke-linecap:butt; stroke:\"magenta\"">

    }

    private boolean init(String fileName) {
        _endSection = new Stack<String>();
        try {
            _f = new PrintWriter(fileName);
        } catch(Exception e) {
            e.printStackTrace();
            _f = null;
            return true;
        }
        return false;
    }

    // minimalist header
    public SVGPlot(String fileName, float width, float height,
                float x0, float y0, float viewWidth, float viewHeight) {
        if(init(fileName))return;
        
        // write out SVG header here, and set page boundaries
        _f.printf("<svg width=\"%.1f\" height=\"%.1f\" viewBox=\"%.1f %.1f %.1f %.1f\"\nxmlns=\"http://www.w3.org/2000/svg\"\npreserveAspectRatio=\"xMinYMin meet\">\n",
                width,height,x0,y0,viewWidth,viewHeight);
        _endSection.push("</svg>");

        // some stuff which is hard-coded here now may want to soft-code later
        // fill background with a partially transparent shade
        desc("Shaded Background");
        _f.printf("<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" fill=\"#EEEECC\" fill-opacity=\"0.8\"/>",
                x0,y0,viewWidth,viewHeight); _f.println();
    }
    
    public void desc(String d) {
    	_f.println();
    	_f.print("<desc>");
    	_f.print(d);
    	_f.println("</desc>");
    }
    
    public void startg(String args) {
    	_f.print("<g ");
    	_f.print(args);
    	_f.println(">");
    	_endSection.push("</g>");
    }
    
    // this is hard-coded.  should re-factor this out of base class some day...
    public void setWalkerGrid(int flags) {
    	desc("Plot coordinates and grid for standard Walker plots");
    	startg(String.format("style=\"fill:none; stroke-width:1; stroke-linejoin:miter; stroke-linecap:butt; stroke:magenta\" transform=\"translate(%.3f %.3f) scale(%d -%d)\"",
    			_scale*150.,_scale*75.,_scale,_scale));
    	if ((flags&1)==1) {
    	   startpath("stroke=\"black\" stroke-width=\".6\" stroke-dasharray=\"2,3\"");
    	   pM(-150+4,0); pl(300,0);
    	   pM(0,-125-1); pl(0,200); end();
    	}
    	if ((flags&2)==2) {
    		startpath("stroke=\"rgb(0,180,0)\" stroke-width=\"0.3\" stroke-dasharray=\"2,4,1,4\"");
    		pM(-150,  50); pl(300,0);
    		pM(-150, -50); pl(300,0);
    		pM(-150,-100); pl(300,0);
    		pM(-100,-125); pl(0,200);
    		pM( -50,-125); pl(0,200);
    		pM(  50,-125); pl(0,200);
    		pM( 100,-125); pl(0,200);
    		end();
    	}
    	// now in walker grid coordinates, end this group when done
    	circle(0,0,2);
    	//text(-100,60,0,10,"red","Is this flipped?");
    }
    
    public void text(float x, float y, float rot, int pt, String color, String msg) {
        startg(String.format("transform=\"translate(%.2f %.2f) rotate(%.2f)\"",x,y,rot));
        // font-family can be sans-serif, monospace, Arial, Verdana?, Helvetica
        _f.printf("<text x=\"0\" y=\"0\" fill=\"%s\" stroke-width=\"0.001\" font-family=\"Helvetica\" font-size=\"%d\" transform=\"scale(1,-1)\">%s</text>\n",
                color,pt,msg);
        end();
    }
    public void text(float x, float y, int pt, String color, String msg) {
        // font-family can be sans-serif, monospace, Arial, Verdana?, Helvetica
        _f.printf("<text x=\"%.1f\" y=\"%.1f\" fill=\"%s\" stroke-width=\"0.001\" font-family=\"Helvetica\" font-size=\"%d\" transform=\"scale(1,-1)\">%s</text>\n",
                x,-y,color,pt,msg);
    }
     
    public void plotJansen(float ay, float bx, float[][] node, boolean annotate) {
    	desc("Walking Linkage Position instance");
    	double dy = node[0][1] - ay;
    	float ac = (float)Math.sqrt(dy*dy + (double)node[0][0]*node[0][0]);
    	if (annotate) circle(0,ay,ac,"rgb(200,200,0)",.5f,"none");
    	startpath("stroke=\"rgb(0,0,180)\" stroke-width=\"2\" stroke-linejoin=\"round\" stroke-linecap=\"round\"");
    	pM(0,ay);
    	for (int i=0; i<=5; i++) pL(node[i][0],node[i][1]);
    	pL(node[0][0],node[0][1]);  // return to C
    	pM(node[3][0],node[3][1]);  pL(node[5][0],node[5][1]); // FH
    	pM(node[1][0],node[1][1]);  pL(bx,0);  pL(node[5][0],node[5][1]); //DB,BH
    	pM(node[2][0],node[2][1]);  pL(bx,0);  //EB
    	end();
    	if (annotate) {
    		int pt = 10;  // font points
    		String c = "rgb(255,0,255)"; // color
    		text(node[0][0]+2,node[0][1]  ,0,pt,c,"C");
    		text(node[1][0]  ,node[1][1]+5,0,pt,c,"D");
    		text(node[2][0]-8,node[2][1]+3,0,pt,c,"E");
    		text(node[3][0]-9,node[3][1]-2,0,pt,c,"F");
    		text(node[4][0]-5,node[4][1]-9,0,pt,c,"G");
    		text(node[5][0]+3,node[5][1]-5,0,pt,c,"H");
    		text(-10,ay-3,0,pt,c,"A");
    		text(bx+5 ,0,0,pt,c,"B");
        	circle(0,ay,2,"black",.3f,"none");
        	circle(bx,0,3,"black",.8f,"none");
    	}
    }

    public void circle(float x, float y, float r) { circle(x,y,r,"black",.2f,"none"); }
    public void circle(float x, float y, float r, String lineColor, float lineWidth, String fill) {
    	_f.printf("<circle cx=\"%.2f\" cy=\"%.2f\" r=\"%.2f\" stroke=\"%s\" stroke-width=\"%.2f\" fill=\"%s\" />",
    			x,y,r,lineColor,lineWidth,fill);
    	_f.println();
    }
    
    public void pM(float x, float y) { path('M',x,y); }
    public void pm(float x, float y) { path('m',x,y); }
    public void pL(float x, float y) { path('L',x,y); }
    public void pl(float x, float y) { path('l',x,y); }
    public void pZ() { _f.println('Z'); }
    public void path(char code, float x, float y) {
    	_f.printf("%c%.3f,%.3f",code,x,y);
    	_f.println();
    }

    public void startpath(String args) {
    	_f.print("<path ");
    	_f.print(args);
    	_f.print(" d='");
    	//_endSection.push("'></path>");
    	_endSection.push("' />");
    }
    
    public void end() {
    	if (_endSection.empty()) {
    		System.err.print("Attempt to end SVG section, but section stack is empty.");
    		return;
    	}
    	_f.print(_endSection.pop());
    	_f.println();
    }
    
    public void finish() {
    	while(!_endSection.empty()) end();
    	_f.close();  // may not be necessary if destructor/garbage collector does .close(), but try it here just in case
    }
}
