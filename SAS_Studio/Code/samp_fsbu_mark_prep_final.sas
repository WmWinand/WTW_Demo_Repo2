/* cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=false); */
/* libname casuser cas caslib='casuser'; */
/* cas mySession terminate; */

/* STEPS:
     1. START A CAS SESSION
     2. CREATE CASLIBS TO DATA PATH AND TO SNOWFLAKE
     3. LOAD DATA INTO CAS: fin_camp_details(snow) fin_georegion_lookup fin_geocity_lookup fin_stats
     4. use fedsql query to join these tables
     5. add other dm steps from data plan
          Drop all STATS columns
          Remove duplicates across all columns
          GEO_CITY > Proper Case
	      Split CAMPAIGN on Fixed Length (3)
     6. save esulting table to VA accessible CASLIB
     7.  cleanup and test
*/


/* START A CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US" metrics=false);

/* PATH */
caslib mycas path="/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Git_Repo/Data" 
   datasource=(srctype="path");

/* SNOWFLAKE */
libname snow SASIOSNF 
	server="saspartner.snowflakecomputing.com"
	user=REPRUI 
	pw="{SAS002}B87C6F3C3D2FB7D53AC0FC1C"
	schema=REPRUI 
	preserve_tab_names=yes
	bulkload=yes 
	bulkunload=yes 
	bl_internal_stage="user/test1"
	;
libname mysas '/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data';
libname mycas cas caslib='mycas';
libname casuser cas caslib='casuser';

proc casutil;
	load data=snow.fin_camp_details outcaslib='casuser'
	casout="fin_camp_details" replace;

	load data=mysas.fin_geocity_lookup_s outcaslib='casuser'
	casout="fin_geocity_lookup" replace;

    load file="/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Git_Repo/Data/fin_stats.csv" outcaslib='casuser'
    casout="fin_stats" replace;
quit;

PROC FEDSQL SESSREF=mySession;
	CREATE TABLE casuser."fin_out" AS
		SELECT
			(t1."Campaign") AS "Campaign",
			(t1."acct_number") AS "acct_number",
			(t1."Vintage") AS "Vintage",
			(t1."p_date") AS "p_date",
			(t1."Closed_Date") AS "Closed_Date",
			(t1."Account_status") AS "Account_status",
			(t1."APR") AS "APR",
			(t1."Credit_Limit") AS "Credit_Limit",
			(t1."prod_color") AS "prod_color",
			(t1."profit_index") AS "profit_index",
			(t1."contact_cd") AS "contact_cd",
			(t1."segment_cd") AS "segment_cd",
			(t1."spend_index") AS "spend_index",
			(t1."Cr_Score") AS "Cr_Score",
			(t1."Debt_Income") AS "Debt_Income",
			(t1."Account_Count") AS "Account_Count",
			(t1."Closed_Ind") AS "Closed_Ind",
			(t1."LOC") AS "LOC",
			(t1."TCL") AS "TCL",
			(t1."Income") AS "Income",
			(t1."Account_Age") AS "Account_Age",
			(t1."os_bal") AS "os_bal",
			(t1."Trans_Amount") AS "Trans_Amount",
			(t1."Trans_count") AS "Trans_count",
			(t1."Geo_City") AS "Geo_City",
			(t2."Total") AS "Total",
			(t2."AllocProportion") AS "AllocProportion",
			(t2."SampleSize") AS "SampleSize",
			(t2."ActualProportion") AS "ActualProportion",
			(t2."SelectionProb") AS "SelectionProb",
			(t2."SamplingWeight") AS "SamplingWeight",
			(t3."Geo_Region") AS "Geo_Region",
			(t3."Geo_Region_Lat") AS "Geo_Region_Lat",
			(t3."Geo_Region_Lon") AS "Geo_Region_Lon",
			(t3."Geo_State") AS "Geo_State",
			(t3."Geo_City_Lat") AS "Geo_City_Lat",
			(t3."Geo_City_Lon") AS "Geo_City_Lon"
		FROM
			CASUSER."FIN_CAMP_DETAILS" t1
				INNER JOIN CASUSER."FIN_STATS" t2 ON (t1."RecID" = t2."RecID")
				INNER JOIN CASUSER."FIN_GEOCITY_LOOKUP" t3 ON (t1."Geo_City" = t3."Geo_City")
	;
QUIT;
RUN;
PROC CASUTIL SESSREF=mySession;
ALTERTABLE CASDATA="fin_out" INCASLIB=casuser
COLUMNS={
{
NAME="Campaign",
FORMAT="$24."},
{
NAME="Vintage",
FORMAT="DATE9."},
{
NAME="p_date",
FORMAT="DATE9."},
{
NAME="Closed_Date",
FORMAT="$3."},
{
NAME="Account_status",
FORMAT="$3."},
{
NAME="Credit_Limit",
FORMAT="$36."},
{
NAME="prod_color",
FORMAT="$24."},
{
NAME="profit_index",
FORMAT="$3."},
{
NAME="contact_cd",
FORMAT="$3."},
{
NAME="segment_cd",
FORMAT="$12."},
{
NAME="spend_index",
FORMAT="$6."},
{
NAME="Debt_Income",
FORMAT="$9."},
{
NAME="TCL",
FORMAT="$30."},
{
NAME="Income",
FORMAT="$30."},
{
NAME="os_bal",
FORMAT="$39."},
{
NAME="Trans_Amount",
FORMAT="$36."},
{
NAME="Geo_City",
FORMAT="$33."},
{
NAME="Total",
FORMAT="BEST12."},
{
NAME="AllocProportion",
FORMAT="BEST12."},
{
NAME="SampleSize",
FORMAT="BEST12."},
{
NAME="ActualProportion",
FORMAT="BEST12."},
{
NAME="SelectionProb",
FORMAT="BEST12."},
{
NAME="SamplingWeight",
FORMAT="BEST12."},
{
NAME="Geo_Region",
FORMAT="$4."},
{
NAME="Geo_Region_Lat",
FORMAT="BEST12."},
{
NAME="Geo_Region_Lon",
FORMAT="BEST12."},
{
NAME="Geo_State",
FORMAT="$2."},
{
NAME="Geo_City_Lat",
FORMAT="BEST12."},
{
NAME="Geo_City_Lon",
FORMAT="BEST12."}};
QUIT;
RUN;


data casuser.samp_fsbu_mark;
  set casuser.fin_out (drop=Total AllocProportion SampleSize ActualProportion
                       SelectionProb SamplingWeight);

  city=propcase(geo_city);
  LEFT_Campaign = substr(Campaign,1,3);
  RIGHT_Campaign = substr(Campaign,4);
run;

proc casutil;
  save incaslib='casuser' casdata='samp_fsbu_mark' outcaslib='mycas' casout='samp_fsbu_mark.csv';

  promote incaslib='casuser' casdata='fin_camp_details' outcaslib='casuser';
  promote incaslib='casuser' casdata='fin_geocity_lookup' outcaslib='casuser';
  promote incaslib='casuser' casdata='fin_stats' outcaslib='casuser';
  promote incaslib='casuser' casdata='samp_fsbu_mark' outcaslib='casuser';



  list files incaslib='casuser';
  list tables incaslib='casuser';
quit;

ods html close;

title1 'PowerPoint Example - Listing Report';
footnote "The ODS Output Destination for PowerPoint";

ods powerpoint file="/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/fsbu_example.pptx";
  proc print data=casuser.samp_fsbu_mark obs=10;
  run;
ods _all_ close;

cas mySession terminate;