*************************;
* Lesson 2, Practice #3 *;
*************************;

/* Part a. */
proc casutil;
    load casdata="sales.csv" casout="salesimport"
         importoptions=(filetype="csv" encoding="latin1" getnames="false") replace;
    contents casdata="salesimport";
quit;

/* Parts b.-c. */
proc casutil;
    load casdata="sales.csv" casout="salesimport"
         importoptions=(filetype="csv"
                       encoding="latin1"
                       getnames="false"
                       vars=(
                          (name="Id", label="Identification Number", type="varchar"),
                          (name="", label="", type=""),
                          (name="", label="", type=""),
                          (name="", label="",type=""),
                          (name="",label="", type=""),
                          (name="",label="",type="varchar"),
                          (name="", label=""),
                          (name="",label="")
                          )
                          ) replace;
    contents casdata="salesimport";
quit;

/* Part d. */
options msglevel=i;
data casuser.salesimport_final;
    set casuser.salesimport;
    Birth_Date=input(DOB,<informat>);
    Hire_Date=input(HireDate,<informat>.);
    format Birth_Date <format.> Hire_Date <format>.;


run;
options msglevel=n;

proc casutil;
    contents casdata="salesimport_final";
quit;



