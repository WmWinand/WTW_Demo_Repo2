/*****************************************************/
/* This program introduces basic changes needed       */
/* to migrate programs to Viya                       */
/*****************************************************/


/* PREVIOUS WINDOWS AND UNIX SAS LIBREF */
/* libname oldlibw "c:\MyDemos\data"; */
/* libname oldlibu "/home/sasdemo/WTW_Demo_Repo/data"; */

/* MODIFIED VIYA LIBREF */
libname newlibv '/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Git_Repo/data';


/* PREVIOUS DATA STEP USING OLD UNIX LIBREF */
/* data work.cars_usa; */
/*   set oldlibu.cars; */
/*     where origin = "USA"; */
/* run; */

/* MODIFIED DATA STEP USING NEW VIYA LIBEF */
data work.cars_usa;
  set newlibv.cars;
    where origin = "USA";
run;


/* LISTING REPORT */
proc print data=work.cars_usa (obs=10);
  var origin type make model;
run;


/* MODIFY HARDCODED PATHNAMES */
%let oldpathu /home/sasdemo/WTW_Demo_Repo/data;
%let newpathv /mnt/viya-share/homes/T.Winand@sas.com/Git_Repo/data;


/* PROC IMPORT - USING OLD UNIX PATHNAME */
/* proc import datafile="&oldpathu/cars1.xlsx" */
/*             dbms=xlsx */
/*             out=mydata.cars1 */
/*             replace; */
/* run; */

/* PROC IMPORT - USING NEW VIYA PATHNAME */
proc import datafile="&newpathv/cars1.xlsx"
            dbms=xlsx
            out=work.cars1
            replace;
run;


/* %include '/home/sasdemo/WTW_Demo_Repo/code/ExampleIncludePgm.sas'; */
%include '/mnt/viya-share/homes/T.Winand@sas.com/Git_Repo/SasStudio/Code/ExampleIncludePgm.sas';

/* x "ls" ; */
