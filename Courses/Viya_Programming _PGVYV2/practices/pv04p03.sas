*********************************************************;
* Lesson 4, Practice #3                                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

proc cas;
    table.loadtable / 
        caslib= ,
        path= ,
        casOut={caslib="", name="", replace=};
    simple.freq / 
        table={},
        inputs={};
quit;