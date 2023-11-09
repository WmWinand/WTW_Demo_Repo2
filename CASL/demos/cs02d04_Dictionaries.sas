**************************************************************;
* Demo 2.04: Using Dictionaries with CAS Actions             *;
*   NOTE: If you have not setup the Autoexec file in         *;
*         SAS Studio, open and submit startup.sas first.     *;
**************************************************************;

***********;
* Step 1  *;
***********;
proc cas;
    table.fetch / table={name="cars", caslib="casuser"};
quit;



***********;
* Step 2  *;
***********;
* Use a dictionary variable in a action *;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch / table=cars;
quit;



***********;
* Step 3  *;
***********;
* Use a dictionary variable in multiple actions *;
proc cas;
    cars={name="cars", caslib="casuser"};
    table.fetch / table=cars;
    simple.distinct / table=cars;
    simple.numRows / table=cars;
quit;



***********;
* Step 4  *;
***********;
* Use a dictionary and an array in multiple actions *;
proc cas;
    cars={name="cars", caslib="casuser"};
    colNames={"Make", "Model", "MSRP"};
    table.fetch / 
      table=cars,
      fetchVars=colNames;
    simple.distinct / 
      table=cars,
      inputs=colNames;
    print "Total number of rows in cars";
    simple.numRows / table=cars;
quit;



***********;
* Step 5  *;
***********;
* Add a key-value pair to a dictionary for an action *;
proc cas;
* Set up variables *;
    cars={name="cars", caslib="casuser"};
    colNames={"Make", "Model", "MSRP"};

* CAS Actions *;
    table.fetch / 
      table=cars,
      fetchVars=colNames;
    simple.distinct / 
      table=cars,
      inputs=colNames;

* Total number of rows in cars *;
    print "Total number of rows in cars";
    simple.numRows / table=cars;

* Add a key-value pair to a dictionary *;
    cars["where"]="Make='Toyota'";
    print "Added the where key to the dictionary";
    print cars;
* Use the updated cars dictionary *;
    print "Number of rows where Make is Toyota";
    simple.numRows / table=cars;
quit;



***********;
* Step 6  *;
***********;
* Add a key-value pair to a dictionary temporarily *;
proc cas;
* Set up variables *;
    cars={name="cars", caslib="casuser"};

* Total number of rows in cars *;
    print "Total number of rows in cars";
    simple.numRows / table=cars;

* Add a key-value pair to a dictionary only for the action *;
    print "Number of rows where Make is Toyota";
    simple.numRows / table=cars || {where="Make='Toyota'"};

* View the cars dictionary *;
    print "View the key-value pairs in the cars dictionary";
    print cars;
quit;