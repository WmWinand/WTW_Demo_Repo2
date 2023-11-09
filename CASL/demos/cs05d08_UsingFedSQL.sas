**************************************************************;
* Demo 5.08: Executing SQL Queries in CAS Using FedSQL       *;
*   NOTE: If you have not setup the Autoexec file in         *;
*         SAS Studio, open and submit startup.sas first.     *;
**************************************************************;

**********;
* Step 1 *;
**********;
* Load the orders_clean.sashdat table *;
proc cas;
    table.loadtable / 
        path="orders_clean.sashdat", caslib="cs", 
        casout={name="orders", caslib="cs", replace=TRUE};
quit;



**********;
* Step 2 *;
**********;
* Simple query *;
proc cas;
   fedsql.execDirect /
       query="select * 
                  from cs.orders 
                  limit 10";
   table.columnInfo / table={name='orders', caslib='cs'};
quit;



**********;
* Step 3 *;
**********;
* Use SOURCE *;
proc cas;
    source q;
      select * 
         from cs.orders 
         limit 10;
    endsource;

    fedsql.execDirect / query=q;
quit;



**********;
* Step 4 *;
**********;
* Create a table from a query with a new calculated column TotalProfit *;
proc cas;
    source q;
      create table cs.total_profit as
      select Customer_ID, Customer_Group, Customer_Type, 
             Postal_Code, Quantity, RetailPrice, Cost, OrderType,
             RetailPrice - (Quantity*Cost) as TotalProfit
         from cs.orders 
         limit 10;
    endsource;

    fedsql.execDirect / query=q;

    table.fetch / table={name="total_profit", caslib="cs"};
quit;



**********;
* Step 4 *;
**********;
* Remove the limit clause and attempt to replace an in-memory table (error) *;
proc cas;
    source q;
      create table cs.total_profit as
      select Customer_ID, Customer_Group, Customer_Type, 
             Postal_Code, Quantity, RetailPrice, Cost, OrderType,
             RetailPrice - (Quantity*Cost) as TotalProfit
         from cs.orders;
    endsource;

    fedsql.execDirect / query=q;

    table.fetch / table={name="total_profit", caslib="cs"};
quit;



**********;
* Step 5 *;
**********;
* Replace an in-memory table *;
proc cas;
   source q;
      create table cs.total_profit{options replace=true} as
      select Customer_ID, Customer_Group, Customer_Type, 
             Postal_Code, Quantity, RetailPrice, Cost, OrderType,
             RetailPrice - (Quantity*Cost) as TotalProfit
         from cs.orders;
    endsource;

    fedsql.execDirect / query=q;

    table.fetch / table={name="total_profit", caslib="cs"};
quit;



**********;
* Step 6 *;
**********;
* Filter using a WHERE clause using double quotes (error) *;
proc cas;
    source q;
      create table cs.gold_members{options replace=true} as
      select Customer_ID, Customer_Group, Customer_Type, 
             Postal_Code, Quantity, RetailPrice, Cost, OrderType,
             RetailPrice - (Quantity*Cost) as TotalProfit
         from cs.orders
         where Customer_Group = "Orion Club Gold members";
    endsource;

    fedsql.execDirect / query=q;

    table.fetch / table={name="gold_members", caslib="cs"};
quit;



**********;
* Step 7 *;
**********;
* Filter using a WHERE clause with single quotes *;
proc cas;
    source q;
      create table cs.gold_members{options replace=true} as
      select Customer_ID, Customer_Group, Customer_Type, 
             Postal_Code, Quantity, RetailPrice, Cost, OrderType,
             RetailPrice - (Quantity*Cost) as TotalProfit
         from cs.orders
         where Customer_Group = 'Orion Club Gold members';
    endsource;

    fedsql.execDirect / query=q;

    table.fetch / table={name="gold_members", caslib="cs"};
quit;



**********;
* Step 8 *;
**********;
* Summarize data using a GROUP BY clause *;
proc cas;
    source q;
      create table cs.gold_members{options replace=true} as
      select OrderType,
            sum(RetailPrice - (Quantity*Cost)) as TotalProfit,
            count(*) as TotalOrders
         from cs.orders
         where Customer_Group = 'Orion Club Gold members'
         group by OrderType;
    endsource;

    fedsql.execDirect / query=q;

    table.fetch / table={name="gold_members", caslib="cs"};
quit;