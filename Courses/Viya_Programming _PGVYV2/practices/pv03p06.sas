*********************************************************;
* Lesson 3, Practice #6                                 *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/* proc casutil; */
/*     droptable casdata="orders" incaslib="casuser" quiet; */
/*     load casdata="orders_hd.sashdat" incaslib="casuser"  */
/* 	 outcaslib="casuser" casout="orders" promote; */
/* quit; */

proc sql;
create table orderDetail as
select Order_ID, ord.Product_ID, Product_Name, Product_Category,
       (Retailprice-(Cost*Quantity)) as Profit format=dollar12.2
    from pvbase.orders ord left join pvbase.products pc
    on pc.product_id=ord.product_id
    where calculated Profit > 0;
quit;