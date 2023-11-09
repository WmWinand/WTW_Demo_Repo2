/* DEMO */
%let path=/enable01-export/enable01-aks/homes/T.Winand@sas.com;

cas mySession sessopts=(caslib= casuser timeout=1800 locale="en_US");

libname myCasLib cas caslib=casuser;

proc casutil;
  load file="&path/Data/hmeq.csv" replace
  outcaslib="casuser" casout="hmeq";
run;
quit;

/* DATA PREPROCESSING */

/* replace missing values */
proc cas;
  loadactionset "dataPreprocess";
  action dataPreprocess.impute /
      table={name="hmeq"}
      methodContinuous="median"
      methodNominal="MODE"
      copyAllVars="true"
      inputs={"clage", "clno", "debtinc", "delinq", "derog", "job",
          "loan", "mortdue", "ninq", "reason", "value", "yoj"}  
      casout={name="indata", replace="true"};
  run;
quit;

proc cas;
  loadactionset "sampling";
  action sampling.srs /
      table={name="indata"}
      samppct=70
      seed=919
      partind=true
      output={casout= {name="indata", replace="true"}, copyvars="all"};
  run;
quit;

/* FEATURE SELECTION */

/* select features that expalin 90% of variance in data */

proc cas;
  loadactionset "varReduce";
  action varReduce.super /
      table={name="indata", where="_partind_=1"}
      target="bad"
      inputs={"imp_clage", "imp_clno", "imp_debtinc", "imp_delinq", "imp_derog", "imp_job",
              "imp_loan", "imp_mortdue", "imp_ninq", "imp_reason", "imp_value", "imp_yoj"}
      nominals={"imp_job", "imp_reason"}
      varexp=0.9;
  run;
quit;

/* TRAIN AND SCORE MACHINE LEARNING MODELS */

/* logistic regression model */

proc cas;
  loadactionset "regression";
  action regression.logistic /
      table={name="indata", where='_partind_=1'},
      classVars={"imp_job", "imp_reason"},
      model={depvar="bad",
             effects={"imp_clage", "imp_clno", "imp_debtinc", "imp_delinq", "imp_derog", "imp_job",
                     "imp_loan", "imp_mortdue", "imp_ninq", "imp_reason", "imp_value", "imp_yoj"},
             dist="binomial",
             link="logit"},
      store={name="lr_model", replace="true"};


  action regression.logisticScore /
       table={name="indata", where="_partind_=0"},
       restore="lr_model",
       casout={name="lr_scored", replace="true"},
       copyVars="bad";

  action datastep.runcode /  
       code="data lr_scored;
               set lr_scored;
               rename _PRED_ = P_BAD;
             ;
  run;

quit; 

proc cas;
  loadactionset "decisiontree";
  action decisiontree.dtreetrain /
      table={name="indata", where='_partind_=1'},
      target="bad",
      inputs={"imp_clage", "imp_clno", "imp_debtinc", "imp_delinq", "imp_derog", "imp_job",
                     "imp_loan", "imp_mortdue", "imp_ninq", "imp_reason", "imp_value", "imp_yoj"},
      nominals={"imp_job", "imp_reason"},
      casout={name="dt_model", replace="true"};

  action decisiontree.dtreeScore /
       table={name="indata", where='_partind_=0'},
       model="dt_model",
       casout={name="dt_scored", replace="true"},
       copyVars="bad",
       encodename="true",
       assessonerow="true";
  run;
quit;

proc cas;
  action decisiontree.gbtreetrain /
      table={name="indata", where='_partind_=1'},
      target="bad",
      inputs={"imp_clage", "imp_clno", "imp_debtinc", "imp_delinq", "imp_derog", "imp_job",
                     "imp_loan", "imp_mortdue", "imp_ninq", "imp_reason", "imp_value", "imp_yoj"},
      nominals={"imp_job", "imp_reason"},
      seed=1,
      casout={name="gb_model", replace="true"};

  action decisiontree.dtreeScore /
       table={name="indata", where='_partind_=0'},
       model="gb_model",
       casout={name="gb_scored", replace="true"},
       copyVars="bad",
       encodename="true",
       assessonerow="true";
  run;
quit;

proc cas;
  loadactionset "neuralNet";
  action neuralNet.annTrain /
      table={name="indata", where='_partind_=1'},
      target="bad",
      inputs={"imp_clage", "imp_clno", "imp_debtinc", "imp_delinq", "imp_derog", "imp_job",
                     "imp_loan", "imp_mortdue", "imp_ninq", "imp_reason", "imp_value", "imp_yoj"},
      nominals={"imp_job", "imp_reason"},
      hiddens={150},
      nloOpts={
               optmlOpt={maxIters=100, fConv=1e-10},
               lbfgsOpt={numCorrections=6}
              },
      casout={name="nn_model", replace="true"};

  action neuralNet.annScore /
       table={name="indata", where='_partind_=0'},
       model="nn_model",
       casout={name="nn_scored", replace="true"},
       copyVars="bad",
       encodename="true",
       assessonerow="true";

  run;
quit;

proc cas;
  loadactionset "percentile";
  action percentile.assess /
      table="lr_scored",
      inputs="P_BAD"
      casout={name="lr_assess", replace="true"},
      response="bad",
      event="1";

  action percentile.assess /
      table="dt_scored",
      inputs="P_BAD"
      casout={name="dt_assess", replace="true"},
      response="bad",
      event="1";

  action percentile.assess /
      table="gb_scored",
      inputs="P_BAD"
      casout={name="gb_assess", replace="true"},
      response="bad",
      event="1";

  action percentile.assess /
      table="nn_scored",
      inputs="P_BAD"
      casout={name="nn_assess", replace="true"},
      response="bad",
      event="1";
  run;
quit;

proc cas;
  action datastep.runcode /
      code="data lr_assess_ROC;
            set lr_assess_ROC;
            model='Logistic Regression';";

  action datastep.runcode /
      code="data dt_assess_ROC;
            set dt_assess_ROC;
            model='Decision Tree';";

  action datastep.runcode /
      code="data gb_assess_ROC;
            set gb_assess_ROC;
            model='Gradient Boosting';";

  action datastep.runcode /
      code="data nn_assess_ROC;
            set nn_assess_ROC;
            model='Neural Network';";

  action datastep.runcode /
      code="data assess_ROC;
            set lr_assess_ROC dt_assess_ROC gb_assess_ROC nn_assess_ROC;";
  run;
quit;

proc sgplot data=myCasLib.assess_roc noautolegend aspect=1;
  title 'ROC Curve (Target = BAD, Event = 1)';
  xaxis label='False positive rate' values=(0 to 1 by 0.1);
  yaxis label='True positive rate' values=(0 to 1 by 0.1);
  lineparm x=0 y=0 slope=1 /
            transparency=.7 LINEATTRS=(Pattern=34);
  series x=_FPR_ y=_sensitivity_ / group=model;
  keylegend / position=right;;
run;


cas mySession terminate;   
