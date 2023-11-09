cas casauto;

caslib SFcaslib 
	desc='Snowflake Caslib' 
	/** Admin option only. **/
    /* 	Global	            */
	/************************/ 
	dataSource=(
		srctype='snowflake',          
		server='saspartner.snowflakecomputing.com'
		username='REPRUI',          
		password='{SAS002}B87C6F3C3D2FB7D53AC0FC1C',         
		schema='REPRUI'
		);

libname SFcaslib cas caslib='SFcaslib';
	
proc casutil;
  list files incaslib='SFcaslib';
  list tables incaslib='SFcaslib';
quit;

proc casutil;
	load 
		casdata="cars" 
		incaslib="SFcaslib" 
		outcaslib="SFcaslib"
        casout="cars"
		replace
		;  
	/** Admin option only. ******************************************/  
    /* 	Promote casdata="Client_Offers_CAS" outcaslib="SFcaslib";   */
	/****************************************************************/ 
	quit;

cas casauto terminate;