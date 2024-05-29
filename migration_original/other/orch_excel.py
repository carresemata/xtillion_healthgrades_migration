# go over the folder ODS1Stage/tables and safe all the names of the tables in a list

import os
import re
import openpyxl

def create_orc_excel():
    table_names = []
    base_dirs = [os.path.join(os.path.dirname(os.getcwd()), 'ODS1Stage/tables')]

    for base_dir in base_dirs:
        os.chdir(base_dir)
        for schema in os.listdir():
            os.chdir(schema)
            for table in os.listdir():
                os.chdir(table)
                # save all the names of the tables in the list
                table_names.append(f'{schema}.sp_load_{table}')
                
                os.chdir('..')
            os.chdir('..')
        os.chdir('..')
    # Sort alphabetically the list
    table_names.sort()
    
    # Create a new Excel workbook
    wb = openpyxl.Workbook()
    sheet = wb.active
    sheet.title = 'validation'
    
    # Specify the columns
    columns = ['Table Name', 'Validation Status', 'Sample Check', 'Aggregated Check', 'Owner', 'Notes']
    sheet.append(columns)
    
    # Fill the Table Name column with the table names
    for name in table_names:
        sheet.append([name, '', '', '', '', ''])
    
    # Save the Excel file in the other folder
    os.chdir(os.path.join(os.path.dirname(os.getcwd()), 'other'))
    wb.save('validation_status.xlsx')

create_orc_excel()