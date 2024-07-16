CREATE OR REPLACE FUNCTION ODS1_STAGE_TEAM.UTILS.CLEAN_XML("INPUT" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS '
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(input, 
                        ''&'', ''&amp''),
                    ''<'', ''/lt''),
                ''>'', ''/gt''),
            ''"'', ''/quot''),
        '''''''', ''/apos'')
';