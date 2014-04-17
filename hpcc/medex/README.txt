How to use the medex drug signature extractor:

put the jar in the java plugins jar directory (usually /opt/HPCCSystems/classes) on all thor nodes
	-to test the jar, run "java -cp medex.jar org/apache/medex/ECLMedex" and verify that no errors occur, and valid xml output is returned

edit /etc/environment.conf and add /opt/HPCCSystems/classes/medex.jar to the classpath

restart hpcc (service hpcc-init stop, service hpcc-init start)

call medex with ECL like the following:

IMPORT java;

shared UNICODE MedTag(UNICODE input,UNICODE rec_id)   := 
    IMPORT(java,'org/apache/medex/ECLMedex.MedTag:(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;');

UNICODE result := MedTag('The patient recieved 4mg of coumadin','1');

output(result);



if you find that you get a java heap space/out of memory error, increase the java vm memory heap by adding a line in environment.conf with the maximum memory:
jvmoptions=-Xmx1024m

An example that includes parsing medex xml output into a dataset can be found in TextAnalytics/hpcc/ecl/medex
