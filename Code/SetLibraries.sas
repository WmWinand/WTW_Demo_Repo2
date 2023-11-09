libname libbase1 "/mnt/viya-share/homes/T.Winand@sas.com/SasStudio/data";

libname libsnow1 SASIOSNF 
	server="saspartner.snowflakecomputing.com"
	user=REPRUI 
	pw="{SAS002}B87C6F3C3D2FB7D53AC0FC1C"
	schema=REPRUI 
	preserve_tab_names=yes
	bulkload=yes 
	bulkunload=yes 
	bl_internal_stage="user/test1"
	;