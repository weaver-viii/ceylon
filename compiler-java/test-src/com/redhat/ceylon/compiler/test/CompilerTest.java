package com.redhat.ceylon.compiler.test;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.regex.Matcher;

import javax.tools.JavaFileObject;

import junit.framework.Assert;

import com.redhat.ceylon.compiler.tools.CeyloncFileManager;
import com.redhat.ceylon.compiler.tools.CeyloncTaskImpl;
import com.redhat.ceylon.compiler.tools.CeyloncTool;
import com.sun.source.util.TaskEvent;
import com.sun.source.util.TaskEvent.Kind;
import com.sun.source.util.TaskListener;
import com.sun.tools.javac.tree.JCTree.JCCompilationUnit;
import com.sun.tools.javac.zip.ZipFileIndex;

public abstract class CompilerTest {

	private final static String dir = "test-src";
	protected final static String destDir = "build/ceylon-cars";
	private final static String destCar = destDir + "/unversioned/default_module-unversioned.car";
    
	protected final String path;

	public CompilerTest() {
        // for comparing with java source
        Package pakage = getClass().getPackage();
        String pkg = pakage == null ? "" : pakage.getName().replaceAll("\\.", Matcher.quoteReplacement(File.separator));
        path = dir + File.separator + pkg + File.separator;
	}
	
	protected CeyloncTool makeCompiler(){
        try {
            return new CeyloncTool();
        } catch (VerifyError e) {
            System.err.println("ERROR: Cannot run tests! Did you maybe forget to configure the -Xbootclasspath/p: parameter?");
            throw e;
        }
	}

	protected CeyloncFileManager makeFileManager(CeyloncTool compiler){
        return (CeyloncFileManager)compiler.getStandardFileManager(null, null, null);
	}
	
	protected void compareWithJavaSource(String name) {
		compareWithJavaSource(name+".src", name+".ceylon");
	}

	protected void compareWithJavaSource(String java, String... ceylon) {
	    // make a compiler task
        // FIXME: runFileManager.setSourcePath(dir);
	    CeyloncTaskImpl task = getCompilerTask(ceylon);
	    
	    // grab the CU after we've completed it
	    class Listener implements TaskListener{
            JCCompilationUnit compilationUnit;
            private String compilerSrc;
            @Override
            public void started(TaskEvent e) {
            }

            @Override
            public void finished(TaskEvent e) {
                if(e.getKind() == Kind.ENTER){
                    if(compilationUnit == null) {
                        compilationUnit = (JCCompilationUnit) e.getCompilationUnit();
                        // for some reason compilationUnit is full here in the listener, but empty as soon
                        // as the compile task is done. probably to clean up for the gc?
                        compilerSrc = normalizeLineEndings(compilationUnit.toString());
                    }
                }
            }
        }
	    Listener listener = new Listener();
	    task.setTaskListener(listener);

	    // now compile it all the way
	    Boolean success = task.call();
	    
	    Assert.assertTrue("Compilation failed", success);

		// now look at what we expected
		String expectedSrc = normalizeLineEndings(readFile(new File(path, java))).trim();
        String compiledSrc = listener.compilerSrc.trim();
		Assert.assertEquals("Source code differs", expectedSrc, compiledSrc);
	}

	private String readFile(File file) {
		try{
			Reader reader = new FileReader(file);
			StringBuilder strbuf = new StringBuilder();
			try{
				char[] buf = new char[1024];
				int read;
				while((read = reader.read(buf)) > -1)
					strbuf.append(buf, 0, read);
			}finally{
				reader.close();
			}
			return strbuf.toString();
		}catch(IOException x){
			throw new RuntimeException(x);
		}
	}

	private String normalizeLineEndings(String txt) {
		String result = txt.replaceAll("\r\n", "\n"); // Windows
		result = result.replaceAll("\r", "\n"); // Mac (OS<=9)
		return result;
	}

	protected void compile(String... ceylon) {
	    Boolean success = getCompilerTask(ceylon).call();
	    Assert.assertTrue(success);
	}

	protected void compileAndRun(String main, String... ceylon) {
		compile(ceylon);
		try{
		    // make sure we load the stuff from the Car
		    File car = new File(destCar);
		    ClassLoader loader = URLClassLoader.newInstance(
		            new URL[] { car.toURL() },
		            getClass().getClassLoader()
		            );
			java.lang.Class<?> klass = java.lang.Class.forName(main, true, loader);
			Method m = klass.getMethod(klass.getSimpleName());
			m.invoke(null);
		}catch(Exception x){
			throw new RuntimeException(x);
		}
	}
	
	protected CeyloncTaskImpl getCompilerTask(String... sourcePaths){
        // make sure we get a fresh jar cache for each compiler run
	    ZipFileIndex.clearCache();
        java.util.List<File> sourceFiles = new ArrayList<File>(sourcePaths.length);
	    for(String file : sourcePaths){
	        sourceFiles.add(new File(path, file));
	    }
	    
	    CeyloncTool runCompiler = makeCompiler();
        CeyloncFileManager runFileManager = makeFileManager(runCompiler );
        
        // make sure the destination repo exists
        new File(destDir).mkdirs();
        
        Iterable<? extends JavaFileObject> compilationUnits1 =
            runFileManager.getJavaFileObjectsFromFiles(sourceFiles);
        return (CeyloncTaskImpl) runCompiler.getTask(null, runFileManager, null, 
                Arrays.asList("-src", getSourcePath(), "-out", destDir, "-verbose"), 
                null, compilationUnits1);
	}

    protected String getSourcePath() {
        return dir;
    }
}
