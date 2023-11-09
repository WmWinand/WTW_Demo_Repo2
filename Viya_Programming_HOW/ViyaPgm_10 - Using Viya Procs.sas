/*****************************************************************************/
/* ViyaPgm_10: Analyze Data using Viya Procedures                            */
/*****************************************************************************/

/*****************************************************************************/
/* RUN THIS CODE SECTION IF YOU DID NOT RUN ViyaPgm_01, ViyaPgm_02,          */
/* ViyaPgm_03, ViyaPgm_04, and ViyaPgm_05 PREVIOUSLY                         */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/* ViyaPgm_03: Load data into CAS memory - 3 simple ways                     */
/* ViyaPgm_04: List CAS in-memory tables                                     */
/* ViyaPgm_05: Running DATA Step in Viya                                     */
/* ViyaPgm_06: Running DATA Step with "BIG" Data in Viya                     */
/* ViyaPgm_07: Running a DATA Step with Group By in Viya                     */
/* ViyaPgm_08: Running a DATA Step using Partition and Orderby in CAS        */
/* ViyaPgm_09: Analyze Data using SAS9 Procedures                            */
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
/*  Analyze Data Using Viya Procedures                                       */
/*****************************************************************************/
proc mdsummary data=mycas.cars;
  groupby Type;
  var MSRP;
  output out=mycas.cars_mdsstats (replace=yes);
quit;

proc print data=mycas.cars_mdsstats;
run;


