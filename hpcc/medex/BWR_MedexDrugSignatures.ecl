IMPORT java;
IMPORT lib_unicodelib;

shared UNICODE MedTag(UNICODE input,UNICODE rec_id)   := 
    IMPORT(java,'org/apache/medex/ECLMedex.MedTag:(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;');

l_raw:=RECORD
unicode line;
end;
//sample dataset
shared ds:=DATASET([{'Admission Date :\n2012-10-31\nDischarge Date :\n2012-11-07\nDate of Birth :\n1941-03-23\nSex : \nM\nService :\nMEDICINE\nAllergies : \nNsaids/Anti-Inflammatory Classifier / Vancomycin\nAttending : \nKristie R. Hamby , M.D. \nChief Complaint :\nCC : Antonio M. Z. Eddings , M.D. \nMajor Surgical or Invasive Procedure :\nMesenteric angiograpm w/ coil embolization of bleeding vessel .\nSigmoidoscopy .\nColonoscopy .\nHistory of Present Illness :\nHPI: Pt is a 71 y/o male with h/o dm2 , cad s/p cabg , DVT/PE on long term anti-coagulation , ulcerative colitis on Asacol presents with brbpr starting at 9am of the morning of admission .\nHe\'d been having lower abdominal pain for approximately the past week , a symptom for which he\'s been admitted in the past .\nHis PCP had recently started ciprofloxacin for a UTI . \nAt 9am the morning of admission he passed a large , bloody bowel movement and came to the Michael . There , his vitals were intially stable with a hct of 36.7 , though he was felt to be hypovolemic and this hemoconcentrated ; his previous hct was 39 about five months ago .\nHe refused an NG lavage .\nAlthough an initial DRE showed only clot , he later passed a large , bloody bowel movement , and his bp nadired to the low 90\'s but rested there only transiently and easily rebounded to the 130\'s-140\'s with fluid ; he then went to angiography for a tagged RBC scan where they found and embolized two vessels to the sigmoid colon .\nHis HCT had dropped from 36.7 to 30.8 despite 2U PRBC and 3 U FFP .\nIs called out of the FICU as has been been HD and stable HCT .\nCurrently denies CP , SOB , abd pain or continued BRBPR .\nPast Medical History :\nPMH :\n1.) DM-2  \n2.) CAD s/p 3v-CABG 2003 and subsequent stenting of SVG and LIMA\n3.) CHF with EF 30-35% on 07-10 echo\n4.) Right parietal intracranial bleeding following 1996 cardiac cath\n5.) LBBB\n6.) Sinus node dysfunction s/p pacemaker\n7.) H/O DVT ( right sided ) and subsequent PE , put onto lifetime warfarin\n8.) Ulcerative colitis\nPSH :\n1.) C4-7 anterior discectomies\n2.) CABG 2003\n3.) R intracerebral hemorrhage drainage \nSocial History :\nSocHx : Mr Peres generally lives with his wife but has spent a great deal of time recently at rehab .\nHe has no h/o ETOH/IVDA but quit tob 15 years ago .\nFamily History :\nNoncontributory . \nPhysical Exam :\nVS 98.4 , 62 , 103/37 , 15 97%2L\ngen - lying in bed , NAD\nheent - anicteric sclera , op clear with mmm\nneck - jvd flat\ncv - rrr , s1s2 , no m/r/g\npul - CTAB without rales\nabd - soft , minimally distended , nt , no rebound/guarding , nabs\nextrm - trace edema at ankles , no cyanosis , warm/dry \nPertinent Results :\n2012-10-31 05:47PM URINE\nCOLOR - Straw APPEAR - Clear SP Marquez - 1.021\n2012-10-31 05:47PM URINE\nBLOOD - LG NITRITE - NEG PROTEIN - NEG\nGLUCOSE - NEG KETONE - NEG BILIRUBIN - NEG UROBILNGN - NEG PH - 7.0 LEUK - NEG\n2012-10-31 05:47PM URINE\nRBC-21-50* WBC-0-2 BACTERIA - FEW\nYEAST - NONE EPI - <1\n2012-10-31 02:32PM\nLACTATE - 1.8\n2012-10-31 12:20PM\nGLUCOSE - 197* UREA N-25* CREAT - 0.8 SODIUM - 141\nPOTASSIUM - 3.7 CHLORIDE - 105 TOTAL CO2 - 22 ANION GAP - 18\n2012-10-31 12:20PM\nWBC - 5.6 RBC - 4.35* HGB - 12.6* HCT - 36.7* MCV - 84\nMCH - 28.9 MCHC - 34.3 RDW - 15.7*\n2012-10-31 12:20PM\nNEUTS - 80.5* LYMPHS - 13.1* MONOS - 3.5 EOS - 2.5\nBASOS - 0.4\n2012-10-31 12:20PM\nPOIKILOCY - 1+ MICROCYT - 1+\n2012-10-31 12:20PM\nPLT COUNT - 102*\n2012-10-31 12:20PM\nPT - 20.5* PTT - 29.4 INR(PT) - 3.0\nGI BLEEDING STUDY\n2012-10-31\nIMPRESSION : Increased tracer activity demonstrated within the left lower quadrant , most likely sigmoid colonic loops of bowel , consistent with active bleeding .\nCT ABDOMEN W/CONTRAST\n2012-10-31 3:27 PM\nIMPRESSION :\n1. No evidence of colitis or other bowel pathology present to explain the patient\'s bright red blood per rectum .\n2. Stable appearance of left adrenal fat-containing lesion consistent with a myelolipoma .\n3. Stable appearance of hypodense lesion within the caudate lobe of the liver , too small to fully characterize .\n4. Subcentimeter attenuation lesion within the lower pole of the right kidney , too small to characterize .\n5. 3-mm noncalcified pulmonary nodule within the right lower lobe . \nIf the patient does not have a history of a primary malignancy , followup CT of the chest in 1 year is recommended to evaluate for stability of this finding .\nBrief Hospital Course :\nInitial A/P :\n71 y/o male with dm2 , cad , chf , uc presents with one week of lower abdominal pain and 2 episodes of brpbr on the day of admission .\n# BRBPR -- The patient was in the intensive care unit given his lower GI bleed .\nAn angiography showed bleeding in two vessels off of the Minnie supplying the sigmoid that were succesfully embolized .\nThe patient was transfused from a Hct 29 to 34 on the day of discharge .\nHis coumadin was held during his stay given his acute bleed but restarted per his PCP with the guidance of GI on the day of discharge .\n- The patient underwent a flex sigmoidoscopy on Friday , 11-02 , which showed old blood in the rectal vault but no active source of bleeding .\nGiven this , it was advised that the patient have a colonoscopy to rule out further bleeding .\n- The patient had a colonoscopy on Monday 11-05 but unfortunately , was unable to complete the study as his bowel \nprep was inadequate .\nTherefore , he had a repeat colonoscopy on 11-06 which showed expected mucosal signs of moderate ulcerative colitis , no polyps , w/ 8 mm ulcer at junction of distal descending colon and sigmoid colon .\n- Biopsies were obtained during his colonoscopy and he should follow up with gastroenterology for the results .\n# Ulcerative colitis -- The patient\'s Asacol was originally held but restarted the day prior to discharge per GI .\n# CAD/CHF - The patient was restarted on his home regimen prior to discharge as it was held temporarily given his acute GI bleed .\nThe exception is that per his PCP , Jason aspirin will be held for 2 weeks given that he was restarted on coumadin with \nhis risk of bleeding .\n# DM-2 -- The patient was maintained on his home insulin regimen .\n# h/o DVT/PE :\nCoumadin was initially held .\nIt was unclear at first as to why the patient required life-long anticoagulation .\nAfter discussing this with his PCP , Leon was clear that the patient had had recurrent DVTs and ultimately a PE and his PCP felt strongly that he required long-term anticoagulation .\nHis goal INR should be 1.6-2.0 . If bleeding continues to occur , consider V. Winchester filter .\n# Access -- 2 large bore PIV\'s\n# Code -- full\nMedications on Admission :\nMeds on Admission :\n1.) Spironolactone/hctz 25/25 daily\n2.) Atenolol 12.5mg daily\n3.) Insulin 45N/8R qAM and 33N qPM\n4.) Furosemide 10 mg every other day\n5.) Aspirin 81 mg daily\n6.) Zoloft 40 mg qAM\n7.) Flomax\n8.) Atorvastatin 40 mg daily\n9.) Ritalin 20 mg daily\n10.) Ramipril 2.5 mg daily\n11.) Asacol 400 mg 3 , TID\n12.) Carafate 1 gm bid\n13.) Actos 15 mg daily\n14.) Folate 1 mg daily\n15.) Warfarin 2 mg daily\nDischarge Medications :\n1. Tamsulosin 0.4 mg Capsule , Sust . Release 24HR Sig : One ( 1 ) Capsule , Sust . Release 24HR PO HS ( at bedtime ) .\n2. Atorvastatin 40 mg Tablet Sig : One ( 1 ) Tablet PO DAILY ( Daily ) .\n3. Methylphenidate 10 mg Tablet Sig : Two ( 2 ) Tablet PO DAILY ( Daily ) .\n4. Acetaminophen 325 mg Tablet Sig : One ( 1 ) Tablet PO Q4-6H ( every 4 to 6 hours ) as needed .\n5. Folic Acid 1 mg Tablet Sig : One ( 1 ) Tablet PO DAILY ( Daily ) .\n6. Atenolol 25 mg Tablet Sig : 0.5 Tablet PO DAILY ( Daily ) .\n7. Spironolactone 25 mg Tablet Sig : One ( 1 ) Tablet PO DAILY ( Daily ) .\n8. Ramipril 1.25 mg Capsule Sig : Two ( 2 ) Capsule PO DAILY ( Daily ) .\n9. Hydrochlorothiazide 25 mg Tablet Sig : One ( 1 ) Tablet PO DAILY ( Daily ) .\n10. Pioglitazone 15 mg Tablet Sig : One ( 1 ) Tablet PO DAILY ( Daily ) as needed for DM .\n11. Mesalamine 400 mg Tablet , Delayed Release ( E.C. ) Sig : Three ( 3 ) Tablet , Delayed Release ( E.C. ) PO TID ( 3 times a day ) as needed for ulcerative colitis w/o recent severe flares .\n12. Insulin 45 NPH in am with 33 NPH at bedtime\nContinue Sliding scale insulin as needed .\n13. Sertraline 20 mg/mL Concentrate Sig : Two ( 2 )  PO at bedtime .\n14. Coumadin 2 mg Tablet Sig : One ( 1 ) Tablet PO once a day .\nDischarge Disposition : \nExtended Care\nFacility : \nOak Bluffs Of Greenfield\nDischarge Diagnosis :\nRectal bleeding from inferior mesenteric artery tributaries supplying sigmoid colon .\nDischarge Condition : Good .\nDischarge Instructions : \nPlease call physician if you develop shortness of breath , weakness in your legs or arms , sudden blurry vision or slurred speech , chest pain , faintness , or significant unexplained weight loss .\nFollowup Instructions :\nProvider : Lucio Y. Matthews , M.D. Phone : ( 967 ) 675 1641 Date/Time : 2012-12-28 2:30\nProvider :  Greg CLINIC Phone : ( 212 ) 442 0438 Date/Time : 2013-01-11 1:30\nProvider : Lucio F. R. Matthews , M.D. Phone : ( 967 ) 675 1641 Date/Time : 2013-01-11 2:00\nPlease call White , Leslie L. at ( 602 ) 743 8709 to schedule an appointment with him in 1 week .\nPlease call your gastroenterologist to schedule a follow up appointment in 2 weeks .\nAlan John MD 54-745\nCompleted by : Bertha Janice Motta MD 52-860 2012-11-07 @ 1207\nSigned electronically by : DR. Melody PARKS on: WED 2012-11-21 6:22 PM\n'}],l_raw);

