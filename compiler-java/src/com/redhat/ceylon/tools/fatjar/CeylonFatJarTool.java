package com.redhat.ceylon.tools.fatjar;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.SortedSet;
import java.util.jar.Attributes;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

import com.redhat.ceylon.cmr.api.ModuleQuery;
import com.redhat.ceylon.cmr.impl.IOUtils;
import com.redhat.ceylon.common.FileUtil;
import com.redhat.ceylon.common.JVMModuleUtil;
import com.redhat.ceylon.common.ModuleSpec;
import com.redhat.ceylon.common.Versions;
import com.redhat.ceylon.common.tool.Argument;
import com.redhat.ceylon.common.tool.Description;
import com.redhat.ceylon.common.tool.Option;
import com.redhat.ceylon.common.tool.OptionArgument;
import com.redhat.ceylon.common.tool.Summary;
import com.redhat.ceylon.common.tool.ToolUsageError;
import com.redhat.ceylon.model.cmr.ArtifactResult;
import com.redhat.ceylon.model.loader.JvmBackendUtil;
import com.redhat.ceylon.tools.moduleloading.ModuleLoadingTool;

@Summary("Generate a Ceylon executable jar for a given module")
@Description("Gerate an executable _fat jar_ which contains the given module and all its run-time"
        + " dependencies, including the Ceylon run-time, which makes that jar self-sufficient and"
        + " executable by `java` as if the Ceylon module was run by `ceylon run`."
)
public class CeylonFatJarTool extends ModuleLoadingTool {

    private List<ModuleSpec> modules;
    private boolean force;
	private File out;
    private final List<String> excludedModules = new ArrayList<>();
    /** The (Ceylon) name of the functional to run, e.g. {@code foo.bar::baz} */
    private String run;

    @Argument(order = 1, argumentName="module", multiplicity="+")
    public void setModules(List<String> modules) {
        setModuleSpecs(ModuleSpec.parseEachList(modules));
    }

    public void setModuleSpecs(List<ModuleSpec> modules) {
        this.modules = modules;
    }

    @OptionArgument(longName = "run", argumentName = "toplevel")
    @Description("Specifies the fully qualified name of a toplevel method or class with no parameters. " +
            "The format is: `qualified.package.name::classOrMethodName` with `::` acting as separator " +
            "between the package name and the toplevel class or method name (defaults to `{module}::run`).")
    public void setRun(String run) {
        this.run = run;
    }

    @Description("Target fat-jar file (defaults to `{name}-{version}.jar`).")
    @OptionArgument(shortName = 'o', argumentName="file")
    public void setOut(File out) {
        this.out = out;
    }

