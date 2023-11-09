**************************************************************;
* Demo 5.01: Updating a Table In Place                       *;
* NOTE: If you have not setup the Autoexec file in           *;
*       SAS Studio, open and submit startup.sas first.       *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Reload and preview the cars_raw.sas7bdat table *;
proc cas;
    cars_raw = {name="cars_raw", caslib="casuser"};

* Load client side file *;
    table.upload /
        path="&path/data/my_data/cars_raw.sas7bdat",
        casOut={name=cars_raw.name,
                caslib=cars_raw.caslib,
                replace=TRUE
        };

* Preview the in-memory table and caslib *;
    table.tableInfo / caslib=cars_raw.caslib;
    table.fetch / table=cars_raw;
    simple.freq / 
        table=cars_raw, 
        inputs={"Type", "Origin"};
quit;



**********;
* Step 2 *;
**********;
* Update a single column (error) *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

    table.update /
       table=cars_raw,
       set={var="Type", value="upcase(Type)"};
quit;



**********;
* Step 3 *;
**********;
* Update a single column *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

    table.update /
       table=cars_raw,
       set={
             {var="Type", value="upcase(Type)"} 
       };

* Preview the in-memory table *;
    table.fetch / table=cars_raw;
    simple.freq / 
        table=cars_raw, 
        inputs="Type";
quit;



**********;
* Step 4 *;
**********;
* Update multiple columns *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

    table.update /
       table=cars_raw,
       set={
             {var="Model", value="strip(Model)"} ,
             {var="Origin", value="ifc(upcase(Origin)='USA', upcase(Origin), propcase(Origin, ' '))"},
             {var="Type", value="ifc(upcase(Type)='SUV', upcase(Type), propcase(Type, ' '))"}
       };

* Preview the in-memory table *;
    table.fetch / table=cars_raw;
    simple.freq / 
        table=cars_raw, 
        inputs={"Type", "Origin"};
quit;



**********;
* Step 5 *;
**********;
* Using the SOURCE statement to update columns *;
proc cas;
    cars_raw={name="cars_raw", caslib="casuser"};

* IFC expression for Origin *;
    source updateOrigin;
       ifc(upcase(Origin)='USA', upcase(Origin), propcase(Origin, ' '));
    endsource;

* IFC expression for Type *;
    source updateType;
       ifc(upcase(Type)='SUV', upcase(Type), propcase(Type, ' '));
    endsource;

* Update cars_raw *;
    table.update /
       table=cars_raw,
       set={
             {var="Model", value="strip(Model)"},
             {var="Origin", value=updateOrigin},
             {var="Type", value=updateType}
       };

* Preview in-memory table *;
    table.fetch / table=cars_raw;
    simple.freq / 
        table=cars_raw, 
        inputs={"Type", "Origin"};
quit;



**********;
* Step 6 *;
**********;
* 5% Invoice discount for Toyota, Acura and Honda *;
proc cas;
    cars_raw={name="cars_raw", 
              caslib="casuser",
              where="Make in ('Toyota', 'Acura', 'Honda')"
    };

    table.update /
       table=cars_raw,
       set={
             {var="Invoice", value="Invoice*.95"}
       };
quit;



**********;
* Step 7 *;
**********;
* Can be done with CAS compliant DATA step *;
data casuser.cars_raw / sessref=conn;
    set casuser.cars_raw;
    Model=strip(Model);
    Origin=ifc(upcase(Origin)='USA', upcase(Origin), propcase(Origin, ' '));
    Type=ifc(upcase(Type)='SUV', upcase(Type), propcase(Type, ' '));
    if Make="Toyota" then Invoice=Invoice*.95;
run;

* View the CASL code sent to CAS *;
cas conn listhistory 12;