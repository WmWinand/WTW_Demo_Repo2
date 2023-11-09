cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

caslib _all_ list;

caslib _all_ assign;

/* Define a CAS engine libref for CAS in-memory data tables */
libname mycas cas caslib=casuser;


/* LOAD HMEQ INTO CAS S IF NOT ALREADY THERE */
/* %if not %sysfunc(exist(mycas.hmeq)) %then %do; */
/*  */
/*   proc casutil; */
/*     load data=sampsio.hmeq casout="hmeq" outcaslib=casuser; */
/*   run; */
/*  */
/* %end; */

/* LOAD CSV FILE TO CAS USING PROC CASUTIL */
proc casutil;
    load file='/home/sasdemo/WTW_Examples/Data/hmeq.csv'
    casout='hmeq'
    outcaslib='casuser'
    importoptions=(filetype='csv' getnames=true)
    replace;
quit;  

/* SPECIFY MACRO VARS FOR DATA PREP */
/* Specify the data set names */
%let sasdata          = sampsio.hmeq;                     
%let casdata          = mycas.hmeq;

/* Specify the data set inputs and target */
%let class_inputs    = reason job;
%let interval_inputs = clage clno debtinc loan mortdue value yoj derog delinq ninq; 
%let target          = bad;

%let im_class_inputs    = reason job;
%let im_interval_inputs = im_clage clno im_debtinc loan mortdue value im_yoj im_ninq derog im_delinq; 
%let cluster_inputs     = im_clage im_debtinc value;

/* Specify a folder path to write the temporary output files */
%let outdir = 'home/sasdemo/WTW_Examples/Data';


/* EXPLORE DATA & PLOT MISSING VALUES */
proc cardinality data=&casdata outcard=mycas.data_card;
run;

proc print data=mycas.data_card(where=(_nmiss_>0));
  title "Data Summary";
run;

data data_missing;
  set mycas.data_card (where=(_nmiss_>0) keep=_varname_ _nmiss_ _nobs_);
  _percentmiss_ = (_nmiss_/_nobs_)*100;
  label _percentmiss_ = 'Percent Missing';
run;

proc sgplot data=data_missing;
  title "Percentage of Missing Values";
  vbar _varname_ / response=_percentmiss_ datalabel categoryorder=respdesc;
run;
title;


/* IMPUTE MISSING VALUES */
proc varimpute data=&casdata;
  input clage /ctech=mean;
  input delinq /ctech=median;
  input ninq /ctech=random;
  input debtinc yoj /ctech=value cvalues=50,100;
  output out=mycas.hmeq_prepped copyvars=(_ALL_);
run;
    
    
/* ID VARS THAT EXPLAIN VARIANCE IN TARGET */
/* Discriminant analysis for class target */
proc varreduce data=mycas.hmeq_prepped technique=discriminantanalysis;  
  class &target &im_class_inputs.;
  reduce supervised &target=&im_class_inputs. &im_interval_inputs. / maxeffects=8;
  ods output selectionsummary=summary;	     
run;

data out_iter (keep=Iteration VarExp Base Increment Parameter);
  set summary;
  Increment=dif(VarExp);
  if Increment=. then Increment=0;
  Base=VarExp - Increment;
run;

proc transpose data=out_iter out=out_iter_trans;
  by Iteration VarExp Parameter;
run;

proc sort data=out_iter_trans;
  label _NAME_='Group';
  by _NAME_;
run;


/* ITERATION PLOT TO EXPLAIN VARIANCE */
proc sgplot data=out_iter_trans;
  title "Variance Explained by Iteration";
  yaxis label="Variance Explained";
  vbar Iteration / response=COL1 group=_NAME_;
run;
title;



/* CLUSTER ANALYSIS BASED ON DEMOG INPUTS */
proc kclus data=mycas.hmeq_prepped standardize=std distance=euclidean maxclusters=6;
  input &cluster_inputs. / level=interval;
run;


/* CREATE A PARTITION VARIABLE FOR MODELING */
proc partition data=mycas.hmeq_prepped partind samppct=70 seed=12345;
	by BAD;
	output out=mycas.hmeq_part;
run;

proc print data=mycas.hmeq_part (obs=10);
run;


/* DECISION TREE */
proc treesplit data=mycas.hmeq_part;
  input &interval_inputs. / level=interval;
  input &class_inputs. / level=nominal;
  target &target / level=nominal;
  partition rolevar=_partind_(train='1' validate='0');
  grow entropy;
  prune c45;
run;


/* CLEAN UP */
proc casutil;
  list tables;
run;  

proc casutil;
  save casdata="hmeq_part" replace;
run;  


proc casutil;
   droptable casdata="hmeq_part" incaslib="casuser";
run;
quit;

cas mySession terminate;