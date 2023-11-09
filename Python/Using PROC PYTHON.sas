****************************************************************;
* - Read the Census API Using the Python Requests Package      *;
* - Store the results as a SAS data set in the WORK library    *;
****************************************************************;
proc python;
submit;

import requests
import pandas as pd


##
## CREATE THE DATAFRAME FUNCTION 
##
def createData(_censusJSON):
    
    ## Obtain column names from the JSON file in the first row
    pop_data_col_names = _censusJSON.json()[0]
    
    ## Make column names lowercase
    pop_data_col_names = [x.lower() for x in pop_data_col_names]
    
    ## Obtain data from the JSON file. First row is headers
    pop_data = _censusJSON.json()[1:]
    
    ## Create the dataframe and add the rows and columns
    return pd.DataFrame(data = pop_data, columns = pop_data_col_names)



##
## REQUEST DATA FROM THE CENSUS API
##
census_API_key_csv_file = SAS.symget("census_api_key_path")

api_key = pd.read_csv(census_API_key_csv_file, header = None).loc[0,0]

parameters = {'get' : 'DENSITY_2021,POP_2021,NAME,NPOPCHG_2021',
              'for' : 'state',
              'key' : api_key}

census_url = SAS.symget("census_api_url")

JSONdata = requests.get(census_url, params = parameters, timeout = 5)



##
## CREATE THE DATAFRAME FROM THE JSON FILE
##
df = createData(JSONdata)
print(df)

##
## CONVERT THE PYTHON DATAFRAME TO A SAS DATA SET IN THE WORK LIBRARY
##
SAS.df2sd(df, 'work.population2021_sas_compute')


endsubmit;
quit;

******************************************************************;
* PREPARE THE DATA FOR SAS VISUAL ANALYTICS USING SAS            *;
******************************************************************;

*******************************************************************;
* 1. Calculate the Total Population and Store as a Macro Variable *;
*******************************************************************;
proc sql noprint;
	select sum(input(pop_2021,10.)) format=10.
		into :TotalPopulation trimmed
		from work.population2021_sas_compute;
quit;
%put &=TotalPopulation;


****************************************************************;
* 2. Prepare the table using the DATA step                     *;
****************************************************************;
data work.population_final_sas_compute;
	set work.population2021_sas_compute(rename=(density_2021 = char_density_2021 
                                                pop_2021 = char_pop_2021 
                                                npopchg_2021 = char_npopchang2021));
* Convert the columns to numeric *;
	density_2021 = input(char_density_2021,16.);
	pop_2021 = input(char_pop_2021,8.);
	npopchg_2021 = input(char_npopchang2021,7.);

* Find the population percentage for each state *;
	population_pct_2021 = pop_2021 / &TotalPopulation;

* Drop and format columns *;
	drop char:;
	format population_pct_2021 percent8.2 pop_2021 npopchg_2021 comma16.;
run;


****************************************************************;
* 3. Preview the table and table data types                    *;
****************************************************************;
proc contents data=work.population_final_sas_compute;
run;

proc print data=work.population_final_sas_compute(obs=10);
run;


********************************************************************;
* 4. Load the table to the CAS server to use SAS Visual Analytics  *;
********************************************************************;
%let cas_table_name = US_population_SAS;

proc casutil;
	* Drop the CAS table if it exists *;
	droptable casdata="&cas_table_name" incaslib = "casuser" quiet;

	* Load the SAS data set into the CAS server *;
	load data=work.population_final_sas_compute 
		 outcaslib='casuser' 
         casout="&cas_table_name"
         promote;
quit;
