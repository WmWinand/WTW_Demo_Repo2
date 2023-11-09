************************;
* Practice #3 SOLUTION *;
************************;

/* Part a. */
proc casutil;
    load casdata="sales.csv" casout="salesimport"
         importoptions=(filetype="csv" encoding="latin1" getnames="false") replace;
    contents casdata="salesimport";
quit;

/* Parts b.-c. . */
proc casutil;
    load casdata="sales.csv" casout="salesimport"
         importoptions=(filetype="csv"
                       encoding="latin1"
                       getnames="false"
                       vars=(
                          (name="ID", label="Identification Number", type="varchar"),
                          (name="First", label="First Name", type="varchar"),
                          (name="Last", label="Last Name", type="varchar"),
                          (name="Salary", label="Annual Salary",type="double"),
                          (name="JobTitle",label="Employee Job Title", type="varchar"),
                          (name="Country",label="Employee Country",type="varchar"),
                          (name="DOB", label="Birth Date"),
                          (name="HireDate",label="Date of Hire")
                          )
                          ) replace;
    contents casdata="salesimport";
quit;

/* Part d. */
options msglevel=i;
data casuser.salesimport_final(promote=yes);
    set casuser.salesimport;
    Birth_Date=input(DOB,date9.);
    Hire_Date=input(HireDate,mmddyy10.);
    format Birth_Date date9. Hire_Date mmddyy10.;
    drop DOB HireDate;
    label Birth_Date="Birth Date" Hire_Date="Date of Hire";
run;
options msglevel=n;

proc casutil;
    contents casdata="salesimport_final";
quit;



