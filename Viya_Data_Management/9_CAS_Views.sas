/* CREATE A SIMPLE VIEW */

 mySession sessopts=(metrics=true) ;

options msglevel=i ;

/* Simple View */

/* Assign the CAS engine library to view the contents */
libname casdm cas caslib="dm" ;

/* Load order_fact */
proc casutil incaslib="dm" outcaslib="dm" ;
   dropTable casdata="order_fact" quiet ;
   load casdata="order_fact.sashdat" casout="order_fact" promote ;
   list tables ;
quit ;

/* Create a view on order_fact with a few columns and a computed variable */
proc cas ;
   table.dropTable / caslib="dm" name="order_fact_view" quiet=true ;
   table.view / caslib="dm" name="order_fact_view" promote=true
      tables={
         {
            caslib="dm",
            name="order_fact",
            varlist={"retail_transaction_type_cd","order_channel", "date_id", "item_rk","item_qty", "item_cost_amt", "list_price_amt"}
            computedVars={{name="saleAmount"}},
            computedVarsProgram="saleAmount=item_qty*item_cost_amt ;"
         }
      } ;
   table.tableInfo / caslib="dm" name="order_fact%" wildIgnore=false ;
quit ;

/* Perform a crosstab on the view */
proc cas ;
   simple.crosstab /
      row="retail_transaction_type_cd",
      col="order_channel",
      aggregator="SUM",
      weight="saleAmount",
      table={
         caslib="dm",
         name="order_fact_view"
      } ;
quit ;

/* Describe the view */
proc cas ;
   table.describeView / caslib="dm" name="order_fact_view" ;
quit ;




/* CREATE A STAR SCHEMA VIEW */

/* Star Schema View */

/* Assign the CAS engine library to view the contents */
libname caspgdvd cas caslib="dm_pgdvd" ;

/* Load 3 tables from the PostgreSQL dvdrental database */
proc casutil incaslib="dm_pgdvd" outcaslib="dm_pgdvd" ;
   dropTable casdata="film_actor" quiet ;
   dropTable casdata="film" quiet ;
   dropTable casdata="actor" quiet ;
   load casdata="film_actor" casout="film_actor" promote ;
   load casdata="film" casout="film" promote ;
   load casdata="actor" casout="actor" promote ;
   list tables ;
quit ;

/* Create a Star Schema view */
proc cas ;
   table.dropTable / caslib="dm_pgdvd" name="film_actor_view" quiet=true ;
   table.view / caslib="dm_pgdvd" name="film_actor_view" promote=true
      tables={
         {
            caslib="dm_pgdvd",
            name="film_actor",
            as="FACT"
         },
         {
            caslib="dm_pgdvd",
            name="actor",
            keys={"FACT_actor_id = ACTOR_actor_id"},
            as="ACTOR"
            varList={"first_name","last_name"}
         },
         {
            caslib="dm_pgdvd",
            name="film",
            keys={"FACT_film_id = FILM_film_id"},
            as="FILM",
            varList={"title"}
         }
      } ;
   table.tableInfo / caslib="dm_pgdvd" ;
quit ;

/* Print the first 100 records of the film titles and their actor names */
proc cas ;
   table.fetch / table={caslib="dm_pgdvd",name="film_actor_view",vars={{name="FILM_title"},{name="ACTOR_first_name"},{name="ACTOR_last_name"}}},
      sortBy={{name="FILM_title" order="ASCENDING"},{name="ACTOR_first_name" order="ASCENDING"},{name="ACTOR_last_name" order="ASCENDING"}}
      to=100 ;
quit ;

/* Describe the view */
proc cas ;
   table.describeView / caslib="dm_pgdvd" name="film_actor_view" ;
quit ;



cas mySession terminate;

