*****************************************************************;
* Demo 2.02: Creating and Using String and Numeric Variables    *; 
* NOTE: If you have not setup the Autoexec file in              *;
*       SAS Studio, open and submit startup.sas first.          *;
*****************************************************************;

**********;
* Step 1 *;
**********;
* Numeric variable *;

*****;
* a *;
*****;
* Simple numeric *;
proc cas;
   x=3;
   describe x;
   print x;
quit;


*****;
* b *;
*****;
* Variables are cleared at the end of the CAS procedure *;
proc cas;
    print x;
quit;


*****;
* c *;
*****;
* Print a string and numeric variable *;
proc cas;
   x=3;
   describe x;
   print "Value of x: " x;
quit;


*****;
* d *;
*****;
* Create a numeric variable with an expression *;
proc cas;
*Integer*;
   x=(5+7) * 10;
   describe x;
   print "Value of x: " x;
*Double*;
   x=(5+7) / 5;
   describe x;
   print "Value of x: " x;
quit;


*****;
* e *;
*****;
* Create a variable with the common MEAN function *;
proc cas;
   x=mean(10,20);
   describe x;
   print "Value of x: " x;
quit;



**********;
* Step 2 *;
**********;
* Character variable *;

*****;
* a *;
*****;
* Simple string variable *;
proc cas;
   y="Hello World";
   describe y;
   print y;
quit;

*****;
* b *;
*****;
* Concatenate two string variables using the bar operator *;
proc cas;
   x1="Hello";
   x2="World";
   print x1 || x2;
quit;


*****;
* c *;
*****;
* Concatenate two string variables using multiple methods *;
proc cas;
   x1="Hello";
   x2="World";
* Operator *;
   y=x1 || " " || x2;
   print y ;
* Function *;
   y=catx(" ",x1,x2);
   print y ;
quit;


*****;
* d *;
*****;
* Use the common UPCASE function *;
proc cas;
   x1="Hello";
   x2="World";
   y=upcase(x1 || " " || x2);
   print y;
quit;


*****;
* e *;
*****;
* Work with a string variables *;
proc cas;
   x1="Hello";
   x2="World";
   y=x1 || " " || x2;
* Obtain number of characters in the string *;
   totalNum=length(y);
* Describe multiple variables *;
   describe x1 x2 y totalNum;
   print "Total letters in variable y=" totalNum;
quit;



**********;
* Step 3 *;
**********;
* Use variables in CAS actions *;

*****;
* a *;
*****;
* CAS actions *;
proc cas;
   table.fetch / table="cars" to=5;
   simple.summary / table="cars";
   simple.numrows / table="cars";
quit;


*****;
* b *;
*****;
* Use variables as CAS action parameters *;
proc cas;
* Set up variables*;
   tblName="cars";
   numRows=5;
* CAS actions*;
   table.fetch / table=tblName, to=numRows;
   simple.summary / table=tblName;
   simple.numrows / table=tblName;
quit;