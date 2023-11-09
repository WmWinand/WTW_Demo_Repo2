/*****************************************************************************/
/* ViyaPgm_09: Analyze Data using SAS9 Procedures                            */
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
/*  Analyze Data Using SAS9 Procedures                                       */
/*****************************************************************************/
proc means data=mycas.cars chartype mean std min max n range vardef=df;
	var MSRP;
	output out=mycas.cars_means mean=std=min=max=n=range= / autoname;
	by Type;  
run;

proc print data=mycas.cars_means;
run;

