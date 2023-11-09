/* ACCESSING EXISTING PARQUET FILES */

/* Accessing individual .parquet files */
libname pqt parquet 
	"/gelcontent/data/BIG_DATA_FORMATS/parquet/userdata2.parquet";

proc datasets lib=pqt;
quit;

proc contents data=pqt.data1;
	quit;

proc print data=pqt.data1(obs=10);
run;

proc sql;
	select count(*) from pqt.data1;
quit;

/* Accessing individual parquet files that have no extension */
libname pqt parquet "/gelcontent/data/BIG_DATA_FORMATS/parquet/userdata1" 
	file_name_extension=(_none_);

proc datasets lib=pqt;
quit;

proc contents data=pqt.part1;
	quit;

proc print data=pqt.part1(obs=10);
run;

proc sql;
	select count(*) from pqt.part1;
quit;

/* Accessing directories of parquet partitions (with or without the right extension) that share the same schema */
libname pqt parquet "/gelcontent/data/BIG_DATA_FORMATS/parquet" 
	directories_as_data=yes;

proc datasets lib=pqt;
quit;

proc contents data=pqt.userdata1;
	quit;

proc print data=pqt.userdata1(obs=10);
run;

proc sql;
	select count(*) from pqt.userdata1;
quit;

proc contents data=pqt."userdata2.parquet"n;
	quit;

proc print data=pqt."userdata2.parquet"n(obs=10);
run;

proc sql;
	select count(*) from pqt."userdata2.parquet"n;
quit;



/* CREATE A PARQUET DATASET */

/* Assign 2 libraries, including a parquet one, to the same folder */
libname sasdtm "/gelcontent/data/AppalachianChocolate_datamart";
libname pqtdtm parquet "/gelcontent/data/AppalachianChocolate_datamart";

/* Create a Parquet data set */
data pqtdtm.order_fact;
	set sasdtm.order_fact;
run;

/* Display table metadata */
proc contents data=pqtdtm.order_fact;
run;

/* Run a report on it */
proc tabulate data=pqtdtm.order_fact;
	var total_line_item_sale_amt item_qty;
	class order_channel order_type;
	table order_channel="", (total_line_item_sale_amt 
		item_qty)*order_type=""*sum="";
run;



/* EXPERIMENT WITH CALLBACK METHODS */

proc python;
	submit;
	SAS.submit("data prdsale ; set sashelp.prdsale ; run ;") 
		mytable=SAS.symget("SYSLAST") print("The last table I created is", mytable) 
		workpath=SAS.sasfnc("pathname", "work") 
		print("The SASWORK library points to", workpath) df=SAS.sd2df(mytable) 
		df.info() import pandas as pd import numpy as np pd.crosstab(df.COUNTRY, 
		df.YEAR, values=df.ACTUAL, aggfunc=np.sum) import requests 
		json_response=requests.get("http://api.open-notify.org/astros.json").json() 
		print("Response from the HTTP request:", json_response) 
		SAS.symput("nb_people_in_ISS", json_response["number"]) endsubmit;
run;

%put "Right now, there are &nb_people_in_ISS people in the ISS." ;



/* IMPORT AN AVRO FILE IN SAS */

proc python ;
   submit ;

import pandas
from fastavro import reader

fo = open('/gelcontent/data/BIG_DATA_FORMATS/avro/userdata_avro/userdata2.avro', 'rb')
records = [record for record in reader(fo)]
df = pandas.DataFrame.from_records(records)
df['registration_dttm'] = pandas.to_datetime(df['registration_dttm'])
ds = SAS.df2sd(df,"userdata")

   endsubmit ;
run ;



/* IMPORT A JSON FILE IN SAS */

proc python ;
   submit ;

import pandas as pd
import json
f = open("/gelcontent/data/BIG_DATA_FORMATS/json/smartFridges_brackets.json")
data = json.load(f)
df = pd.json_normalize(data, record_path=['Objects', 'Object', 'InfoItem', 'value'],
   meta=[['Objects', 'Object', 'id'],
       ['Objects', 'Object', 'type'],
       ['Objects', 'Object', 'InfoItem', 'name'],
       ['Objects', 'Object', 'InfoItem', 'description']])
df['dateTime'] = pd.to_datetime(df['dateTime'])
df.head()
df.info()
df.rename(columns = {
   'Text':'measure',
   'Objects.Object.id':'deviceId',
   'Objects.Object.type':'deviceType',
   'Objects.Object.InfoItem.name':'measureName',
   'Objects.Object.InfoItem.description':'measureDescription',
   'Objects.Object.InfoItem.name':'measureName'
   }, inplace = True)
df.info()
ds = SAS.df2sd(df,"smartFridges")

   endsubmit ;
run ;
