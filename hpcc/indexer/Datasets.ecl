import $;
EXPORT Datasets := Module
 
export dsEntityList := Dataset($.Indexes.ENTITY_LIST_FILENAME,$.Layouts.l_entitytypelist,THOR);
 export dsEntityTypes :=DATASET( 
[ 
{$.Utility.MakeHash($.EntityTypes.PERSON_NAME ) ,
				$.EntityTypes.PERSON_NAME, 
				'Person Name',true, true, [] }, 
{$.Utility.MakeHash($.EntityTypes.PHONE_NUMBER) ,
				$.EntityTypes.PHONE_NUMBER, 
				'Phone Number',true,true, []},  
{$.Utility.MakeHash($.EntityTypes.ACCOUNT_NUMBER) ,
				$.EntityTypes.ACCOUNT_NUMBER, 
				'Account Number',true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.URL) ,
				$.EntityTypes.URL,
				$.EntityTypes.URL,true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.USER_AT_DOMAIN) ,
				$.EntityTypes.USER_AT_DOMAIN,
				$.EntityTypes.USER_AT_DOMAIN,true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.UNFORMATTED_STRING) ,
				$.EntityTypes.UNFORMATTED_STRING, 
				'Other',true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.IP_ADDRESS) ,
				$.EntityTypes.IP_ADDRESS,
				'IP Address',true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.USER_ID) ,
				$.EntityTypes.USER_ID,
				$.EntityTypes.USER_ID,true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.FAX_NUMBER) ,
				$.EntityTypes.FAX_NUMBER,
				'Fax Number',true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.PERSON_IDENTIFIER) ,
				$.EntityTypes.PERSON_IDENTIFIER,
				$.EntityTypes.PERSON_IDENTIFIER,true,true, []}, 
{$.Utility.MakeHash($.EntityTypes.FULL_ADDRESS) ,
				$.EntityTypes.FULL_ADDRESS,
				$.EntityTypes.FULL_ADDRESS,true, true, []},
{$.Utility.MakeHash($.EntityTypes.BUSINESS_NAME ) ,
				$.EntityTypes.BUSINESS_NAME ,
				'Business Name',true, true, []},
{$.Utility.MakeHash($.EntityTypes.CITY) ,
				$.EntityTypes.CITY ,
				$.EntityTypes.CITY ,true, true, []}		,
{$.Utility.MakeHash($.EntityTypes.PROVINCE) ,
				$.EntityTypes.PROVINCE ,
				$.EntityTypes.PROVINCE ,true, true, []}		,
{$.Utility.MakeHash($.EntityTypes.POSTAL_CODE) ,
				$.EntityTypes.POSTAL_CODE ,
				'Postal Code' ,true, true, []}		,
{$.Utility.MakeHash($.EntityTypes.DATE) ,
				$.EntityTypes.DATE ,
				$.EntityTypes.DATE ,true, true, []}		,
{$.Utility.MakeHash($.EntityTypes.GENDER) ,
				$.EntityTypes.GENDER ,
				$.EntityTypes.GENDER ,true, true, []}		,
{$.Utility.MakeHash($.EntityTypes.COUNTRY) ,
				$.EntityTypes.COUNTRY ,
				$.EntityTypes.COUNTRY ,true, true, []}		,
{$.Utility.MakeHash($.EntityTypes.YEAR) ,
				$.EntityTypes.YEAR ,
				'Year' ,true, true, []},
{$.Utility.MakeHash($.EntityTypes.STREET_ADDRESS) ,
				$.EntityTypes.STREET_ADDRESS ,
				'Street Address' ,true, true, []}
				] 
	,$.Layouts.L_EntityRefData) ; 
	
