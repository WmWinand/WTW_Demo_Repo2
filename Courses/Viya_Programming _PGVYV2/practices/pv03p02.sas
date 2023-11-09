*********************************************************;
* Lesson 3, Practice #2                                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data work.CustomerCounts;
    set pvbase.orders end=eof;
    if scan(customer_Group,3) ='Gold' then GoldCount+1;
    else if scan(customer_Group,1,' ') ='Internet/Catalog' then ICCount+1;
    else OtherCount+1;
    if eof then output;
    keep GoldCount ICCount OtherCount;
    label GoldCount='Total # Gold Memberships'
          ICCount='Total # Internet/Catalog Memberships'
          OtherCount='Total # Other Memberships';
run;

proc print data=work.CustomerCounts label;
    title 'Orion Star Club Membership Counts';
run;

