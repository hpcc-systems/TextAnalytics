import java;

shared UNICODE entityextract(UNICODE input,STRING annotator,STRING annotatorconfig)
   :=     IMPORT(java,'org/hpcc/plugins/HpccGatePlugin.execute:(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;');
	 
	 
	 String annotator:='ANNIE';
	 String annotatorConfig:='ANNIE_with_defaults.gapp';

dsin:=DATASET([{u'John Smith, third president of Umbrella Corporation, worked in Atlanta Georgia and lived at 123 S. Main St in August of 2002'}],{UNICODE line});

dsannotated:=PROJECT(dsin,transform( {unicode intext, unicode annotations},
SELF.intext:=LEFT.line;
UNICODE annotations:=entityextract(left.line,annotator,annotatorConfig);
SELF.annotations:=annotations;));

l_annotation:=RECORD
STRING annotationtype;
UNSIGNED8 beginOffset;
UNSIGNED8 endOffset;
UNICODE annotationvalue;
END;
l_result:=RECORD
UNICODE input;
DATASET(l_annotation) annotations;
END;

l_result T1 := TRANSFORM 
SELF.input:=(UNICODE) xmltext('input');
SELF.annotations:= XMLPROJECT('annotations/annotation',
						TRANSFORM(l_annotation, 
								SELF.beginOffset := (UNSIGNED8) xmltext('beginOffset');
								SELF.endOffset := (UNSIGNED8) xmltext('endOffset');
								SELF.annotationtype := (STRING) xmltext('type');
								SELF.annotationvalue := (UNICODE) xmltext('value');
						));
END;

 parsedsigs := PARSE( dsannotated,annotations,  T1, XML('result'));

output(parsedsigs);