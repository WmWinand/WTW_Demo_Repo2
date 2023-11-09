{"parameters":{"code":"/* Generated Code (IMPORT) */\n/* Source File: Stocks.xlsx */\n/* Source Path: /greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/Stocks.xlsx */\n/* Code generated on: May 3, 2022, 12:51:31 PM */\n\nproc sql;\n%if %sysfunc(exist(WORK.Stocks_I)) %then %do;\n    drop table WORK.Stocks_I;\n%end;\n%if %sysfunc(exist(WORK.Stocks_I,VIEW)) %then %do;\n    drop view WORK.Stocks_I;\n%end;\nquit;\n\n\n\nFILENAME REFFILE DISK '/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/Stocks.xlsx';\n\nPROC IMPORT DATAFILE=REFFILE\n\tDBMS=XLSX\n\tOUT=WORK.Stocks_I;\n\tGETNAMES=YES;\nRUN;\n\nPROC CONTENTS DATA=WORK.Stocks_I; RUN;\n\n\n","logHTML":"","resultsHTML":"","outputType":"TABLE","outputName":"Stocks_I","outputLocation":"WORK","fileName":"Stocks.xlsx","filePath":"/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/Stocks.xlsx","pathLabel":"/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Data/Stocks.xlsx","importPathLabel":"/greenmonthly-export/ssemonthly/homes/T.Winand@sas.com/Task/Import.ctl","fileType":"","fileSheet":"","fileTable":"","eolDelimiterOption":"default","colDelimiterOption":"","outputNameChangedByUser":true,"encoding":"UTF-8"},"type":"importObject","version":5.2}