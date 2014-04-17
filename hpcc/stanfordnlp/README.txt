How to use the segmenter:

Download the segmenter frm http://nlp.stanford.edu/software/stanford-segmenter-2014-01-04.zip, unzip, take the data folder, and rename it stanfordsegdata. (Github doesn't allow huge or zipped files stored in it, and the files needed by the segmenter are both.)

put the stanfordseg.jar into the java plugins jar directory (usually /opt/HPCCSystems/classes) on all thor nodes
put the stanfordsegdata folder in the same location as the java jar.
	-Make sure that all files in stanfordsegdata are world-readable.
	-to test the jar, run "java -cp stanfordseg.jar org/hpcc/ECLStanfordSegmenter" and verify that no errors occur, and valid output is returned

edit /etc/environment.conf and add /opt/HPCCSystems/classes/stanfordseg.jar to the classpath

restart hpcc (service hpcc-init stop, service hpcc-init start)

call the segmenter with ECL like the following:

import java;

shared UNICODE Segment(UNICODE input)   :=     IMPORT(java,'org/hpcc/ECLStanfordSegmenter.segment:(Ljava/lang/String;)Ljava/lang/String;');

UNICODE instr:=u'因为冰箱本身的设计寿命是十年左右，时间长了，肯定大部分零部件是要老化的/可怜';
UNICODE outstr:=Segment(instr);
output(instr);
output(outstr);

if you find that you get a java heap space/out of memory error, increase the java vm memory heap by adding a line in environment.conf with the maximum memory:
jvmoptions=-Xmx1024m