// Be careful not to exceed the maxlength fo the returned dataset
// it just segfaults.
export DATASET($.Indexes.layout_ret) orintsets(
  DATASET($.Indexes.layout_int) inputleft
, DATASET($.Indexes.layout_int) inputleftrun
, DATASET($.Indexes.layout_int) inputright
, DATASET($.Indexes.layout_int) inputrightrun
) := BEGINC++
	#body
	// should always be equal
	unsigned long lenleft  = (unsigned long)lenInputleft;
	unsigned long lenleftrun  = (unsigned long)lenInputleftrun;
  // should always be equal
	unsigned long lenright = (unsigned long)lenInputright;
	unsigned long lenrightrun = (unsigned long)lenInputrightrun;
  unsigned long len = lenleft <= lenright ? lenleft : lenright;
	uint *outset;
	outset = (uint*)rtlMalloc(lenleft + lenright);
	uint *outpos;
	outpos = (uint*)rtlMalloc(lenleft + lenright);
  uint leftsize = (lenleft/sizeof(uint));
  uint rightsize = (lenright/sizeof(uint));
	uint ileft = 0;
	uint iright = 0;
	uint iout = 0;
  uint foo = (lenleft + lenright)/sizeof(uint);
	
				 // FILE * pFile;
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "Starting...\n");
				 // fprintf (pFile, "leftsize = %d, rightsize = %d, outsize = %d\n", leftsize, rightsize, foo);
				 // fclose(pFile);
	
	while( (ileft < leftsize || iright < rightsize) && iout < 4096)
	{
	  int idxleft = ileft < leftsize ? ileft : leftsize - 1;
	  uint lword = ((uint*)inputleft)[idxleft];
		uint loffset = ((uint*)inputleftrun)[idxleft];
    int idxright = iright < rightsize ? iright : rightsize - 1;
	  uint rword = ((uint*)inputright)[idxright];
		uint roffset = ((uint*)inputrightrun)[idxright];
    if(loffset == roffset)
		{
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in OR\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = lword | rword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
       iright++;
		}
    else if(loffset < roffset && ileft < leftsize)
    {
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in left\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = lword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
    }
    else if(loffset < roffset && ileft >= leftsize)
    {
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in left2\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = rword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = roffset;
			   iout++; 
			 }
       iright++;
    }
    else if(loffset > roffset && iright < rightsize)
    {
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in right\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = rword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = roffset;
			   iout++; 
			 }
       iright++;
    }
    else if(loffset > roffset && iright >= rightsize)
    {
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in right2\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = lword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
    }
		else
		{
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d (%d), iright = %d (%d) :: in NOOP\t", iout, ileft, leftsize, iright, rightsize);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
				 iout++;
		}
	}
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "Finished Loop\n");
				 // fclose(pFile);
  int combinedlen = (iout*sizeof(uint))*2 + sizeof(int)*2;
	
	int *outsetlen;
	outsetlen = (int*)rtlMalloc(sizeof(int));
	outsetlen[0] = (int)(iout*sizeof(uint));
	int *outposlen;
	outposlen = (int*)rtlMalloc(sizeof(int));
	outposlen[0] = (int)(iout*sizeof(uint));
 
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "combinedlen = %d\n", combinedlen);
				 // fprintf (pFile, "Malloced output sizes\n");
				 // fclose(pFile);
	// __lenResult = (iout*sizeof(uint));
	// __result = (void*)rtlMalloc((iout*sizeof(uint)));
	// memcpy(__result , outset, (iout*sizeof(uint)));
	// memcpy(__result , outpos, (iout*sizeof(uint)));
	__lenResult = combinedlen;
	__result = (void*)rtlMalloc(combinedlen);
	// memcpy(__result , outsetlen, (sizeof(int)));
	// memcpy(__result + sizeof(int) , outset, (iout*sizeof(uint)));
	// memcpy(__result + sizeof(int) + (iout*sizeof(uint)) , outposlen, (sizeof(int)));
	// memcpy(__result + sizeof(int) + (iout*sizeof(uint)) + sizeof(int), outpos, (iout*sizeof(uint)));
	memcpy(__result , outsetlen, (sizeof(int)));
	memcpy(&((uint*)__result)[1] , outset, (iout*sizeof(uint)));
	memcpy(&((uint*)__result)[1+iout] , outposlen, (sizeof(int)));
	memcpy(&((uint*)__result)[1+iout+1], outpos, (iout*sizeof(uint)));
ENDC++;


