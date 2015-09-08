// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/walker/tests/PruneBadConfigurationList.java $
// $Id: PruneBadConfigurationList.java 221 2013-09-09 13:23:09Z aaron $
// Loading a PointNode tree does some pruning on load (by _fuzz).
// Loading, then dumping a tree should prune some close entries
package com.boim.walker.tests;

//import java.io.*;
import com.boim.walker.*;
//import com.boim.util.*;
//import java.util.*;

public class PruneBadConfigurationList {
	
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: PruneBadConfigurationList fuzz inFileName outFileName");
            return;
        }
        double fuzz = Double.parseDouble(args[0]);
        String inFileName = args[1];
        String outFileName = args[2];
        
        BadConfigurationList bl = new BadConfigurationList();
        bl.setFuzz(fuzz);
        bl.load(inFileName);
        bl.dump(outFileName);
    }
}
