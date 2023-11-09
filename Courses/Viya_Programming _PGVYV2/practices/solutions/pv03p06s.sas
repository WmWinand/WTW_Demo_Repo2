*********************************************************;
* Lesson 3, Practice #6 SOLUTION                        *;
*   NOTE: If you have not setup the Autoexec file in    *;
*         SAS Studio, open and submit startup.sas first.*;
*********************************************************;

/* Uncomment and run this step if ORDERS is not loaded to the CASUSER caslib */
/* proc casutil; */
/*     droptable casdata="orders" incaslib="casuser" quiet; */
/*     load casdata="orders_hd.sashdat" incaslib="casuser"  */
/* 	 outcaslib="casuser" casout="orders" promote; */
/* quit; */

/* Part a. */
proc sql;
create table orderDetail as
select Order_ID, ord.Product_ID, Product_Name, Product_Category,
       (Retailprice-(Cost*Quantity)) as Profit format=dollar12.2
    from pvbase.orders ord left join pvbase.products pc
    on pc.product_id=ord.product_id
    where calculated Profit > 0;
quit;

/* Part b. */
proc casutil;
	load data=pvbase.products outcaslib="casuser" casout="products" replace;
quit;

proc fedsql sessref=mysession;
create table casuser.orderdetail{options replace=true} as
select ord.*, Product_Name, Product_Category, Product_Line, 
       Supplier_Name, Supplier_Country,
       (ord.Retailprice-(Cost*Quantity)) as Profit
    from casuser.orders ord left join casuser.products pc
    on pc.product_id=ord.product_id
    where (Retailprice-(Cost*Quantity)) > 0;
quit;

/* Part c. */
proc casutil;
    altertable casdata="orderdetail" incaslib="casuser"
        columns={{name="Profit" format="dollar12.2" label="Order Profit"}};
    contents casdata="orderdetail" incaslib="casuser";
quit; 

/* Part d. */
proc casutil;
    save casdata="orderdetail" casout="orderdetail" replace;
    list files;
quit;