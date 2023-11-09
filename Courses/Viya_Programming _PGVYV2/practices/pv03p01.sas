*********************************************************;
* Lesson 3, Practice #1                                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/*proc casutil; */
/*    droptable casdata="orders" incaslib="casuser" quiet; */
/*    load casdata="orders_hd.sashdat" incaslib="casuser"  */
/*         outcaslib="casuser" casout="orders" promote; */
/*quit; */

data work.CouponMailer;
    set pvbase.orders end=eof;
    if quantity in (1,2) then Discount=.15;
    else if quantity in (3,4) then discount=.20;
    else discount=.30;
    FullName=catx(' ', scan(Customer_Name,2,',')
                     , scan(Customer_Name,1));
    MailDate=mdy(12,day(Order_Date),year(today()));
    keep FullName City Postal_Code State_Province Discount MailDate;
    if eof then put _threadid_=   _N_=;
    format MailDate worddate.;
run;

