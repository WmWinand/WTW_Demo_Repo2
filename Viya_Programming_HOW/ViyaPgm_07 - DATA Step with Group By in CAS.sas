/*****************************************************************************/
/* ViyaPgm_07: Running a DATA Step with Group By in Viya (On the Compute     */
/* Server and in CAS)                                                        */
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
/*  Running a DATA Step with Group By in SAS9 (Compute Server)                */
/*****************************************************************************/
proc sort data=sashelp.cars out=sort_cars;
  by Type MSRP;
run;

data work.cars2;
  set sort_cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  keep Make Model Type Average_MPG MSRP LowMSRP HighMSRP;

  by Type;
  if first.Type then LowMSRP=1;
    else LowMSRP=0;
  if last.Type then HighMSRP=1;
    else HighMSRP=0;
run;


/*****************************************************************************/
/*  Running a DATA Step with Group By in CAS                                 */
/*****************************************************************************/
data mycas.cars2;
  set mycas.cars;

  Average_MPG=mean(MPG_City, MPG_Highway);
  keep Make Model Type Average_MPG MSRP LowMSRP HighMSRP;

  by Type MSRP;
  if first.Type then LowMSRP=1;
    else LowMSRP=0;
  if last.Type then HighMSRP=1;
    else HighMSRP=0;
run;

