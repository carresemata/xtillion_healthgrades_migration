# Iterate over ODS1Stage and script the spu_translated file to see if the UDFs are being used

import os
import re

def get_udf_usage():
    # Define UDF names and schemas
    dev_udf = ['DEV.CLEAN_JSON', 'DEV.JSON_TO_XML_2', 'DEV.P_JSON_TO_XML']
    base_udf = ['P_JSON_TO_XML']
    mid_udf = ['FNUREMOVESPECIALHEXADECIMALCHARACTERS']
    show_udf = ['CONSTRUCT_DICT', 'P_JSON_TO_XML', 'GETPIPESEPARATEDCITYSTATEALTERNATIVE']
    utils_udf = ['UTILS.P_JSON_TO_XML']

    # Define dictionary: {SCHEMA: [UDF]}
    udf_dict = {'Dev': dev_udf, 'Base': base_udf, 'Mid': mid_udf, 'Show': show_udf, 'Utils': utils_udf}

    # Define the base directories
    base_dirs = ['/Users/carrese/Desktop/xtillion_healthgrades_migration-1/migration_original/ODS1Stage/tables'
            ]

    for base_dir in base_dirs:
        # Navigate to the directory
        os.chdir(base_dir)

        # For each schema
        for schema in ['Base', 'Mid', 'Show']: # ['DEV', 'BASE', 'MID', 'SHOW', 'UTILS']
            os.chdir(f'{base_dir}/{schema}')
            print(f'- {schema} : ')

            # For each UDF in the schema verify if it appears in the 'translated' file
            for udf in udf_dict[schema]:
                print(f'--- {udf} : ')
                # For each table/view
                for table in os.listdir():
                    os.chdir(f'{base_dir}/{schema}/{table}')
                    # Check that the 'translated' file is not empty
                    if os.path.getsize(f'spu_translated_{table}.sql') != 0:
                        with open(f'spu_translated_{table}.sql', 'r') as f:
                            content = f.read()
                            # if udf in content, disregard the case
                            if re.search(udf, content, re.IGNORECASE):
                                print(f'     {table}')
                    os.chdir(f'{base_dir}/{schema}')
        os.chdir(base_dir)

        # Verify for all schemas if in the spu_translated file the UDF is being used from Dev and Utils, but dont search for these schemas as they dont exist
        # for udf in Dev or Utils
        for udf in udf_dict['Dev'] + udf_dict['Utils']:
            # print udf name, before .
            udf_schema = udf.split('.')[0]
            print(f'- {(udf_schema)}')
            print(f'--- {udf} : ')
            for schema in os.listdir():
                os.chdir(f'{base_dir}/{schema}')
                # For each table/view
                for table in os.listdir():
                    os.chdir(f'{base_dir}/{schema}/{table}')
                    # Check that the 'translated' file is not empty
                    if os.path.getsize(f'spu_translated_{table}.sql') != 0:
                        with open(f'spu_translated_{table}.sql', 'r') as f:
                            content = f.read()
                            # if udf in content, disregard the case
                            if re.search(udf, content, re.IGNORECASE):
                                print(f'     {table}')
                    os.chdir(f'{base_dir}/{schema}')
            os.chdir(base_dir)

get_udf_usage()