/*****************************************************************************/
/* ViyaPgm_10: Cleaning Up                                                   */
/*****************************************************************************/

/*****************************************************************************/
/* RUN THIS CODE SECTION IF YOU DID NOT RUN ViyaPgm_01, ViyaPgm_02,          */
/* ViyaPgm_03 PREVIOUSLY                                                     */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/* ViyaPgm_03: Load data into CAS memory - 3 simple ways                     */
/* ViyaPgm_04: List CAS in-memory tables                                     */
/* ViyaPgm_05: Running DATA Step in Viya                                     */
/* ViyaPgm_06: Running DATA Step with "BIG" Data in Viya                     */
/* ViyaPgm_07: Running a DATA Step with Group By in Viya                     */
/* ViyaPgm_08: Running a DATA Step using Partition and Orderby in CAS        */
/* ViyaPgm_09: Creating and Using a User-Defined Formats in CAS              */
/*****************************************************************************/
/* options cashost="127.0.0.1" casport=5570; */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
caslib _all_ assign;
caslib _all_ list;
libname mycas cas caslib=casuser;

proc casutil;
  load data=sashelp.cars casout="cars" replace;
quit;


/*****************************************************************************/
/* Saving CAS In-Memory Tables to Persistent Storage, Dropping Them from     */
/* CAS Memory, and Final Clean Up                                            */
/*****************************************************************************/

/* List in-memory CAS tables and files asspociated with the active caslib */
proc casutil;
  list files incaslib=casuser;
  list tables incaslib=casuser;
run;

/* Use Proc CASUTIL to save in-memory tables to persistent storage */
proc casutil;
  save casdata="cars" incaslib="casuser" replace;
  save casdata="bigcars" incaslib="casuser" replace;
quit;
 

/* Release in-memory table from CAS memory */
proc casutil;
  droptable incaslib="casuser" casdata="cars";
  droptable incaslib="casuser" casdata="bigcars";
  droptable incaslib="casuser" casdata="bigcars_score";
  droptable incaslib="casuser" casdata="cars2";
quit;


/* List tables and files associated with our caslib to see what has changed */
proc casutil;
  list files incaslib=casuser;
  list tables incaslib=casuser;
quit;

/* Terminate session and release resources */
/* cas mySession terminate; */
