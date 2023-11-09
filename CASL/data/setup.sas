/* Hide the log */
filename setup "&path/data/setup.log";
proc printto log=setup;
run;
/* Terminate any stray CAS sessions  */
proc cas;
session.listSessions result=rs;
saveresult rs dataout=work.sessions;
quit;

proc sql;
create table work.active as
   select * from work.sessions 
   where state='Connected'
;
quit;

%if &sqlobs >0 %then %do;
data _null_;
   set work.sessions;
   command=catx(' ',"cas ",scan(SessionName,1,':'),"uuid=",quote(UUID),";cas ",scan(SessionName,1,':')," terminate;");
/*    put command=; */
   call execute(command);
run;
%end;
* Create the correct CAS connection and set session options *;
cas conn;

proc cas;
* If CS caslib is not available in this session, create it *;
   table.queryCaslib result=r / caslib="cs";
   if r.cs=FALSE then do;
      table.addCaslib /
         caslib="cs"
         path="&path/data/cas"
      ;
   end;

* Set the required file names, cas table names, and file names *;
    requiredFiles={"sales.csv","sales.sas7bdat","heart_raw.sashdat","products.xlsx","orders_hd.sashdat"};
    casNames={"sales_csv","sale_sas7bdat","heart_raw_sashdat","products","orders"};
    fileNames={"sales.csv", "sales.sas7bdat", "heart_raw.sashdat","products.xlsx","orders_hd.sashdat"};
    field=0;

* Store all files in the casuser caslib in an array *;
    table.fileInfo result=fi / caslib="casuser";
    fileList=fi.FileInfo[,"Name"];

    do i over requiredFiles;
        field=field+1;

        if i==fileList then do;
             print "file:" || i || " exists in casuser";
        end;
        else do; 
        * Load the table into memory *;
             table.loadTable /
                path=tranwrd(i,"orders_hd.sashdat","orders_clean.sashdat"),
                caslib="cs",
                casOut={name=casNames[field], caslib="casuser", replace=TRUE};
        * Save the in-memory table as a data source file *;
             table.save /
                table={name=casNames[field], caslib="casuser"},
                name=fileNames[field], 
                caslib="casuser";
        * Drop the in-memory table *;
             table.dropTable / 
                name=casNames[field], 
                caslib="casuser";
        end;
    end;

* Check to see if the cars table exists in the casuser caslib. 
  Store the result in a macro variable *;
   table.tableExists result=r/
      caslib="casuser",
      name="cars"
   ;
   symputx("carsLoaded",r.exists);

* Check to see if the cars table exists in the casuser caslib.
  Store the result in a macro variable *;
   table.tableExists result=r/
      caslib="casuser",
      name="heart"
   ;
   symputx("heartLoaded",r.exists);

* Set the active caslib to the default casuser *;
   sessionProp.setSessOpt / caslib="casuser";
quit;


* Load the sashelp.cars table if it doesn't exist in memory *;
%if &carsLoaded=0 %then %do;
proc casutil;
   load data=sashelp.cars outcaslib="casuser" casout="cars" promote;
run;
%end;

* Load the sashelp.heart table if it doesn't exist in memory *;
%if &heartLoaded=0 %then %do;
proc casutil;
   load data=sashelp.heart outcaslib="casuser" casout="heart" promote;
run;
%end;

/* Clean up the SAS session */;
cas conn terminate;
proc datasets library=work kill nolist nodetails;
run; quit;
proc printto;run;
