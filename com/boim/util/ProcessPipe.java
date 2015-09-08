// $URL: svn+ssh://mrwhat@ssh.boim.com/home/mrwhat/svn/Walker/trunk/com/boim/util/ProcessPipe.java $
// $Id: ProcessPipe.java 63 2013-05-13 13:09:13Z aaron $
//
// Spawn a process, and grab pipes to its stdin/stdout.
package com.boim.util;
import java.io.*;
//import java.util.*;

public class ProcessPipe {

    public Process _proc;
    public BufferedWriter _toProc;
    public BufferedReader _fromProc;
    private String _cmd;

    public ProcessPipe(String cmd) {
        try { _proc = Runtime.getRuntime().exec(cmd); }
        catch(Exception exc) {
            System.err.println("Error spawning process.");
            System.err.println(exc.getMessage());
            return;
        }
        _toProc   = new BufferedWriter( new OutputStreamWriter(_proc.getOutputStream()) );
        _fromProc = new BufferedReader( new  InputStreamReader(_proc.getInputStream()) );
        _cmd = cmd;
    }

    public String send(String s) {
    	String stat = "OK";
    	try { _toProc.write(s); _toProc.flush(); }
    	catch(Exception e) {
    		stat = e.getMessage();
            System.err.format("Error sending command to %s%n\t%s%n",_cmd,stat);
    	}
    	return stat;
    }
    public String printResp(PrintStream s) {
    	String stat = "OK";
    	String ret = "";
    	try { 
            while( _fromProc.ready() ) {
                ret=_fromProc.readLine();
                s.println(ret);
            }
    	}
    	catch (Exception e) {
    		stat = e.getMessage();
            System.err.format("Error reading response from %s:%n\t%s%n",
                              _cmd, stat);
    	}
    	return stat;
    }

    // print response lines, BLOCKING, until you see one containing the until string
    public String printResp(PrintStream s, String until) {
    	String stat = "OK";
    	String ret = "";
    	try {
            while(true) {
                while( _fromProc.ready() ) {
                    ret=_fromProc.readLine();
                    s.println(ret);
                    if (ret.contains(until)) return stat;
                }
                Thread.sleep(1000);
            }
    	}
    	catch (Exception e) {
    		stat = e.getMessage();
            System.err.format("Error reading response from %s:%n\t%s%n",
                              _cmd,stat);
    	}
    	return stat;
    }
}
