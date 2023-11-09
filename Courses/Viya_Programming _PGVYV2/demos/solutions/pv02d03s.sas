**********************************************************;
* Demo: Loading Client-Side SAS Data into CAS - SOLUTION *;
**********************************************************;

/*****************************************************************************/
/*  Load SAS data set from a Base engine library (library.tableName) into    */
/*  the specified caslib ("myCaslib") and save as "targetTableName".         */
/*****************************************************************************/

 /* Steps 6-7 */
proc casutil;
    load data=pvbase.employees outcaslib="casuser"
    casout="emps_cas";
quit;

 /* Steps 8-9 */
proc casutil;
    load data=pvbase.employees outcaslib="casuser"
    casout="emps_cas" replace;
quit;

 /* Step 10 */
proc casutil;
    list tables;
quit;

 /* Step 11 */
proc casutil;
    contents casdata="emps_cas" incaslib="casuser";
quit;

 /* Step 12 */
proc contents data=casuser._all_ nods;
run;
proc contents data=casuser.emps_cas varnum;
run;

