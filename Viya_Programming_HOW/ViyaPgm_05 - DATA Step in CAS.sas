/*****************************************************************************/
/* ViyaPgm_05: Running DATA Step in Viya (On the Compute Server and In CAS)  */
/*****************************************************************************/

/*****************************************************************************/
/* RUN THIS CODE SECTION IF YOU DID NOT RUN ViyaPgm_01, ViyaPgm_02,          */
/* AND ViyaPgm_03 PREVIOUSLY                                                 */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/* ViyaPgm_03: Load data into CAS memory - 3 simple ways                     */
/* ViyaPgm_04: List CAS in-memory tables                                     */
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
/*  Running a DATA Step in SAS9 (Compute Server)                             */
/*****************************************************************************/

data work.cars;
  set sashelp.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  Keep origin Make Model Type MSRP MPG_City MPG_Highway Average_MPG;
run;


/*****************************************************************************/
/*  Running a DATA Step in CAS Using CAS In-Memory Tables                    */
/*****************************************************************************/

data mycas.cars;
  set mycas.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  Keep origin Make Model Type MSRP MPG_City MPG_Highway Average_MPG;
run;


