-- hack_spuMAPFreeze
CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.SHOW.SP_LOAD_SOLRPROVIDER_FREEZE(is_full BOOLEAN) 
    RETURNS STRING
    LANGUAGE SQL
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrprovider_freeze depends on: 
--- show.webfreeze


---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------


    cleanup_1 string; -- cleanup for show.solrprovider_freeze
    cleanup_2 string; -- cleanup for show.webfreeze
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrprovider_freeze');
    execution_start datetime default getdate();


   
   
begin
    


---------------------------------------------------------
--------------- 3. select statements --------------------
---------------------------------------------------------     



---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

cleanup_1 := 'delete from
                show.solrprovider_Freeze
            where
                SponsorCode not IN (
                    select
                        ClientCode
                    from
                        show.webfreeze);';

            

cleanup_2 := 'delete from
                show.webfreeze
            where
                current_timestamp > FreezeEndDate;';


         

                   


---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRProvider_Freeze;
end if; 
execute immediate cleanup_1;
execute immediate cleanup_2;  
---------------------------------------------------------
--------------- 6. status monitoring --------------------
--------------------------------------------------------- 

status := 'completed successfully';
        insert into utils.procedure_execution_log (database_name, procedure_schema, procedure_name, status, execution_start, execution_complete) 
                select current_database(), current_schema() , :procedure_name, :status, :execution_start, getdate(); 

        return status;

        exception
        when other then
            status := 'failed during execution. ' || 'sql error: ' || sqlerrm || ' error code: ' || sqlcode || '. sql state: ' || sqlstate;

            insert into utils.procedure_error_log (database_name, procedure_schema, procedure_name, status, err_snowflake_sqlcode, err_snowflake_sql_message, err_snowflake_sql_state) 
                select current_database(), current_schema() , :procedure_name, :status, split_part(regexp_substr(:status, 'error code: ([0-9]+)'), ':', 2)::integer, trim(split_part(split_part(:status, 'sql error:', 2), 'error code:', 1)), split_part(regexp_substr(:status, 'sql state: ([0-9]+)'), ':', 2)::integer; 

            return status;
end;
