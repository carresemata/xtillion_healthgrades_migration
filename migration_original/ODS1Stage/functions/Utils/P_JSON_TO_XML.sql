CREATE OR REPLACE FUNCTION ODS1_STAGE_TEAM.UTILS.P_JSON_TO_XML("COL" VARCHAR(16777216), "CUSTOM_ROOT" VARCHAR(16777216), "WRAPPER" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('dicttoxml')
HANDLER = 'udf'
AS '
import json
import xml.etree.ElementTree as ET
from dicttoxml import dicttoxml
import re 

def udf(col, custom_root, wrapper):

    col = col.replace(
            ''\\\\'', '''').replace(
            ''"{'', ''{'').replace(
            ''}"'', ''}'').replace(
            '', }'',''}'')
    # print(col)
    col_list = col.split(''>{'')
    for i in range(len(col_list)):
        if i == 0:
            continue
        substring = col_list[i]
        if ''{\\"'' in substring:
            closing_index = substring.rfind(''}<'')
            if closing_index != -1:
                old_string = substring[:closing_index+1]
                new_string = old_string.replace(''\\"'',''\\\\\\"'')
                col = col.replace(old_string,new_string)

    python_obj = json.loads(col)
    for dictionary in python_obj:
        for key, value in dictionary.items():
            if isinstance(value, dict):
                dictionary[key] = json.dumps(value)

    if not python_obj:
        return None

    xml = dicttoxml(python_obj, custom_root=''root'' if custom_root == '''' else custom_root, attr_type=False)
    xml_str = xml.decode()
    
    if wrapper == '''':
        xml_str = xml_str.replace(''<item>'', '''').replace(''</item>'', '''')
    else:
        xml_str = xml_str.replace(''<item>'', f''<{wrapper}>'').replace(''</item>'', f''</{wrapper}>'')
        
    xml_str = xml_str.replace(
            ''<?xml version="1.0" encoding="UTF-8" ?>'', '''').replace(
            ''<key name="">'', '''').replace(
            ''</key>'', '''').replace(
            ''&lt;'', ''<'').replace(
            ''&gt;'', ''>'').replace(
            ''&apos;'', ''\\'''').replace(
            ''&quot;'', ''\\"'')

    pattern = re.compile(r''<xml_\\d+>|<\\/xml_\\d+>'')
    xml_str = re.sub(pattern, '''', xml_str)

    if custom_root == '''':
        root = ET.fromstring(xml_str)
        
        xml_str = ''''.join(ET.tostring(e).decode() for e in root)
        
    return xml_str
';