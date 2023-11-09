*********************************************************;
* Activity 4.05                                         *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc cas;
    table.addCaslib / 
        name="pvcas" path="&path/data";
    table.loadTable / 
        path=" " caslib=" ",
        casOut={caslib="casuser", name="custFrance", replace="true"},
        where=" ";
    table.tableDetails / 
        caslib="casuser", name="custFrance";
quit;
