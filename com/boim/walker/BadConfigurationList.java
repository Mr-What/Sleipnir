// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/BadConfigurationList.java $
// $Id: BadConfigurationList.java 221 2013-09-09 13:23:09Z aaron $
//
// Maintain a (persistent) list of bad/illegal linkage configurations
package com.boim.walker;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.FileOutputStream;

import java.io.PrintStream;
import com.boim.util.PointNode;

public class BadConfigurationList {
    protected PointNode _badTree;
    protected String _fNam;  // name of persistent back-up file
    protected PrintStream _badStream;
    protected double _fuzz;
    protected int _pointDim;
    
    public BadConfigurationList() { _badStream = System.err; 
        _fNam = "UndefinedBadList.dat";
        _fuzz = .0001;
	    _pointDim = -1;  // dimension of points yet to be defined
    }
    
    public void setFuzz(double f) { _fuzz = f; }
    
    public static double[] parseLine(String line) {
        // parse line into array of doubles.  return null/zero-length array for error
        String [] ele = line.split("[ \t,]");
        double[] a = new double[ele.length];
        for (int i=0; i < ele.length; i++)
            a[i] = Double.parseDouble(ele[i]);
        return a;
    }
 
    // return 0 or error code
    public int load(String fNam) {
        // add all elements in fNam to current _badList
        try {
            BufferedReader br = new BufferedReader(new FileReader(fNam));
            String line;
            int lineNum = 0;
            while ((line = br.readLine()) != null) {
                double[] a = parseLine(line);
                if ((_pointDim < 0) && (a.length > 0))
                    _pointDim = a.length;
                if (a.length == _pointDim) {
                    if (_badTree == null)
                        _badTree = new PointNode(a);
                    else
                        //addSilent(a);
                        _badTree.add(a,_fuzz);
                } else {
                    System.err.printf("Cannot add %d dimensional vector to a %d dimensional tree\n\t%s line %d\n",
                            a.length,_pointDim,fNam,lineNum);
                }
                lineNum++;
                if (lineNum%1000==0) 
                    System.err.printf("%d lines parsed\r", lineNum);
            }
            br.close();
        } catch (IOException e) {
            e.printStackTrace();
        } 

        // re-open this file for append
        try {
            FileOutputStream fos = new FileOutputStream(fNam, true);
            _badStream = new PrintStream(fos);
        } catch (IOException e) {
            e.printStackTrace();
            System.err.println("Using stderr for log");
            _badStream = System.err;
        }
        return 0;
    }
    
    public int add(double[] a) {
        if (_badTree==null) {
            _badTree = new PointNode(a); return 0; }
        if (closest(a) < _fuzz)
            return 1;
        _badTree.add(a);
        PointNode.print("%.3f", a, _badStream);
        return 0;
    }

    public int addSilent(double[] a) {
        //if (_badTree==null) {
        //    _badTree = new PointNode(a); return 0; }
        if (closest(a) < _fuzz)
            return 1;
        _badTree.add(a);
        //PointNode.print("%.3f", a, _badStream);
        return 0;
    }
    
    public double closest(double[] a) {
        return((_badTree==null)?9e19:_badTree.closest(a,9e19));
    }
    
    public void dump(String outFileName) {
        PrintStream os;
        try {
            FileOutputStream fos = new FileOutputStream(outFileName);
            os = new PrintStream(fos);
            dump(_badTree,os);
        } catch (IOException e) {
            e.printStackTrace();
            System.err.print("Unable to dump BadConfigurationList to \"");
            System.err.print(outFileName);
            System.err.println("\".");
        }
    }
    static public void dump(PointNode a, PrintStream os) {
        PointNode.print("%.3f", a.x, os);
        if (a.lt != null)
            dump(a.lt,os);
        if (a.ge != null)
            dump(a.ge,os);
        
    }
}
