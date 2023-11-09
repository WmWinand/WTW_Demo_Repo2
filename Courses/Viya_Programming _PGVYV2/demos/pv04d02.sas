**********************************************************;
* Demo: Creating and Using Custom Formats                *;
*   NOTE: If you have not setup the Autoexec file in     *;
*         SAS Studio, open and submit startup.sas first. *;
**********************************************************;

proc format lib=work.formats casfmtlib="casformats";
    value typefmt 1="In-store"
                  2="Shipped"
                  3="Curbside";
run;

proc casutil;
    format OrderType typefmt.;                                     
    load data=pvbase.orders casout="orders" 
         outcaslib="casuser" replace;
    contents casdata="orders";
quit;

proc freqtab data=casuser.orders;
    tables OrderType;
run;