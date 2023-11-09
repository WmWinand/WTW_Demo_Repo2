/*****************************************************************************/
/* ViyaPgm_14: Query Dataset using Proc SQL & CAS Table Using Proc FedSQL    */
/*****************************************************************************/

/*****************************************************************************/
/* This complete code uses the librayr sashelp.cars to look at US Cars       */
/* Fuel Efficiency and outputs to an Excel workbook with individual          */
/* Sheets for each make of car. Output is set to the Data folder of the      */
/* Viya Workshop.                                                            */
/*---------------------------------------------------------------------------*/
/* Auhor: Daniel Nelson  Date: 16JUN2021                                     */
/*****************************************************************************/

cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");
caslib _all_ assign;
caslib _all_ list;
libname mycas cas caslib=casuser;

proc casutil;
  load data=sashelp.cars casout="cars" replace;
quit;


/*****************************************************************************/
/*  Query SAS Dataset using Proc SQL and CAS Table Using Proc FedSQL         */
/*****************************************************************************/

%if not %sysfunc(exist(mycas.US_FuelEfficient_Cars)) %then %do;

	proc fedsql sessref=Mysession;
	create table casuser.US_FuelEfficient_Cars as
	   select Make
	        , Model
	        , MSRP
	        , put((MPG_City + MPG_Highway)/2, 9.2) as Average_MPG 
	     from casuser.cars
	     where (MPG_City + MPG_Highway)/2 > 25 
	       and Origin = 'USA'
	;
	quit;

%end;

/******************************************************************************/
/* Create Excel output file using the ODS Excel and Proc Report feature       */
/******************************************************************************/

ods _all_ close;

FILENAME fexport FILESRVC FOLDERPATH='/home/sasdemo/SAS Studio/DATA'
FILENAME='US_FuelEfficient_Cars.xlsx';

options formchar="|----|+|---+=|-/\<>*";
options nobyline;
	
ods excel file='/home/sasdemo/SAS Studio/DATA/fexport' options(embedded_titles = 'yes');


ods excel options(sheet_name='Report Discription'
                  start_at= '2,2'
                  gridlines='no');
                  
proc odstext;
	p "This report provides a listing of U.S. made autos" / style=[fontfamily=
	    'times' color=black fontsize=14pt just=left tagattr='mergeacross:6'];
	    
	p "as fuel efficient cars.  Each sheet is broken out by Make" 
	   / style=[fontfamily='times' color=black fontsize=14pt just=left 
	   tagattr='mergeacross:6'];
	
	p; /* blank line */
	
	p "The report and its individual sheets are created by using ODS EXCEL" 
		/ style=[fontfamily='times' color=black fontsize=14pt just=left 
	   tagattr='mergeacross:6'];
	   
	p "and the use of Proc Report.  Each sheet is set to an option of " 
	   / style=[fontfamily='times' color=black fontsize=14pt just=left 
	   tagattr='mergeacross:6'];
	   
	p "sheet_interval='bygroup' and sheet_name='#byval(make)'"
	  / style=[fontfamily='times' color=black fontsize=14pt just=left 
	   tagattr='mergeacross:6'];
run;

/* Create the individual sheets from the SAS Data in Excel Workbook           */

ods excel style=htmlblue options(sheet_interval='bygroup'
                                 sheet_name='#byval(make)'
                                 suppress_bylines='yes'
                                 start_at='1,1');
                                              
	proc report data=CASUSER.US_FUELEFFICIENT_CARS;
		
		by make;
		
		column	make
				model
				msrp
				average_mpg;
		
		/* Column A */
		define  Make	/	'Make' DISPLAY style(header)=[tagattr='rotate:90' 
									     BACKGROUNDCOLOR=lightblue 
									     BORDERBOTTOMCOLOR=BLACK 
									     BORDERBOTTOMSTYLE=SOLID 
									     BORDERBOTTOMWIDTH=0.2pt
									     height=75pt]
                                         style(column)=[textalign=left];
                                         
		/* COLUMN B */
    	DEFINE Model	/  'Model' DISPLAY style(header)=[tagattr='rotate:90'  
									     BACKGROUNDCOLOR=lightblue 
									     BORDERBOTTOMCOLOR=BLACK 
									     BORDERBOTTOMSTYLE=SOLID 
									     BORDERBOTTOMWIDTH=0.2pt
									     height=75pt]
                                         style(column)=[textalign=left]; 
                                         
		/* COLUMN C */
    	DEFINE MSRP 	/ 	'MSRP' DISPLAY style(header)=[tagattr='rotate:90'  
									     BACKGROUNDCOLOR=lightblue 
									     BORDERBOTTOMCOLOR=BLACK 
									     BORDERBOTTOMSTYLE=SOLID 
									     BORDERBOTTOMWIDTH=0.2pt
									     height=75pt]
                                         style(column)=[textalign=left]; 
                                         
		define average_mpg  / 'Average MPG' DISPLAY style(header)=
										[tagattr='rotate:90'  
									     BACKGROUNDCOLOR=lightblue 
									     BORDERBOTTOMCOLOR=BLACK 
									     BORDERBOTTOMSTYLE=SOLID 
									     BORDERBOTTOMWIDTH=0.2pt
									     height=75pt]
                                         style(column)=[textalign=left];                                         
	
run;

ods _all_ close;
ods listing;	

cas mySession terminate;


		
