import requests
import pandas as pd



##
## CLEAN JSON DATA FUNCTION AND CREATE A PANDAS DATAFRAME
##

def createData(_censusJSON):
    
    # Obtain column names from the JSON file in the first row
    pop_data_col_names = _censusJSON.json()[0]
    
    # Make column names lowercase
    pop_data_col_names = [x.lower() for x in pop_data_col_names]
    
    # Obtain data from the JSON file. First row is headers
    pop_data = _censusJSON.json()[1:]
    
    # Create the dataframe and add the rows and columns
    df = pd.DataFrame(data = pop_data, columns = pop_data_col_names)
    
    # Prepare the DataFrame
    return (df
            .astype({'density_2021':'float',
                     'pop_2021':'int64',
                     'npopchg_2021':'int64'})
            .assign(
                population_pct_2021 = lambda _df: _df.pop_2021 / _df.pop_2021.sum()
                   )
    )



##
## REQUEST TO THE CENSUS API
##

# Folder path and file of the census api key CSV file. Information stored in the autoexec file.
census_API_key_csv_file = SAS.symget("census_api_key_path")

# Get the api key from the csv file and store it
api_key = pd.read_csv(census_API_key_csv_file, header = None).loc[0,0]

# API call for stat population data from the Census
parameters = {'get' : 'DENSITY_2021,POP_2021,NAME,NPOPCHG_2021',
              'for' : 'state',
              'key' : api_key}

census_url = SAS.symget("census_api_url")

JSONdata = requests.get(census_url, params = parameters, timeout = 5)



##
## CREATE A DATAFRAME WITH THE JSON FILE USING THE USER DEFINED FUNCTION
##

df = createData(JSONdata)

print('PREVIEW THE DATAFRAME')
print(df.dtypes, df)



##
## SEND THE DATAFRAME TO CAS SERVER AND/OR THE COMPUTER SERVER
##

# Send the data to the CAS server and promote the table to use SAS Visual Analytics
SAS.df2sd(df, 'casuser.pop2021_python_editor(PROMOTE=YES)')

# Send the data to the compute server
SAS.df2sd(df, 'work.pop2021_python_editor')