export DATASET($.Indexes.layout_ret) andintsets(
  DATASET($.Indexes.layout_int) inputleft
, DATASET($.Indexes.layout_int) inputleftrun
, DATASET($.Indexes.layout_int) inputright
, DATASET($.Indexes.layout_int) inputrightrun
) := BEGINC++
	#body
	// should always be equal
	unsigned long lenleft  = (unsigned long)lenInputleft;
	unsigned long lenleftrun  = (unsigned long)lenInputleftrun;
  // should always be equal
	unsigned long lenright = (unsigned long)lenInputright;
	unsigned long lenrightrun = (unsigned long)lenInputrightrun;
  unsigned long len = lenleft <= lenright ? lenleft : lenright;
	uint *outset;
	outset = (uint*)rtlMalloc(len);
	uint *outpos;
	outpos = (uint*)rtlMalloc(len);
  uint leftsize = (lenleft/sizeof(uint));
  uint rightsize = (lenright/sizeof(uint));
	uint ileft = 0;
	uint iright = 0;
	uint iout = 0;
	
	while(ileft < leftsize && iright < rightsize)
	{
	  uint lword = ((uint*)inputleft)[ileft];
		uint loffset = ((uint*)inputleftrun)[ileft];
	  uint rword = ((uint*)inputright)[iright];
		uint roffset = ((uint*)inputrightrun)[iright];
    if(loffset == roffset)
		{
       uint outword = lword & rword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
       iright++;
		}
    else if(loffset < roffset)
    {
       ileft++;
    }
    else if(loffset > roffset)
    {
       iright++;
    }
	}
  int combinedlen = (iout*sizeof(uint))*2 + sizeof(int)*2;
	
	int *outsetlen;
	outsetlen = (int*)rtlMalloc(sizeof(int));
	outsetlen[0] = (int)(iout*sizeof(uint));
	int *outposlen;
	outposlen = (int*)rtlMalloc(sizeof(int));
	outposlen[0] = (int)(iout*sizeof(uint));
 
	// __lenResult = (iout*sizeof(uint));
	// __result = (void*)rtlMalloc((iout*sizeof(uint)));
	// memcpy(__result , outset, (iout*sizeof(uint)));
	// memcpy(__result , outpos, (iout*sizeof(uint)));
	__lenResult = combinedlen;
	__result = (void*)rtlMalloc(combinedlen);
	// memcpy(__result , outsetlen, (sizeof(int)));
	// memcpy(__result + sizeof(int) , outset, (iout*sizeof(uint)));
	// memcpy(__result + sizeof(int) + (iout*sizeof(uint)) , outposlen, (sizeof(int)));
	// memcpy(__result + sizeof(int) + (iout*sizeof(uint)) + sizeof(int), outpos, (iout*sizeof(uint)));
	memcpy(__result , outsetlen, (sizeof(int)));
	memcpy(&((uint*)__result)[1] , outset, (iout*sizeof(uint)));
	memcpy(&((uint*)__result)[1+iout] , outposlen, (sizeof(int)));
	memcpy(&((uint*)__result)[1+iout+1], outpos, (iout*sizeof(uint)));
ENDC++;

