/*****************************************************************************/
/* ViyaPgm_06: Running DATA Step with "BIG" Data in Viya (On the             */
/* Compute Server and In CAS)                                                */
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
/*  Running a DATA Step with Big Data in SAS9 (Compute Server)                */
/*****************************************************************************/
data bigcars;
  set sashelp.cars;

  do i=1 to 100000;
    output;
  end;
run;

data bigcars_score;
  set bigcars;

  length myscore 8;
  myscore=0.3*Invoice/(MSRP-Invoice)
    + 0.5*(EngineSize+Horsepower)/Weight + 0.2*(MPG_City+MPG_Highway);
run;


/*****************************************************************************/
/*  Running a DATA Step with Big Data in CAS                                 */
/*****************************************************************************/
data mycas.bigcars;
  set mycas.cars;

  do i=1 to 100000;
    output;
  end;
run
;

data mycas.bigcars_score;
  set mycas.bigcars;

  length myscore 8;
  myscore=0.3*Invoice/(MSRP-Invoice)
    + 0.5*(EngineSize+Horsepower)/Weight + 0.2*(MPG_City+MPG_Highway);
  Thread=_threadid_;
run;



