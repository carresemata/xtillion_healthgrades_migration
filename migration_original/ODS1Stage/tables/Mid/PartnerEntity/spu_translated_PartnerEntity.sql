CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PARTNERENTITY(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.partnerentity depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.partnertoentity
--- base.partner
--- base.provider
--- base.entitytype
--- base.office
--- base.providertooffice
--- base.practice
--- base.partnertype
--- base.externaloaspartner

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_partnerentity');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin 
--- select Statement

select_statement := $$ with CTE_ProviderBatch as (
                        select 
                            distinct 
                            p.providerid, 
                            p.providercode
                        from $$ || mdm_db || $$.mst.Provider_Profile_Processing as pdp
                            join base.provider as p on p.providercode = pdp.ref_provider_code)
                        select distinct
                                pte.partnertoentityid, 
                                pa.partnerid, 
                                pa.partnercode, 
                                pa.partnerdescription, 
                                pt.partnertypecode, 
                                pt.partnertypedescription, 
                                pa.partnerproductcode,
                                pa.partnerproductdescription,
                                pa.urlpath, 
                                CASE WHEN OASURL is not null then OASURL
                                    else 'https://' || pa.urlpath || pte.partnerprimaryentityid || '/availability' END as FullURL,
                                pte.primaryentityid, 
                                pte.partnerprimaryentityid, 
                                pte.secondaryentityid, 
                                pte.partnersecondaryentityid, 
                                pte.tertiaryentityid, 
                                pte.partnertertiaryentityid, 
                                p.providercode, 
                                o.officecode, 
                                prac.practicecode,
                                eop.externaloaspartnercode,
                                eop.externaloaspartnerdescription
                            from base.partnertoentity pte
                                join base.partner pa on pte.partnerid = pa.partnerid
                                join base.provider p on p.providerid = pte.primaryentityid
                                join base.entitytype pet on pte.primaryentitytypeid = pet.entitytypeid
                                join base.office o on o.officeid = pte.secondaryentityid
                                join base.providertooffice po on p.providerid = po.providerid and o.officeid = po.officeid
                                join base.entitytype seet on pte.primaryentitytypeid = seet.entitytypeid
                                left join base.practice prac on prac.practiceid = pte.tertiaryentityid
                                left join base.entitytype tet on pte.tertiaryentitytypeid = tet.entitytypeid
                                join base.partnertype pt on pa.partnertypeid = pt.partnertypeid
                                join CTE_ProviderBatch pb on pte.primaryentityid = pb.providerid
                                left join base.externaloaspartner eop on pte.externaloaspartnerid = eop.externaloaspartnerid
                            where pt.partnertypecode='API' or pt.partnertypecode='URL' $$;

--- update Statement
update_statement := ' update 
                        SET
                            PartnerToEntityID = source.partnertoentityid,
                            PartnerID = source.partnerid,
                            PartnerCode = source.partnercode,
                            PartnerDescription = source.partnerdescription,
                            PartnerTypeCode = source.partnertypecode,
                            PartnerTypeDescription = source.partnertypedescription,
                            PartnerProductCode = source.partnerproductcode,
                            PartnerProductDescription = source.partnerproductdescription,
                            URLPath = source.urlpath,
                            FullURL = source.fullurl, 
                            PrimaryEntityID = source.primaryentityid, 
                            PartnerPrimaryEntityID = source.partnerprimaryentityid, 
                            SecondaryEntityID = source.secondaryentityid, 
                            PartnerSecondaryEntityID = source.partnersecondaryentityid, 
                            TertiaryEntityID = source.tertiaryentityid, 
                            PartnerTertiaryEntityID = source.partnertertiaryentityid, 
                            ProviderCode = source.providercode, 
                            OfficeCode = source.officecode, 
                            PracticeCode = source.practicecode,
                            ExternalOASPartnerCode = source.externaloaspartnercode,
                            ExternalOASPartnerDescription = source.externaloaspartnerdescription';

--- insert Statement
insert_statement := ' insert (
                            PartnerToEntityID,
                            PartnerID,
                            PartnerCode,
                            PartnerDescription,
                            PartnerTypeCode,
                            PartnerTypeDescription,
                            PartnerProductCode,
                            PartnerProductDescription,
                            URLPath,
                            FullURL, 
                            PrimaryEntityID, 
                            PartnerPrimaryEntityID, 
                            SecondaryEntityID, 
                            PartnerSecondaryEntityID, 
                            TertiaryEntityID, 
                            PartnerTertiaryEntityID, 
                            ProviderCode, 
                            OfficeCode, 
                            PracticeCode,
                            ExternalOASPartnerCode,
                            ExternalOASPartnerDescription
                        )
                        values (
                            source.partnertoentityid,
                            source.partnerid,
                            source.partnercode,
                            source.partnerdescription,
                            source.partnertypecode,
                            source.partnertypedescription,
                            source.partnerproductcode,
                            source.partnerproductdescription,
                            source.urlpath,
                            source.fullurl, 
                            source.primaryentityid, 
                            source.partnerprimaryentityid, 
                            source.secondaryentityid, 
                            source.partnersecondaryentityid, 
                            source.tertiaryentityid, 
                            source.partnertertiaryentityid, 
                            source.providercode, 
                            source.officecode, 
                            source.practicecode,
                            source.externaloaspartnercode,
                            source.externaloaspartnerdescription
                        )';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.partnerentity as target using 
                   ('||select_statement||') as source 
                   on source.partnertoentityid = target.partnertoentityid and source.officecode = target.officecode
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.PartnerEntity;
end if; 
execute immediate merge_statement ;

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