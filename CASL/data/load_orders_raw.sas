proc cas;
   ordersTbl = {name="orders_raw", caslib="cs",replace=TRUE};
   table.loadTable result=rl/
      caslib="cs",
      path="orders_raw.sashdat"
      casout=ordersTbl
   ;
quit;
