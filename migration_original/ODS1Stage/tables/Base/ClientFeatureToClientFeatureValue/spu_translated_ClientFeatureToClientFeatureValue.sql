CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTFEATURETOCLIENTFEATUREVALUE(is_full BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------

--- base.clientfeaturetoclientfeaturevalue depends on:
--- base.clientfeature
--- base.clientfeaturevalue
--- mdm_team.mst.customer_product_profile_processing  (base.vw_swimlane_base_client)

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_clientfeaturetoclientfeaturevalue');
    execution_start datetime default getdate();


begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- select Statement
-- if no conditionals:
select_statement := $$ with cte_swimlane as (
    select
        *,
        rank() over(
            partition by customerproductcode
            order by
                LastUpdateDate
        ) as rowrank,
    from
        base.vw_swimlane_base_client
),
cte_tmp_features as (
    select
        CustomerProductCode,
        'FCBFN' as ClientFeatureCode,
        FeatureFCBFN as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCBFN = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCBFN' as ClientFeatureCode,
        FeatureFCBFN as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCBFN = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCCCP' as ClientFeatureCode,
        FeatureFCCCP_FVCLT as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCCCP_FVCLT = 'FVCLT'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCCCP' as ClientFeatureCode,
        FeatureFCCCP_FVFAC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCCCP_FVFAC = 'FVFAC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCCCP' as ClientFeatureCode,
        FeatureFCCCP_FVOFFICE as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCCCP_FVOFFICE = 'FVOFFICE'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCDTP' as ClientFeatureCode,
        FeatureFCDTP as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCDTP = 'FVPPN'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCDTP' as ClientFeatureCode,
        FeatureFCDTP as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCDTP = 'FVPTN'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCMWC' as ClientFeatureCode,
        FeatureFCMWC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCMWC = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCMWC' as ClientFeatureCode,
        FeatureFCMWC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCMWC = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCNPA' as ClientFeatureCode,
        FeatureFCNPA as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCNPA = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCNPA' as ClientFeatureCode,
        FeatureFCNPA as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCNPA = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCBRL' as ClientFeatureCode,
        FeatureFCBRL as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCBRL = 'FVCLT'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCBRL' as ClientFeatureCode,
        FeatureFCBRL as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCBRL = 'FVFAC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCBRL' as ClientFeatureCode,
        FeatureFCBRL as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCBRL = 'FVOFFICE'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCEPR' as ClientFeatureCode,
        FeatureFCEPR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCEPR = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCEPR' as ClientFeatureCode,
        FeatureFCEPR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCEPR = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOOACP' as ClientFeatureCode,
        FeatureFCOOACP as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOOACP = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOOACP' as ClientFeatureCode,
        FeatureFCOOACP as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOOACP = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCLOT' as ClientFeatureCode,
        FeatureFCLOT as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCLOT = 'FVCUS'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCMAR' as ClientFeatureCode,
        FeatureFCMAR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCMAR = 'FVFAC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCDOA' as ClientFeatureCode,
        FeatureFCDOA as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCDOA = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCDOA' as ClientFeatureCode,
        FeatureFCDOA as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCDOA = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCDOS' as ClientFeatureCode,
        FeatureFCDOS_FVFAX as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCDOS_FVFAX = 'FVFAX'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCDOS' as ClientFeatureCode,
        FeatureFCDOS_FVMMPEML as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCDOS_FVMMPEML = 'FVMMPEML'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCEOARD' as ClientFeatureCode,
        FeatureFCEOARD as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCEOARD = 'FVAQSTD'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOBT' as ClientFeatureCode,
        FeatureFCOBT as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOBT = 'FVRAPT'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVDFC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCODC_FVDFC = 'FVDFC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVDPR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCODC_FVDPR = 'FVDPR'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVMT as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCODC_FVMT = 'FVMT'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCODC' as ClientFeatureCode,
        FeatureFCODC_FVPSR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCODC_FVPSR = 'FVPSR'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOAS' as ClientFeatureCode,
        FeatureFCOAS as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOAS = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCSPC' as ClientFeatureCode,
        FeatureFCSPC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCSPC = 'FVABR1'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCPNI' as ClientFeatureCode,
        FeatureFCPNI as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCPNI = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCPQM' as ClientFeatureCode,
        FeatureFCPQM as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCPQM = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCPQM' as ClientFeatureCode,
        FeatureFCPQM as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCPQM = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPOFFICE as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPOFFICE = 'FVCPOFFICE'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOCC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOCC = 'FVCPTOCC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOFAC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOFAC = 'FVCPTOFAC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOPRAC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOPRAC = 'FVCPTOPRAC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVCPTOPROV as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVCPTOPROV = 'FVCPTOPROV'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVPRACOFF as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVPRACOFF = 'FVPRACOFF'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVPROVFAC as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVPROVFAC = 'FVPROVFAC'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCREL' as ClientFeatureCode,
        FeatureFCREL_FVPROVOFF as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCREL_FVPROVOFF = 'FVPROVOFF'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOOPSR' as ClientFeatureCode,
        FeatureFCOOPSR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOOPSR = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOOPSR' as ClientFeatureCode,
        FeatureFCOOPSR as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOOPSR = 'FVYES'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOOMT' as ClientFeatureCode,
        FeatureFCOOMT as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOOMT = 'FVNO'
        and RowRank = 1
    union all
    select
        CustomerProductCode,
        'FCOOMT' as ClientFeatureCode,
        FeatureFCOOMT as ClientFeatureValueCode,
        sourcecode,
        lastupdatedate
    from
        cte_swimlane
    where
        FeatureFCOOMT = 'FVYES'
        and RowRank = 1
)
        select distinct 
            ClientFeatureId,
            ClientFeatureValueId,
            ifnull(t.sourcecode, 'Reltio') as SourceCode,
            ifnull(t.lastupdatedate, current_timestamp()) as LastUpdateDate
        from
            cte_tmp_features as T
            inner join base.clientfeature as CF on cf.clientfeaturecode = t.clientfeaturecode
            inner join base.clientfeaturevalue as CFV on cfv.clientfeaturevaluecode = t.clientfeaturevaluecode
        qualify row_number() over(partition by ClientFeatureID, ClientFeatureValueId, ifnull(t.sourcecode, 'Reltio') order by ifnull(t.lastupdatedate, current_timestamp()) desc) = 1

$$;

--- insert Statement
insert_statement := '  insert (
                            ClientFeatureToClientFeatureValueID, 
                            ClientFeatureID, 
                            ClientFeatureValueID, 
                            SourceCode, 
                            LastUpdateDate)
                        values (
                            uuid_string(), 
                            source.clientfeatureid, 
                            source.clientfeaturevalueid, 
                            source.sourcecode, 
                            source.lastupdatedate);';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into base.clientfeaturetoclientfeaturevalue as target using 
                   ('||select_statement||') as Source
                   on target.clientfeatureid = source.clientfeatureid and target.clientfeaturevalueid = source.clientfeaturevalueid
                   when matched then delete
                   when not matched then'||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ClientFeatureToClientFeatureValue;
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