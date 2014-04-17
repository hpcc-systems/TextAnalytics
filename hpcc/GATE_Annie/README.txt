This plugin integrates with the GATE Annie entity extractor.
How to use:
put hpccgateplugin.jar into the java plugins jar directory (usually /opt/HPCCSystems/classes) on all thor nodes
put the plugins folder in the same location as the java jar.
	-Make sure that all files in plugins are world-readable.
	-to test the jar, run "java -cp hpccgateplugin.jar org/hpcc/plugin/HpccGatePlugin" and verify that no errors occur, and valid output is returned
		-if you get a major/minor version error when doing this, you need to upgrade the HPCC Cluster's JDK to 1.7

edit /etc/environment.conf and add /opt/HPCCSystems/classes/hpccgateplugin.jar (or the location of the jar if different) to the classpath

restart hpcc (service hpcc-init stop, service hpcc-init start)

call the segmenter with ECL like that in exampleusage.ecl

if you find that you get a java heap space/out of memory error, increase the java vm memory heap by adding a line in environment.conf with the maximum memory:
jvmoptions=-Xmx1024m