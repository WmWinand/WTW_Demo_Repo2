/* START A CAS SESSION */
CAS mySession SESSOPTS=(CASLIB=casuser TIMEOUT=99 LOCALE="en_US" metrics=true);


/* GRANT ACCESS TO GLOBAL CASLIBS & LIST CASLIBS */
caslib _all_ assign;
caslib _all_ list;


/* SETTING UP A CASLIB TO AND AWS S3 BUCKET */
caslib ms33 subdirs datasource=(srctype="s3"
               accesskeyid="AKIARPJ6X2NYDF5TYUFX"
               secretaccesskey="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"
               region="US_East"
               bucket="win562960andln"
               objectpath="wtw_files"
               usessl=false);


/* SETTING SAS LIBRARY REFERENCES TO CASLIBS SO THAT WE CAN USE IN DATA STEP, PROCS, ETC */
libname my_sas "/enable01-export/enable01-aks/homes/T.Winand@sas.com//Data";
libname my_ms33 cas caslib="ms33";
libname my_cas cas caslib="casuser";


/* USING PROC CASUTIL TO LIST SAVED FILES ASSOCIATED WITH CASLIBS AND IN-MEMORY TABLES */
proc casutil;
  list files incaslib="ms33";  /* files */
  list tables incaslib="ms33";  /* in-memory data */
quit;


/* USING PROC CASUTIL TO LOAD S3 CUSTOMERS TABLE IN PARQUET FORMAT INTO CAS MEMORY */ 
proc casutil;
	load casdata="customers.parquet" incaslib="ms33"
	casout="casCustomers" replace;
	load casdata="productorders.parquet" incaslib="ms33"
	casout="casProductOrders" replace;
quit;


/* LISTING FILES AND TABLES ASSOCIATED WITH OUR CASLIB */
proc casutil;
  list files incaslib="ms33";  /* files */
  list tables incaslib="ms33";  /* in-memory data */
quit;
 

/* LIST FIRST TEN ROWS OF EACH IN-MEMORY TABLE */
proc print data=my_ms33.casCustomers (obs=10);
run;

proc print data=my_ms33.casProductOrders (obs=10);
run;


/* CREATE SUMMARY TABLE FOR PRODUCT ORDERS */
PROC TABULATE DATA=my_ms33.casProductOrders 
              OUT=my_ms33.ProductOrderSum (LABEL="Summary Table for casProductOrders");
	
	VAR Quantity Total_Retail_Price;
	CLASS CustomerID /	ORDER=UNFORMATTED MISSING;
	TABLE /* Row Dimension */
CustomerID,
/* Column Dimension */
Quantity*
  Sum 
Total_Retail_Price*
  Mean 
Total_Retail_Price*
  Sum 		;
	;
RUN;


/* CREATE PRODUCT ORDER INDICATORS TABLE USING FEDSQL */
proc fedsql sessref=mySession;
create table ProductOrdersIndicators {options replace=true} as
      select casProductOrders.CustomerID,
             (COUNT(DISTINCT(casProductOrders.CustomerID))) AS ONE,
             (SUM(casProductOrders.Total_Retail_Price)) AS TotOrder,
             (CASE 
               WHEN 21 = casProductOrders.Product_Line THEN 'Childrens'
               WHEN 22 = casProductOrders.Product_Line THEN 'ClothesAndShoes'
               WHEN 24 = casProductOrders.Product_Line THEN 'Sports'
            END) AS ProdLineDesc 
      FROM casProductOrders
      GROUP BY casProductOrders.CustomerID, casProductOrders.Product_Line;

quit;


/* USE PROC TRANSPOSE TO CREATE PRODUCT LINE INDICATOR COLUMNS */
PROC TRANSPOSE DATA=my_ms33.ProductOrdersIndicators
	OUT=my_ms33.ProductLineCounts;
	BY CustomerID;

	ID ProdLineDesc;
	VAR ONE;

RUN;


/* USE PROC TRANSPOSE TO CREATE TOTALS COLUMNS FOR EACH PRODUCT LINE */
PROC TRANSPOSE DATA=my_ms33.ProductOrdersIndicators
	OUT=my_ms33.ProductLineTotals (LABEL="Split WORK.INDICATOR_VARIABLES");
	BY CustomerID;

	ID ProdLineDesc;
	VAR TOTORDER;

RUN; 
QUIT;


/* USE DATA STEP TO FILTER ORDERS FOR LAST TWO YEARS */
data my_ms33.OrderLastTwoYears;
  keep CustomerID;
  set my_ms33.casProductOrders;

  format Order_Date date9.;

  if Order_Date >= '01jan2006'd and Order_Date <= '31dec2007'd;

  run;


/* USE FEDSQL TO CREATE TARGET PURCHASE VAR */
PROC fedsql sessref=mySession;
   CREATE TABLE Create_Target {options replace=true} AS 
   SELECT casCustomers.Customer_ID, 
          OrderLastTwoYears.CustomerID, 
          casCustomers.CustomerCountryLabel, 
          casCustomers.Customer_Name, 
          casCustomers.Customer_BirthDate, 
          casCustomers.Customer_Type, 
          casCustomers.Customer_Group,
             (CASE 
               WHEN OrderLastTwoYears.CustomerID = . THEN 0
               ELSE 1
            END) AS Purchase 
      FROM casCUSTOMERS
           LEFT OUTER JOIN OrderLastTwoYears ON (casCustomers.Customer_ID = OrderLastTwoYears.CustomerID);
QUIT;


