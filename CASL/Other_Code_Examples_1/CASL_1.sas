%let path=/enable01-export/enable01-aks/homes/T.Winand@sas.com;

cas mySession sessopts=(caslib=casuser timeout=1800 locale="en_US");

proc cas;
 session mySession;
 session.sessionStatus result=r;
 print "Session status:";
 print "State: " r["state"];
 print "Connections: " r["number of Connections"];
 print "Timeout: " r["Timeout"] "minutes";
 print "Action Status: " r["ActionStatus"];
 print "Authenticated: " r["Authenticated"];
 print "Locale: " r["locale"];
quit;

proc cas;
 session mySession;
 builtins.serverStatus;
quit;

libname my_cas cas caslib="casuser";

proc casutil;
    load file="&path/Data/hmeq.csv"
    casout='hmeq'
    outcaslib='casuser'
    importoptions=(filetype='csv' getnames=true)
    replace;
quit; 

proc cas;
 table.columnInfo / table='hmeq';
 simple.summary result=rSum / table={name='hmeq', groupby='bad'};
 subSet={"MAX","MIN","MEAN","N"};
 describe rSum;
 print rSum["ByGroup2.Summary"];
run;

cas mySession terminate;
