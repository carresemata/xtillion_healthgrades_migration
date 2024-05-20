CREATE OR REPLACE PROCEDURE PUBLIC.ODS1STAGE_FETCH_GITHUB()
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    file_name STRING;
    total_files INTEGER;
    sql_command STRING;
    counter INTEGER := 0;
    cur CURSOR FOR SELECT name FROM results; -- cursor for iterating through results
    
BEGIN
    -- Refresh state of github repo
    ALTER GIT REPOSITORY git_sample FETCH;

    -- Create a temp table to store sql executable file names 
    LIST @git_sample/branches/main/migration_original/ODS1Stage/tables PATTERN='.*sql.*';

    CREATE OR REPLACE TEMPORARY TABLE results AS (
        SELECT "name" AS name,
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) -- this may be dangerous if last query is not LIST command
    );

    total_files := (SELECT COUNT(*) FROM results);
    
    OPEN cur;

    -- Loop through the result set to compile each stored procedure
    WHILE (counter < total_files) DO
        FETCH cur INTO file_name; 
        sql_command := 'EXECUTE IMMEDIATE FROM @' || file_name;
        EXECUTE IMMEDIATE sql_command;
        counter := counter + 1;
    END WHILE;

    CLOSE cur;

    RETURN 'Succesfully compiled stored procedures';
END;
$$;