/* USE PROC FREQ TO DO A ONE WAY FREQUENCY ANALYSIS ON PURCHASE VAR */
ODS GRAPHICS ON;
PROC FREQ DATA=my_ms33.create_target;

;
	TABLES Purchase / NOCUM  SCORES=TABLE plots(only)=freq;
RUN;
ODS GRAPHICS OFF;


/* USE CAS ACTIONS TO DO THE SAME THING IN CAS */
proc cas; 
session mySession; 
    simple.freq /  
       inputs={'purchase'}  
       table={caslib='ms33', name='create_target',
       groupby={name='customer_group'}};           
quit; 


/* BUILD ANAYTICS READY TABLE */
proc fedsql sessref=mySession;
create table casCustomerAnalytics {options replace=true} as
      select create_target.Customer_ID,
             create_target.Customer_Name,
			 create_target.Customer_BirthDate,
			 (YRDIF(Create_Target.Customer_BirthDate, TODAY(), 'ACT/ACT')) as Customer_Age,
			 create_target.CustomerCountryLabel,		 
   			 create_target.Customer_Group,
			 create_target.Customer_Type,
			 create_target.purchase,

			 ProductOrderSum.quantity_sum as totitems,
             ProductOrderSum.total_retail_price_mean as avgspent,
			 ProductOrderSum.total_retail_price_sum as totspent,

			 ProductLineCounts.Childrens as Childrens_Items,
			 ProductLineCounts.ClothesAndShoes as ClothesAndShoes_Items,
             ProductLineCounts.Sports as Sports_Items,

			 ProductLineTotals.Childrens as Childrens_Spent,
			 ProductLineTotals.ClothesAndShoes as ClothesAndShoes_Spent,
             ProductLineTotals.Sports as Sports_Spent


      from ms33.Create_Target, ms33.ProductOrderSum, ms33.ProductLineCounts, ms33.ProductLineTotals
      where Create_Target.Customer_ID = ProductOrderSum.CustomerID and 
            Create_Target.Customer_ID = ProductLineCounts.CustomerID and
            Create_Target.Customer_ID = ProductLineTotals.CustomerID;

select * from casCustomerAnalytics;

quit;

data my_sas.customers;
  set my_ms33.casCustomers;
run;

data my_sas.productorders;
  set my_ms33.casProductOrders;
run;

data my_sas.CustomerAnalytics;
  set my_ms33.casCustomerAnalytics;
run;





/* RELEASE OUR TEMP TABLES FROM MEMORY */
proc casutil;
  droptable incaslib="ms33" casdata="casCustomers";
  droptable incaslib="ms33" casdata="casProductOrders";
  droptable incaslib="ms33" casdata="ProductOrderSum";
  droptable incaslib="ms33" casdata="ProductOrdersIndicators";
  droptable incaslib="ms33" casdata="ProductLineCounts";
  droptable incaslib="ms33" casdata="ProductLineTotals";
  droptable incaslib="ms33" casdata="OrderLastTwoYears";
  droptable incaslib="ms33" casdata="Create_Target";
quit;


/* USING PROC CASUTIL TO SAVE CUSTOMER ANALYTICS TABLE TO PERSISTENT STORAGE FOR MODELING */
proc casutil;
  save casdata="casCustomerAnalytics" incaslib="ms33"
      casout="CustomerAnalytics.parquet" replace;
quit;


/* LISTING FILES AND TABLES ASSOCIATED WITH OUR CASLIB */
proc casutil;
  list files incaslib="ms33";  /* files */
  list tables incaslib="ms33";  /* in-memory data */
quit;
 

/* SPECIFY MACRO VARS FOR DATA PREP AND MODELING */
/* Specify data sets */                  
%let casdata          = my_ms33.casCustomerAnalytics;
%let part_data        = my_ms33.CustomerAnalytics_part; 

/* Specify the data set inputs and target */
%let class_inputs    = CustomerCountryLabel Customer_Group Customer_Type Childrens_Items Sports_Items ClothesAndShoes_Items;
%let interval_inputs = avgspent totspent totitems customer_age CHILDRENS_SPENT sports_spent clothesandshoes_spent; 
%let target          = purchase;
%let cluster_inputs  = avgspent totspent totitems customer_age;

/* Specify a folder path to write the temporary output files */
%let outdir = &_SASWORKINGDIR; 


/* EXPLORE DATA */
proc cardinality data=&casdata outcard=my_ms33.data_card;
run;

proc print data=my_ms33.data_card(where=(_nmiss_>0));
  title "Data Summary";
run;

/* CLUSTER ANALYSIS */
proc kclus data=&casdata standardize=std distance=euclidean maxclusters=6;
  input &cluster_inputs. / level=interval;
run;


/* CREATE A PARTITION VARIABLE FOR MODELING */
proc partition data=&casdata partind samppct=70 seed=12345;
	by purchase;
	output out=&part_data;
run;

proc print data=&part_data (obs=10);
run;


/* RUN A SIMPLE TREE MODEL */
proc treesplit data=&part_data;
  input &interval_inputs. / level=interval;
  input &class_inputs. / level=nominal;
  target &target / level=nominal;
  partition rolevar=_partind_(train='1' validate='0');
  grow entropy;
  prune c45;
  code file="&outdir./treeselect_score.sas";
run;

proc casutil;
  droptable incaslib="ms33" casdata="casCustomerAnalytics";
  droptable incaslib="ms33" casdata="CustomerAnalytics_part";
  droptable incaslib="ms33" casdata="data_card";
quit;

/* CLOSE CAS SESSION */
cas mySession terminate;
