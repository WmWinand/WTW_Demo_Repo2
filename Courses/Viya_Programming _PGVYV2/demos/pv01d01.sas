*********************************************;
* Demo: Running a SAS Program in SAS Studio *;
*********************************************;

%let homedir=%sysget(HOME);
%let path=&homedir/Courses/PGVY01;

libname pvbase "&path/data";

data profit;
    set pvbase.orders;
    Profit=RetailPrice-(Cost*Quantity);
    format Profit dollar8.;
run;

ods excel file="&path/output/customer_report.xlsx";
title "Profit per Order";
proc means data=profit sum mean;
    var Profit;
    class Continent;
run;

proc sgplot data=profit;
    hbar Continent / response=Profit stat=sum 
                     categoryorder=respdesc;
run;
ods excel close;
