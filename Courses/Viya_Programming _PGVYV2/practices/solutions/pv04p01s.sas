*********************************************************;
* Lesson 4, Practice #1 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

 /* Part a. */
proc casutil;
    droptable casdata="employees" incaslib="casuser" quiet;
    load data=pvbase.employees outcaslib="casuser" casout="employees" promote;
quit;

 /* Parts b.-d. */
proc mdsummary data=casuser.employees;
    var Salary;
    output out=casuser.emp_summary;
    groupby Department;
run;

 /* Part e. */
proc mdsummary data=casuser.employees;
    var Salary;
    groupby Department / out=casuser.dept_summary;
    groupby Country / out=casuser.country_summary;
run;

 /* Part f. */
title "Average Salary by Country";
proc print data=casuser.country_summary(drop=Country_f _Column_);
    var Country--_mean_;
    format _M: dollar8.;
run;
title;
