*********************************************************;
* Lesson 4, Practice #3 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc cas;
    table.loadTable / 
        caslib="casuser",
        path="products.xlsx",
        casOut={caslib="casuser", name="products", replace=TRUE};
    simple.freq / 
    inputs={"Product_Line", "Supplier_Country"},
        table={caslib="casuser" name="products"};
quit;