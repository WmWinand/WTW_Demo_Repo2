**************************************************************;
* Demo 1.01: Exploring the Environment and Connecting to CAS *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

***********;
* Step 1  *;
***********;
* a. Explore the Environment with the AutoExec File *;
* b. View the course folder structure *;
* c. Commenting code *;
    * Comment 1 *;
    /* Comment 2 */


***********;
* Step 2  *;
***********;
* Terminate the CAS connection *;
cas conn terminate;

proc cas;
    session.sessionID;
quit;


***********;
* Step 3  *;
***********;
* Connect to CAS by executing the autoexec file *;
* 1. Press F9 *;
* 2. Options -> Reset the SAS session *;



***********;
* Step 4  *;
***********;
* Run a program to view CAS connections *;
proc cas;
    session.sessionID;
quit;



***********;
* Step 5  *;
***********;
***********************************************;
* Run a program to process and visualize data *;
***********************************************;

/* Process data in CAS and save as SAS data sets */
proc cas;
    cars={name="cars", caslib="casuser"};
    simple.summary / table=cars;
    simple.distinct result=d / table=cars;
    simple.freq result=ft / 
        table=cars,
        inputs={"Type","Origin"};

    print d ft;
    describe d ft;
  
    saveresult d.Distinct dataout=work.distinct;
    saveresult ft.Frequency dataout=work.frequency;
quit;



/* Visualize the Data */
%let textColor=cx768396;
%let textHeight=12pt;
%let fillColor=cx33a3ff;


title justify=left height=16pt color=&textColor "Number of Missing Values in the CARS Table by Column";
title2 "";
proc sgplot data=work.distinct 
            noborder;
    vbar Column / 
        response=NMiss
        nooutline 
        fillattrs=(color=&fillColor);
    xaxis valueattrs=(color=&textColor size=&textHeight)
          display=(nolabel);
    yaxis valueattrs=(color=&textColor size=&textHeight)
          labelattrs=(color=&textColor size=14)
          integer
          display=(nolabel);
quit;


title justify=left height=16pt color=&textColor "Number of Distinct Values in the CARS Table by Column";
title2 "";
proc sgplot data=work.distinct
            noborder;
    vbar Column / 
        response=NDistinct
        nooutline 
        fillattrs=(color=&fillColor);
    xaxis valueattrs=(color=&textColor size=&textHeight)
          display=(nolabel);
    yaxis valueattrs=(color=&textColor size=&textHeight)
          labelattrs=(color=&textColor size=14)
          integer
          display=(nolabel);
quit;

title justify=left height=16pt color=&textColor "Percent of Unique Values in the CARS Table";
title2 "";
proc sgpanel data=work.frequency;
    panelby Column / 
              spacing=40
              headerattrs=(color=&textColor size=&textHeight)
              noheaderborder noborder nowall novarname;
    vbar CharVar / 
        response=Frequency 
        stat=percent
        categoryorder=respdesc
        nooutline 
        fillattrs=(color=&fillColor);
    rowaxis valueattrs=(color=&textColor size=&textHeight)
            display=(nolabel);
    colaxis valueattrs=(color=&textColor size=&textHeight)
            labelattrs=(color=&textColor size=14)
            integer
            display=(nolabel);
quit;

title;