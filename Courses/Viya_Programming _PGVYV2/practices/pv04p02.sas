/*****************************************************
* Transposing an In-Memory Table in CAS: Practice #2 *
******************************************************/

proc transpose data=pvbase.qtr_sales out=qtr_sales_rotate(drop=_name_);
    var Sales;
    id Qtr;
    by Product_ID;
run;


