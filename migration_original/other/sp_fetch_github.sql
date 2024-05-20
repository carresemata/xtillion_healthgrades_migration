CREATE OR REPLACE PROCEDURE ODS1_STAGE_TEAM.PUBLIC.ODS1STAGE_FETCH_GITHUB(table_path STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
DECLARE
    repo_path STRING; -- path where we are going to compile (can point to an executable or directory)
    file_name STRING; -- variable used to store executable names in loop
    total_files INTEGER; -- to stop while loop 
    sql_command STRING; -- variable to store the final execution command
    counter INTEGER := 0; -- to track while loop iterations
    cur CURSOR FOR SELECT name FROM results; -- cursor for iterating through results
    
BEGIN

    repo_path := '%git_sample/branches/main/migration_original/ODS1Stage/tables/' || :table_path || '%';
    
    -- Refresh state of github repo
    ALTER GIT REPOSITORY git_sample FETCH;

    -- Create a temp table to store sql executable file names 
    LIST @git_sample/branches/main/migration_original/ODS1Stage/tables PATTERN='.*sql.*';

    CREATE OR REPLACE TEMPORARY TABLE results AS (
        SELECT "name" AS name,
        FROM TABLE(RESULT_SCAN(LAST_QUERY_ID())) -- this may be dangerous if last query is not LIST command
        WHERE name LIKE :repo_path
    );

    total_files := (SELECT COUNT(*) FROM results);
    
    OPEN cur;

    -- Loop through the result set to compile each sql executable file
    WHILE (counter < total_files) DO
        FETCH cur INTO file_name; 
        sql_command := 'EXECUTE IMMEDIATE FROM @' || file_name;
        EXECUTE IMMEDIATE sql_command;
        counter := counter + 1;
    END WHILE;

    CLOSE cur;

    RETURN repo_path;
END;
$$;