    @OptionArgument(argumentName="moduleOrFile", shortName='x')
    @Description("Excludes modules from the resulting far jat. Can be a module name or " + 
            "a file containing module names. Can be specified multiple times. Note that "+
            "this excludes the module from the resulting fat jar, but if your modules require that "+
            "module to be present at runtime it will still be required and may cause your "+
            "application to fail to start if it is not provided at runtime.")
    public void setExcludeModule(List<String> exclusions) {
        for (String each : exclusions) {
            File xFile = new File(each);
            if (xFile.exists() && xFile.isFile()) {
                try (BufferedReader reader = new BufferedReader(new FileReader(xFile))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        this.excludedModules.add(line);
                    }
                } catch (IOException e) {
                    throw new ToolUsageError(CeylonFatJarMessages.msg("exclude.file.failure", each), 
                            e);
                }
            } else {
                this.excludedModules.add(each);
            }
        }
    }

    @Option(longName="force")
    @Description("Force generation of mlib folder with multiple versions of the same module.")
    public void setForce(boolean force) {
        this.force = force;
    }

    @Override
    public void run() throws Exception {
        String firstModuleName = null, firstModuleVersion = null;
        for (ModuleSpec module : modules) {
            String moduleName = module.getName();
            String version = checkModuleVersionsOrShowSuggestions(
                    getRepositoryManager(),
                    moduleName,
                    module.isVersioned() ? module.getVersion() : null,
                    ModuleQuery.Type.JVM,
                    Versions.JVM_BINARY_MAJOR_VERSION,
                    Versions.JVM_BINARY_MINOR_VERSION,
                    null, null, // JS binary but don't care since JVM
                    null);
            if(version == null)
                return;
            if(firstModuleName == null){
                firstModuleName = moduleName;
                firstModuleVersion = version;
            }
            loadModule(null, moduleName, version);
            if(!force)
                errorOnConflictingModule(moduleName, version);
        }
        
        File outputJar = applyCwd(out != null ? out : new File(firstModuleName+"-"+firstModuleVersion+".jar"));
        if(outputJar.getParentFile() != null && !outputJar.getParentFile().exists()){
            FileUtil.mkdirs(outputJar.getParentFile());
        }
        if(outputJar.exists()){
            FileUtil.delete(outputJar);
        }
        Set<String> added = new HashSet<>();

        Manifest manifest = new Manifest();
        Attributes mainAttributes = manifest.getMainAttributes();
        String className = JVMModuleUtil.javaClassNameFromCeylon(firstModuleName, run != null ? run : (firstModuleName + "::run"));
        mainAttributes.putValue("Main-Class", className);
        mainAttributes.putValue("Manifest-Version", "1.0");
        mainAttributes.putValue("Created-By", "Ceylon fat-jar for module "+firstModuleName+"/"+firstModuleVersion);
        added.add("META-INF/");
        added.add("META-INF/MANIFEST.MF");

        try(ZipOutputStream zipFile = new JarOutputStream(new FileOutputStream(outputJar), manifest)){
            List<ArtifactResult> staticMetamodelEntries = new ArrayList<>(this.loadedModules.size());
            for(ArtifactResult entry : this.loadedModules.values()){
                // since we even add missing modules there to avoid seeing them twice, let's skip them now
                if(entry == null)
                    continue;
                File file = entry.artifact();
                if(file == null)
                    continue;
                // on duplicate, let's only keep the last version
                SortedSet<String> versions = loadedModuleVersions.get(entry.name());
                if(!versions.isEmpty() && entry.version() != null && !entry.version().equals(versions.last()))
                    continue;
                if(isVerbose()){
                    append(file.getAbsolutePath());
                    newline();
                }
                staticMetamodelEntries.add(entry);

                try(ZipFile src = new ZipFile(file)){
                    Enumeration<? extends ZipEntry> entries = src.entries();
                    while(entries.hasMoreElements()){
                        ZipEntry srcEntry = entries.nextElement();
                        // skip manifests
                        if(skipEntry(srcEntry.getName()))
                            continue;
                        if(!added.add(srcEntry.getName())){
                            // multiple folders is fine
                            if(!srcEntry.isDirectory()){
                                this.append("Warning: duplicate entry "+srcEntry.getName()+" (from "+file+") already added: skipping\n");
                            }
                            continue;
                        }
                        srcEntry.setCompressedSize(-1);
                        zipFile.putNextEntry(srcEntry);
                        if(!srcEntry.isDirectory())
                            IOUtils.copyStream(src.getInputStream(srcEntry), zipFile, true, false);
                    }
                }
            }
            JvmBackendUtil.writeStaticMetamodel(zipFile, added, staticMetamodelEntries, jdkProvider);
            zipFile.flush();
        }
        flush();
    }


    private boolean skipEntry(String name) {
        return name.equals("META-INF/MANIFEST.MF")
                || name.equals("META-INF/INDEX.LIST")
                || name.equals("META-INF/mapping.txt")
                // skip signatures too
                || (name.startsWith("META-INF/")
                        && (name.endsWith(".DSA") || name.endsWith(".RSA") || name.endsWith(".SF")));
    }

    @Override
    protected boolean shouldExclude(String moduleName, String version) {
        return super.shouldExclude(moduleName, version) ||
                this.excludedModules.contains(moduleName);
    }
}
