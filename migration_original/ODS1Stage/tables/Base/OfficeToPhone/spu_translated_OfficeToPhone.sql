CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_OFFICETOPHONE(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  

declare 

---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
-- base.officetophone depends on:
--- mdm_team.mst.office_profile_processing 
--- base.office
--- base.phonetype
--- base.phone

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------
select_statement string;
insert_statement string;
merge_statement string;
update_statement string;
status string;
procedure_name varchar(50) default('sp_load_officetophone');
execution_start datetime default getdate();
mdm_db string default('mdm_team');


begin


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------

    -- select Statement
    select_statement := $$   with CTE_Phone AS (
                            SELECT
                                p.ref_office_code AS officecode,
                                TO_VARCHAR(json.value: PHONE_NUMBER) AS Phone_PhoneNumber,
                                TO_VARCHAR(json.value: PHONE_TYPE_CODE) AS Phone_PhoneTypeCode,
                                TO_VARCHAR(json.value: DATA_SOURCE_CODE) AS Phone_SourceCode,
                                TO_TIMESTAMP_NTZ(json.value: UPDATED_DATETIME) AS Phone_LastUpdateDate
                            FROM $$ || mdm_db || $$.mst.office_profile_processing AS p,
                                 LATERAL FLATTEN(input => p.OFFICE_PROFILE:PHONE) AS json
                        )
                        select 
                            pt.phonetypeid,
                            p.PhoneId,
                            o.officeid,
                            ifnull(json.phone_SOURCECODE , 'Reltio') as SourceCode,
                            ifnull(json.phone_LASTUPDATEDATE , current_timestamp()) as LastUpdateDate,
                            1 as PhoneRank
                        from cte_phone as JSON
                            join base.office as O on o.officecode = json.officecode
                            join base.phonetype as PT on pt.phonetypecode = json.phone_PHONETYPECODE
                            join base.phone as p on p.phonenumber = json.phone_phonenumber and p.sourcecode = json.phone_sourcecode
                        qualify row_number() over(partition by OfficeID, json.phone_PHONENUMBER, PhoneTypeID order by json.phone_LASTUPDATEDATE desc) = 1 $$;


    -- insert Statement
insert_statement := ' insert  
                            (OfficeToPhoneID,
                            PhoneTypeID,
                            PhoneID,
                            OfficeID,
                            SourceCode,
                            LastUpdateDate,
                            PhoneRank)
                    values 
                          (utils.generate_uuid(source.phonetypeid || source.phoneid || source.officeid), -- done
                            source.phonetypeid,
                            source.phoneid,
                            source.officeid,
                            source.sourcecode,
                            source.lastupdatedate,
                            source.phonerank)';

    -- update statement
update_statement := ' update
                        set
                            target.sourcecode = source.sourcecode,
                            target.lastupdatedate = source.lastupdatedate,
                            target.phonerank = source.phonerank';


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------

merge_statement := ' merge into base.officetophone as target 
                    using ('||select_statement||') as source
                    on source.officeid = target.officeid and source.phonetypeid = target.phonetypeid and source.phoneid = target.phoneid
                    when matched then' || update_statement || '
                    when not matched then'||insert_statement;

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.OfficeToPhone;
end if; 
execute immediate merge_statement;

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