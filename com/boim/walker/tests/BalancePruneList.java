/*
$URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/tests/BalancePruneList.java $
$Id: BalancePruneList.java 403 2014-02-21 18:02:16Z mrwhat $

Load a list of vectors, and write them back out in balanced order.
Prine any vectors which are very close to other vectors.
*/

package com.boim.walker.tests;

import java.io.BufferedReader;
//import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
//import java.io.PrintStream;
import java.util.*;

import com.boim.walker.BadConfigurationList;
import com.boim.walker.SplitList;

public class BalancePruneList {
	
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: PruneBadConfigurationList fuzz inFileName outFileName");
            return;
        }
        double fuzz = Double.parseDouble(args[0]);
        String inFileName = args[1];
        String outFileName = args[2];
        
        BadConfigurationList bl = new BadConfigurationList();
        double[][] a = loadList(inFileName);
        bl.setFuzz(fuzz);
        bl.load(outFileName);  // should be nothing to load, but establishes add log file for new balanced list
        LinkedList<double[][]> q = new LinkedList<double[][]>();
        q.add(a);
        //PrintStream os = openOutputStream(outFileName);
        while (q.size() > 0) {
            a = q.remove();
            if (a.length > 2) {
                SplitList sl = new SplitList(a);
                bl.add(sl.center);
                q.add(sl.a);
                q.add(sl.b);
            } else {
                for (int k=0; k < a.length; k++)
                    bl.add(a[k]);
            }
        }
        //if (os != System.out) os.close();
    }

    public static double[][] loadList(String inFileName){
        LinkedList<double[]> q = new LinkedList<double[]>();
        
        int pointDim = -1;
        try {
            BufferedReader br = new BufferedReader(new FileReader(inFileName));
            String line;
            int lineNum = 0;
            while ((line = br.readLine()) != null) {
                double[] a = BadConfigurationList.parseLine(line);
                if ((pointDim < 0) && (a.length > 0))
                    pointDim = a.length;
                if (a.length == pointDim) {
                    q.add(a);
                } else {
                    System.err.printf("Cannot add %d dimensional vector to a %d dimensional tree\n\t%s line %d\n",
                            a.length,pointDim,inFileName,lineNum);
                }
                lineNum++;
                if (lineNum%10000==0) 
                    System.err.printf("%d lines parsed\r", lineNum);
            }
            br.close();
        } catch (IOException e) {
            e.printStackTrace();
        } 
        
        double[][] b = q.toArray(new double[0][]);
        return b;
    }

/*
    public static void addCheck(double[] a, double fuzz, BadConfigurationList bl, PrintStream os) {
        double d = bl.closest(a);
        if (d > fuzz) {
            saveVector(a,os);
            bl.add(a);
        }
    }

    public static void saveVector(double[] a, PrintStream s) {
        String fmt0 = "%.3f";
        String fmt = '\t' + fmt0;
        s.printf(fmt0,a[0]);
        for(int i=1; i < a.length; i++) s.printf(fmt, a[i]);
        s.println();        
    }

    public static PrintStream openOutputStream(String outFileName) {
        PrintStream os;
        try {
            FileOutputStream fos = new FileOutputStream(outFileName);
            os = new PrintStream(fos);
        } catch (IOException e) {
            e.printStackTrace();
            System.err.print("Unable to write to \"");
            System.err.print(outFileName);
            System.err.println("\".");
            os = System.out;
        }
        return os;
    }
*/
}