l_medex_result:=RECORD
integer8 record_id;
unicode intext;
unicode outtext;
END;

dsInput:=project(ds,transform(l_medex_result,
SELF.intext := LEFT.line;                              
unicode medtag:=MedTag(LEFT.line,(Unicode) COUNTER);                             
SELF.outtext := u'<result>' + medtag + u'</result>';
SELF.record_id:=COUNTER;
)):persist('~temp::persist::medex3');

//xmlout := PROJECT(dsInput,transform({unicode xmlout}, SELF.xmlout:=LEFT.outtext;));

//OUTPUT(xmlout,,'~drea::nlp::interim',CSV(HEADING(0)));


l_signature:= RECORD
UNSIGNED8 id;
UNSIGNED8 record_id;
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

l_sig_container:=RECORD
UNSIGNED8 record_id;
DATASET(l_signature) signatures;
END;


l_sig_container T1 := TRANSFORM 
UNSIGNED8 rec_id := (UNSIGNED8)xmltext('medex/parent_id');
SELF.record_id:=rec_id;
SELF.signatures:= XMLPROJECT('medex/signature',
						TRANSFORM(l_signature, 
								SELF.id := (UNSIGNED8) xmltext('id');
                                  SELF.record_id := rec_id;
								SELF.drugname := xmltext('drugname');
								SELF.drugbegin := (UNSIGNED4)xmltext('drugbegin');
								SELF.drugend :=(UNSIGNED4)xmltext('drugend');
								SELF.brand := xmltext('brand');
								SELF.brandbegin := (UNSIGNED4)xmltext('brandbegin');
								SELF.brandend := (UNSIGNED4)xmltext('brandend');
								SELF.dose_form := xmltext('dose_form');
								SELF.dose_formbegin := (UNSIGNED4)xmltext('dose_formbegin');
								SELF.dose_formend := (UNSIGNED4)xmltext('dose_formend');
								SELF.strength := xmltext('strength');
								SELF.strengthbegin := (UNSIGNED4)xmltext('strengthbegin');
								SELF.strengthend := (UNSIGNED4)xmltext('strengthend');
								SELF.dose_amt := xmltext('dose_amt');
								SELF.dose_amtbegin := (UNSIGNED4)xmltext('dose_amtbegin');
								SELF.dose_amtend := (UNSIGNED4)xmltext('dose_amtend');
								SELF.route := xmltext('route');
								SELF.routebegin := (UNSIGNED4)xmltext('routebegin');
								SELF.routeend := (UNSIGNED4)xmltext('routeend');
								SELF.frequency := xmltext('frequency');
								SELF.frequencybegin := (UNSIGNED4)xmltext('frequencybegin');
								SELF.frequencyend := (UNSIGNED4)xmltext('frequencyend');
								SELF.duration := xmltext('duration');
								SELF.durationbegin :=(UNSIGNED4)xmltext('durationbegin');
								SELF.durationend := (UNSIGNED4)xmltext('durationend');
								SELF.necessity := xmltext('necessity');
								SELF.necessitybegin := (UNSIGNED4)xmltext('necessitybegin');
								SELF.necessityend := (UNSIGNED4)xmltext('necessityend');
								SELF.umls_code := xmltext('umls_code');
								SELF.rx_code := xmltext('rx_code');
								SELF.unknown1 := xmltext('unknown1');
								SELF.generic_name := xmltext('generic_name');
								SELF.sent_text := xmltext('sent_text');
								
						));
END;

 parsedsigs := PARSE( dsInput,outtext,  T1, XML('result'));
output(ds,named('freetext_medex_input'));
output(dsInput,named('raw_medex_output'));
output(parsedsigs,named('parsedmedex'));
