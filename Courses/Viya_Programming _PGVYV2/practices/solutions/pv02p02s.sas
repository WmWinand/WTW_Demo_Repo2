************************;
* Practice #2 SOLUTION *;
************************;

/*****************************************************************************/
/*  Load a table ("sourceTableName") from the specified caslib               */
/*  ("sourceCaslib") to the target Caslib ("targetCaslib") and save it as    */
/*  "targetTableName".                                                       */
/*****************************************************************************/

/* Parts a.-c. */
proc casutil;
	load casdata="sales.sas7bdat" incaslib="casuser" 
	     outcaslib="casuser" casout="sales" promote;
	contents casdata="sales";
quit;

/* Parts d.-e. */
proc casutil;
	altertable casdata="sales"  incaslib="casuser"
	           columns={{name="Hire Date" format="date7."}};
    contents casdata="sales";
quit;

