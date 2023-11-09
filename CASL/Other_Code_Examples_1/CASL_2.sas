cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

libname mycas cas caslib="casuser";

data mycas.heart;
  set sashelp.heart;
run;

proc cas ;
 tableinfo /table='heart'; /* 1 */
run;

columninfo result=r /table='heart'; /* 2 */
print r;
run;

simple.summary/table='heart'; /* 3 */
run;

partition / table={name='heart',
 compvars={'_fold_'},
 comppgm='call streaminit(__rankid*1000);_fold_=floor(rand("UNIFORM")*10);'}
 outtable={name='new_heart_with_fold', replace=True
};
run;

summary/ table='new_heart_with_fold' inputs={'_fold_'};
run;

distinct/ table='new_heart_with_fold', inputs={'_fold_'}; 
run; 

freq/ table='new_heart_with_fold', inputs={'_fold_'};
run;

columninfo result=r /table={name='new_heart_with_fold'};
run;

nVars=dim(r['columninfo'])-1;

i=4;
j=2;
xx= {r["columninfo"][1,1]}; /* 1 */
do while (i<=nVars); /* 2 */
 xx=xx + r["columninfo"][i,1];
 i=i+1;
 j=j+1;
end;
print xx;
run;

function OneFoldTree(nFold, iFold); /* 1 */
/* generate _fold_ where */
 foldwhere1 = "_fold_ NE " || (String)iFold;
 foldwhere2 = "_fold_ EQ " || (String)iFold;
 mymodel = "gbt_" || (String)iFold; /* 2 */
 decisiontree.gbtreetrain / /* 3 */
 table={name="new_heart_with_fold", where=foldwhere1}
 inputs=xx
 target="AgeAtDeath"
 casout={name=mymodel, replace=1}
 maxbranch=2
 maxlevel=8
 leafsize=60
 ntree=100
 binorder=1
 nbins=100
 seed=1234
 learningRate=0.1
 subsamplerate=0.7
 m=64
 ;
 decisionTree.gbtreescore result = r/ table={name='new_heart_with_fold',
 where=foldwhere2} model={name=mymodel}; /* 4 */
 print r;
 myscoredata = "gbtscore_" || (String)iFold; /* 5 */
 saveresult r replace dataset=myscoredata; /* 6 */
/* return prediction error; MSE or missclassification rate */
 return (r["ScoreInfo"][3,2]); /* 7 */
end func;

function KFoldCV(nFold); /* 1 */
 do i=1 to nFold; /* 2 */
 myerror[i] = OneFoldTree(nFold, i);
 end;
 return (myerror); /* 3 */
end func;

nFold = 10;
ModelError = KFoldCV(nFold);
run;

/*print error into log*/
print ModelError;
run;
quit;

/* mse = 0; /* 1 */
/* do i= 1 to nFold; /* 2 */
/*  mse = mse + ModelError[i]; */
/* end; */
/* run; */
/*  */
/* mse = mse/nFold; /* 1 */
/* rmse = sqrt(mse); */
/* print "mse=" mse "rmse=" rmse; */
/* run; */

cas mySession terminate;

