EXPORT Datasets := MODULE

export dsRaw:=DATASET($.Filenames.f_raw,$.layouts.l_raw,csv(HEADING(0),terminator('£'),separator('$'),maxlength(100000)));
export dsClean:=DATASET($.Filenames.f_clean,$.layouts.l_clean,THOR);
export dsSignatures:=DATASET($.Filenames.f_signature,$.layouts.l_signature,THOR);

END;