// input left is the input we are removing documents from
// input right is the NOT input
// Be careful not to exceed the maxlength for the returned dataset
// it just segfaults.
export DATASET($.Indexes.layout_ret) andnotintsets(
  DATASET($.Indexes.layout_int) inputleft
, DATASET($.Indexes.layout_int) inputleftrun
, DATASET($.Indexes.layout_int) inputright
, DATASET($.Indexes.layout_int) inputrightrun
) := BEGINC++
	#body
	// should always be equal
	unsigned long lenleft  = (unsigned long)lenInputleft;
	unsigned long lenleftrun  = (unsigned long)lenInputleftrun;
  // should always be equal
	unsigned long lenright = (unsigned long)lenInputright;
	unsigned long lenrightrun = (unsigned long)lenInputrightrun;
  unsigned long len = lenleft <= lenright ? lenleft : lenright;
	uint *outset;
	outset = (uint*)rtlMalloc(lenleft + lenright);
	uint *outpos;
	outpos = (uint*)rtlMalloc(lenleft + lenright);
  uint leftsize = (lenleft/sizeof(uint));
  uint rightsize = (lenright/sizeof(uint));
	uint ileft = 0;
	uint iright = 0;
	uint iout = 0;
  uint foo = (lenleft + lenright)/sizeof(uint);
	
				 // FILE * pFile;
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "Starting...\n");
				 // fprintf (pFile, "leftsize = %d, rightsize = %d, outsize = %d\n", leftsize, rightsize, foo);
				 // fclose(pFile);
  // while we still have space left in the input array and the output isn't at max size	
	while( (ileft < leftsize) && iout < 4096)
	{
	  int idxleft = ileft < leftsize ? ileft : leftsize - 1;
	  uint lword = ((uint*)inputleft)[idxleft];
		uint loffset = ((uint*)inputleftrun)[idxleft];
    int idxright = iright < rightsize ? iright : rightsize - 1;
	  uint rword = ((uint*)inputright)[idxright];
		uint roffset = ((uint*)inputrightrun)[idxright];
    // if we are at the same offset we will Exclusive OR the RIGHT with 4294967295
		// which is all 32 bits set to 1. (uint is 32 bits wide)
		// and then AND the left and resulting value together
    if(loffset == roffset)
		{
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in OR\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = lword & (rword ^ 4294967295);
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
       iright++;
		}
		// left offset hasn't caught up to the right offset and there are still
		// values in the left side. Add the left side to the output.
    else if(loffset < roffset && ileft < leftsize)
    {
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in left\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = lword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
    }
		// if the left offset is greater than the right offset and there are still
		// values in the right side. Increment the right side.
    else if(loffset > roffset && iright < rightsize)
    {
       iright++;
    }
		// if the left offset is greater than the right offset and the right side
		// is done. Add the left side to the output.
    else if(loffset > roffset && iright >= rightsize)
    {
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d, iright = %d :: in right2\t", iout, ileft, iright);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
       uint outword = lword;
       if(outword != 0)
			 { 
  			 outset[iout] = outword;
  			 outpos[iout] = loffset;
			   iout++; 
			 }
       ileft++;
    }
		// if we get here we increment iout until we get out of the while loop.
		else
		{
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "iout = %d, ileft = %d (%d), iright = %d (%d) :: in NOOP\t", iout, ileft, leftsize, iright, rightsize);
				 // fprintf (pFile, "left offset = %d, right offset = %d\n", loffset, roffset);
				 // fclose(pFile);
				 iout++;
		}
	}
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "Finished Loop\n");
				 // fclose(pFile);
  int combinedlen = (iout*sizeof(uint))*2 + sizeof(int)*2;
	
	int *outsetlen;
	outsetlen = (int*)rtlMalloc(sizeof(int));
	outsetlen[0] = (int)(iout*sizeof(uint));
	int *outposlen;
	outposlen = (int*)rtlMalloc(sizeof(int));
	outposlen[0] = (int)(iout*sizeof(uint));
 
				 // pFile = fopen("/tmp/testout.txt", "a");
				 // fprintf (pFile, "combinedlen = %d\n", combinedlen);
				 // fprintf (pFile, "Malloced output sizes\n");
				 // fclose(pFile);
	// __lenResult = (iout*sizeof(uint));
	// __result = (void*)rtlMalloc((iout*sizeof(uint)));
	// memcpy(__result , outset, (iout*sizeof(uint)));
	// memcpy(__result , outpos, (iout*sizeof(uint)));
	__lenResult = combinedlen;
	__result = (void*)rtlMalloc(combinedlen);
	// memcpy(__result , outsetlen, (sizeof(int)));
	// memcpy(__result + sizeof(int) , outset, (iout*sizeof(uint)));
	// memcpy(__result + sizeof(int) + (iout*sizeof(uint)) , outposlen, (sizeof(int)));
	// memcpy(__result + sizeof(int) + (iout*sizeof(uint)) + sizeof(int), outpos, (iout*sizeof(uint)));
	memcpy(__result , outsetlen, (sizeof(int)));
	memcpy(&((uint*)__result)[1] , outset, (iout*sizeof(uint)));
	memcpy(&((uint*)__result)[1+iout] , outposlen, (sizeof(int)));
	memcpy(&((uint*)__result)[1+iout+1], outpos, (iout*sizeof(uint)));
ENDC++;


END;
 