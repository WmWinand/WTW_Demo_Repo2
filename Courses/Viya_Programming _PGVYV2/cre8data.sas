%let homedir=%sysget(HOME);

%let path=&homedir/PGVYV2_data;

filename cre8log "%qsysfunc(pathname(work))/cre8data.log";
proc printto log=cre8log;
run;

%macro casuserDelete;
    proc fedsql;
    drop table FileInfo force;
    quit;
   
    cas casauto;
    ods select FileInfo;
    ods output fileinfo=fileinfo;
    title "Residual Files to be Deleted from CASUSER";
    proc casutil;
        list files incaslib="casuser";
    run; quit;
    ods output close;
    %if %qsysfunc(exist(work.fileinfo)) %then %do;
    data _null_;
		  set fileinfo end=last;
		  call symputx(cats('file',_n_),name,'l');
		  if last then call symputx('nobs',_n_);
    run;
	
    proc casutil;
			%do i=1 %to &nobs;
            deletesource casdata="&&file&i" incaslib="casuser" quiet;
			%end;
    run; quit;
    %end;
    cas casauto terminate;
%mend;

%macro casuserCopyFrom(folder);
    %local rc did memname;
    %put NOTE: Copying files from &folder to CASUSER;
    %let rc=%sysfunc(filename(fileref,&folder));
    %if &rc ^=0 %then %do;
         %put ERROR: Cannot assignf fileref to %superq(folder).;
         %return;
    %end;
    %let did=%sysfunc(dopen(%superq(fileref)));
    %if &did=0 %then %do;
        %put ERROR: Directory %qupcase(%superq(folder)) does not exist.;
        %return;
    %end;

    cas mySession;
/*    caslib folder drop ; */
    caslib folder path="&folder";
    ods select FileInfo;
    title "Files loaded to CASUSER";
    proc casutil ;
        %do n=1 %to %qsysfunc(dnum(&did));
            %let memname=%qsysfunc(dread(&did,&n));
            load incaslib="folder"  outcaslib="casuser" casout ="table" casdata="&memname"  replace;
            save incaslib="casuser" outcaslib="casuser" casout ="&memname" casdata="table" replace;
            droptable incaslib="casuser" casdata="table";
        %end;
        %let didc=%qsysfunc(dclose(%superq(did)));
        %let rc=%qsysfunc(filename(fileref));
	     list tables incaslib="casuser";
	     list files incaslib="casuser";
    run; quit;
    caslib folder drop;
    cas mySession terminate;
%mend;

%casuserDelete

proc printto;
run;

filename cre8log clear;

%casuserCopyFrom(&path/data/copy-to-casuser)
