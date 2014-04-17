EXPORT Layouts := MODULE

EXPORT l_raw:=RECORD
unicode line;
end;

EXPORT l_clean:=RECORD
unsigned8 source_id;
unsigned8 record_id;
unicode line;
end;


EXPORT l_medex_result:=RECORD
unsigned8 record_id;
unsigned8 source_id;
unicode intext;
unicode outtext;
END;

EXPORt l_signature:= RECORD
UNSIGNED8 id;
UNSIGNED8 section_id;
UNSIGNED8 record_id;
UNSIGNED8 source_id;
UNICODE drugname;
UNICODE brand;
UNICODE dose_form;
UNICODE strength;
UNICODE dose_amt;
UNICODE route;
UNICODE frequency;
UNICODE duration;
UNICODE necessity;
UNICODE umls_code;
UNICODE rx_code;
UNICODE unknown1;
UNICODE generic_name;
UNSIGNED4 drugbegin;
UNSIGNED4 drugend;
UNSIGNED4 brandbegin;
UNSIGNED4 brandend;
UNSIGNED4 dose_formbegin;
UNSIGNED4 dose_formend;
UNSIGNED4 strengthbegin;
UNSIGNED4 strengthend;
UNSIGNED4 dose_amtbegin;
UNSIGNED4 dose_amtend;
UNSIGNED4 routebegin;
UNSIGNED4 routeend;
UNSIGNED4 frequencybegin;
UNSIGNED4 frequencyend;
UNSIGNED4 durationbegin;
UNSIGNED4 durationend;
UNSIGNED4 necessitybegin;
UNSIGNED4 necessityend;
UNICODE sent_text;
END;

export l_sig_container:=RECORD
UNSIGNED8 record_id;
UNSIGNED8 source_id;
DATASET(l_signature) signatures;
END;

END;