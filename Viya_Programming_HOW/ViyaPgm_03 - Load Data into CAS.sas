/*****************************************************************************/
/* ViyaPgm_03: Load data into CAS memory - 3 simple ways                     */
/*****************************************************************************/

/*****************************************************************************/
/* RUN THIS CODE SECTION IF YOU DID NOT RUN ViyaPgm_01 AND ViyaPgm_02        */
/* PREVIOUSLY                                                                */
/*                                                                           */
/* ViyaPgm_01: Create a CAS Connection & Start a CAS Session                 */
/* ViyaPgm_02: Create a SAS librefs for existing caslibs                     */
/*****************************************************************************/
/* options cashost="127.0.0.1" casport=5570; */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
caslib _all_ assign;
caslib _all_ list;
libname mycas cas caslib=casuser;


/*****************************************************************************/
/*  Three simple ways to load a SAS dataset into a CASLIB as a CAS in-memory */
/*  table                                                                    */
/*****************************************************************************/

data mycas.cars;
  set sashelp.cars;
run;

proc casutil;
  load data=sashelp.cars casout="cars" replace;
quit;

proc sql;
  create table mycas.cars as
    select * from sashelp.cars;
quit;
