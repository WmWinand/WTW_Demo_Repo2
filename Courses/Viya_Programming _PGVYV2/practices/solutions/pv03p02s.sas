*********************************************************;
* Lesson 3, Practice #2 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data casuser.CustomerCounts;
    set casuser.orders end=eof;
    if scan(customer_Group,3) ='Gold' then GoldCount+1;
    else if scan(customer_Group,1,' ') ='Internet/Catalog' then ICCount+1;
    else OtherCount+1;
    if eof then output;
    keep GoldCount ICCount OtherCount;
run;

data casuser.CustomerCounts_Total / single=yes;
    set casuser.CustomerCounts end=eof;
    TotalGold+GoldCount;
    TotalIC+ICCount;
    TotalOther+OtherCount;
    keep Total:;
    if eof=1 then output;
    label TotalGold='Total # Gold Memberships'
          TotalIC='Total # Internet/Catalog Memberships'
          TotalOther='Total # Other Memberships';
    format Total: comma7.;
run;    

proc print data=casuser.CustomerCounts_Total label;
    title 'Orion Star Club Membership Counts';
run;

