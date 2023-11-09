/*****************************************************************************/
/* ViyaPgm_09: Creating and Using a User-Defined Formats in CAS              */
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
/* Creating and Using a User-defined Format in SAS9 (Compute Server)         */
/*****************************************************************************/
proc format;
  value pricerange_sas low-25000=”Low”
                       25000<-50000=”Mid”
                       50000<-75000=”High”
                       75000<-high=”Luxury”;
run;

data cars_formatted;
  set sashelp.cars;

  format MSRP pricerange_sas.;
  keep Make Model MSRP MPG_Highway;
run;

proc print data=cars_formatted;
run;


/*****************************************************************************/
/* Creating and Using a User-defined Format in CAS                           */
/*****************************************************************************/
proc format casfmtlib="casformats";
  value pricerange_cas low-25000=”Low”
                       25000<-50000=”Mid”
                       50000<-75000=”High”
                       75000<-high=”Luxury”;
run;

data mycas.cars_formatted;
 set sashelp.cars;

  format MSRP pricerange_cas.;
  keep Make Model MSRP MPG_Highway;
run;

proc mdsummary data=mycas.cars_formatted;
  var MPG_Highway;
  groupby MSRP / out=mycas.cars_summary;
run;

proc print data=mycas.cars_summary;
run;
