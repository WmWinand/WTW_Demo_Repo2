**************************************************************;
* Demo 2.05: Working with CAS Action Results                 *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

***********;
* Step 1  *;
***********;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch / table=cars;
quit;



***********;
* Step 2  *;
***********;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch result=x / table=cars;
quit;



***********;
* Step 3  *;
***********;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch result=x / table=cars;
    describe x;
quit;



***********;
* Step 4  *;
***********;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch result=x / table=cars;
    describe x;
    print x.Fetch;
quit;



***********;
* Step 5  *;
***********;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch result=x / table=cars;

* Store the result table from the dictionary *;
    tbl = x.Fetch;

*View the result table  *;
    describe tbl;
    print tbl;
quit;



***********;
* Step 6  *;
***********;
proc cas;
    builtins.serverStatus;
quit;


***********;
* Step 8  *;
***********;
* Compare the serverStatus results and returned dictionary *;
proc cas;
    builtins.serverStatus;
quit;

proc cas;
    builtins.serverStatus result=x;
    describe x;
quit;



***********;
* Step 9  *;
***********;
* Access the Version key's value *;
proc cas;
    builtins.serverStatus result=x;

* Store the About dictionary from the action result *;
    dict = x.About;

* View the key-value pairs in the About dictionary *;
    describe dict;
    print dict;

* Access the CASVersion value *;
    CASVersion = x.About.Version;
    print "The Version of CAS is: " CASVersion;
quit;