/* SIMPLE PROGRAM TO ILLUSTRATE USING DATA FROM S3 */

/* ********************************************************************************* */
/*                                                                                   */
/* NOTES:                                                                            */
/* This is merely an illustration of process steps.                                  */
/* Data in this example is not encrypted - there are options in PROC S3 to encrypt.  */
/* Another option would be to create and use a path based caslib.                    */
/*									                                                 */
/* ********************************************************************************* */

/* SET MACRO VARIABLES FOR AWS S3 PARAMETERS */
%let keyid = AKIARPJ6X2NYDF5TYUFX;
%let region = useast;
%let secret = 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;
%let s3_path = /win562960andln/wtw_files;


/* LIST FILES IN AWS S3 BUCKET FOLDER */
proc S3 KEYID="&keyid"
        REGION="&region"
        SECRET="&secret";

  list "&s3_path";
run;


/* COPY FILE FROM S3 TO LOCAL FOLDER */
proc S3 KEYID="&keyid"
        REGION="&region"
        SECRET="&secret";

  get "&s3_path./cars.csv" "/enable01-export/enable01-aks/homes/T.Winand@sas.com/S3_Data/cars.csv";
run;


/* COPY FOLDER FROM S3 TO LOCAL */
proc S3 KEYID="&keyid"
        REGION="&region"
        SECRET="&secret";

  getdir "&s3_path" "/enable01-export/enable01-aks/homes/T.Winand@sas.com/S3_Data";
run;


/* START A CAS SESSION */
cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");


/* SET SAS LIBRARY AND LIBREF TO CASLIB */
libname S3lib "/enable01-export/enable01-aks/homes/T.Winand@sas.com/S3_Data";
libname mycas cas caslib=casuser;


/* LOAD CARS.CSV TO CAS */
proc casutil;
    load file='/enable01-export/enable01-aks/homes/T.Winand@sas.com/S3_Data/cars.csv'
    casout='cars'
    outcaslib='casuser'
    importoptions=(filetype='csv' getnames=true)
    replace;
quit; 


/* LIST FILES AND IN-MEMORY TABLES IN CASLIB CASUSER */
proc casutil;
  list files incaslib=casuser;
  list tables incaslib=casuser;
run;


/* RUN DATA STEP IN CAS TO CREATE NEW CAS IN-MEMORY TABLE */
data mycas.cars_usa;
  set mycas.cars;

  if origin = "USA";
run;


/* CREATE SAS DATASET FROM CAS TABLE */ 
data S3lib.cars_USA;
  set mycas.cars_USA;
run;


/* COPY NEW DATASET UP TO S3 */
proc S3 KEYID="&keyid"
        REGION="&region"
        SECRET="&secret";

  put "/enable01-export/enable01-aks/homes/T.Winand@sas.com/S3_Data/cars_usa.sas7bdat" "&s3_path./cars_usa.sas7bdat"; 
run;


/* LIST FILES IN S3 FOLDER */
proc S3 KEYID="&keyid"
        REGION="&region"
        SECRET="&secret";

  list "&s3_path";
run;


/* TERMINATE CAS SESSION */
cas mySession terminate;












