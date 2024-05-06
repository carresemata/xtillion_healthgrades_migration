import os
import json

def main():
    with open('table_levels.json', 'r') as f:
        data = json.load(f)
    with open('output.txt', 'w') as f:
        for level in data.keys():
            string = f"""
create or replace task ODS1_STAGE.DEV.ODS1_STAGE_TASK_LEVEL_{level}
warehouse=XITTILLION
schedule='1 MINUTE'
allow_overlapping_execution=true
as BEGIN
            """
            for table in data[level]:
                schema, table = table.split('.')
                string += f"""
CALL ODS1_STAGE.{schema}.SP_LOAD_{table}();
                """
            string += """
END;
            """
            f.write(string)

if __name__ == "__main__":
    main()