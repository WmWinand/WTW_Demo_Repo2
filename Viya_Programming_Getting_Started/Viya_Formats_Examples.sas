libname FMTSLIB "/home/sasdemo/WTW_Examples/SAS_Formats";


proc format library=fmtslib.class_fmts;
  value $gender_f
      'M' = 'Male'
      'F' = 'Female';
run;

proc format library=fmtslib.class_fmts;
  value height_f
      low - 55=”Short”
      55 <-65 =”Medium”
      65 <- high =”Tall”;
run;      
    

proc format library=fmtslib.class_fmts;
  value age_f
      low - 12=”Young”
      12 <-15 = ”In Between”
      15 <- high =”Old”;
run;      
 
options fmtsearch = (fmtslib.class_fmts); 

proc print data=sashelp.class;
  format sex $gender_f.;
  format age age_f.
  format height height_f.;
run;


/* This example shows you how to use the FORMAT procedure to migrate user-defined formats  */
/* from SAS to CAS using a temporary SAS data set. As in the previous example, it is assumed  */
/* that user-defined formats are stored in SAS format catalogs Work.formats and Orion.mailfmt. */

cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");    /*1*/

libname mycas cas caslib=casuser;

/* catname work.mycat(myfmts.formats orion.mailfmts); */  /*2*/

proc format library=fmtslib.class_fmts cntlout=temp;         /*3*/
run;

proc format cntlin=temp casfmtlib='mycasfmtlib';        /*4*/
run;

proc casutil;
  	load data=sashelp.class outcaslib='casuser'
	casout="casclass" replace;
quit;

proc print data=mycas.casclass;
  format sex $gender_f.;
  format age age_f.
  format height height_f.;
run;

cas mySession listformats fmtlibname=mycasfmtlib members; /*5*/

cas mySession savefmtlib fmtlibname=mycasfmtlib           /*6*/
   caslib=casuser table=mycasfmtlib replace;

/* catname work.mycat clear; */                            /*7*/

/* The CAS statement starts session Casauto. */

/* The CATNAME statement is used to combine catalogs Myfmts.Formats and Orion.Mailfmt into the Work.Mycat catalog. */
/*  */
/* The FORMAT procedure uses the combined catalog as input and creates a SAS data set on the SAS client that stores information about the formats. */
/*  */
/* The second PROC FORMAT step reads the SAS data set and adds a format library in your session that is named MyFmtLib. */
/*  */
/* The CAS statement with the LISTFORMATS and MEMBERS options lists the format libraries and their members for verfication. */
/*  */
/* Optional: The CAS statement with the SAVEFMTLIB option saves the format library as a SASHDAT file in caslib Casuser. */
/*  */
/* The CATNAME statement with the CLEAR option disassociates catref Work.Mycat. */


/* This example shows you how to use the FMTC2ITM procedure to migrate user-defined  */
/* formats that are stored in one or more SAS format catalogs to a format library in  */
/* your CAS session. In this example, it is assumed that user-defined formats are  */
/* stored in SAS format catalogs Work.formats and Orion.mailfmt. A format item-store  */
/* file is used to perform the migration. */

cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");                                 /*1*/

proc fmtc2itm                                /*2*/
   catalog=(fmtslib.class_fmts)
   itemstore="/home/sasdemo/WTW_Examples/SAS_Formats/ItemStoreA";
run;

cas mySession addfmtlib fmtlibname=mycasfmtlib    /*3*/
   path="/home/sasdemo/WTW_Examples/SAS_Formats/ItemStoreA"
   replacefmtlib;

cas mySession listformats fmtlibname=mycasfmtlib   /*4*/
   members;
   
cas mySession listformats scope=global members;
   
cas mySession terminate;   

/* The CAS statement starts session Casauto. */
/*  */
/* The FMTC2ITM procedure writes the formats in format catalogs Work.Formats and Orion.Mailfmts  */
/* to an item store file. */
/*  */
/* Note: Use a SELECT statement in the FMTC2ITM procedure step to select a subset of the formats  */
/* in the specified format catalogs. See SELECT Statement in Base SAS Procedures Guide. */
/* The CAS statement ADDFMTLIB option adds the formats in the item-store file that was created  */
/* by the FMTC2ITM procedure into CAS format library Myfmtlib. The PATH= option specifies the path  */
/* to the item-store file. */
/*  */
/* Note: Path-to-item-store-file must be readable from the control node of the server. */