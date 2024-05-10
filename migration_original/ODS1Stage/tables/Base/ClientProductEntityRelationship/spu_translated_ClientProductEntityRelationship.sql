CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCENTITYRELATIONSHIP()
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as  
declare 
---------------------------------------------------------
--------------- 0. table dependencies -------------------
---------------------------------------------------------
--- base.clientproductentityrelationship depends on:
-- mdm_team.mst.provider_profile_processing (raw.vw_provider_profile)
-- mdm_team.mst.office_profile_processing (raw.vw_office_profile)
-- base.provider
-- base.facility
-- base.office
-- base.relationshiptype
-- base.clienttoproduct
-- base.entitytype
-- base.clientproducttoentity
-- base.practice

---------------------------------------------------------
--------------- 1. declaring variables ------------------
---------------------------------------------------------

select_statement_facility string;
select_statement_office string;
select_statement_practice string;
insert_statement string; 
merge_statement_facility string;
merge_statement_office string;
merge_statement_practice string;
status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_clientproductentityrelationship');
    execution_start datetime default getdate();


---------------------------------------------------------
--------------- 2.conditionals if any -------------------
---------------------------------------------------------   

begin
-- no conditionals
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

------------ spuMergeProviderFacilityCustomerProduct ------------
select_statement_facility := $$
                            with CTE_swimlane as (
                                    select distinct
                                    -- ReltioEntityId (deprecated)
                                    p.providerid,
                                    f.facilityid,
                                    -- SourceID (unused)
                                    ifnull(CUSTOMERPRODUCT_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
                                    ifnull(CUSTOMERPRODUCT_SOURCECODE, 'Profisee') as SourceCode,
                                    json.providercode, 
                                    json.facility_FACILITYCODE as FacilityCode,
                                    json.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
                                    cp.clienttoproductid,
                                    rt.relationshiptypeid,
                                    rt.relationshiptypecode,
                                    row_number() over(partition by p.providerid, f.facilityid order by CREATE_DATE desc) as RowRank
                                from raw.vw_PROVIDER_PROFILE as JSON
                                left join base.provider p on p.providercode = json.providercode
                                inner join base.facility f on f.facilitycode = json.facility_FacilityCode
                                left join base.relationshiptype rt on rt.relationshiptypecode='PROVTOFAC'
                                inner join base.clienttoproduct cp on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
                                where json.provider_PROFILE is not null
                            )
                            
                            select 
                                s.relationshiptypeid,
                                cptep.clientproducttoentityid as ParentID,
                                cptef.clientproducttoentityid as ChildID,
                                s.sourcecode,
                                s.lastupdatedate
                            from CTE_Swimlane s
                            inner join base.entitytype prov on prov.entitytypecode='PROV'
                            inner join base.entitytype fac on fac.entitytypecode='FAC'
                            inner join base.clientproducttoentity cptep on s.providerid = cptep.entityid
                                and prov.entitytypeid = cptep.entitytypeid 
                            inner join base.clientproducttoentity cptef on s.facilityid = cptef.entityid
                                and fac.entitytypeid = cptef.entitytypeid
                            where s.rowrank = 1 and cptep.clienttoproductid = cptef.clienttoproductid
                            $$;


------------ spuMergeProviderOfficeCustomerProduct ------------
select_statement_office := $$
                            with CTE_swimlane as (
                                    select distinct
                                    -- ReltioEntityId (deprecated)
                                    p.providerid,
                                    o.officeid,
                                    -- SourceID (unused)
                                    ifnull(CUSTOMERPRODUCT_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
                                    ifnull(CUSTOMERPRODUCT_SOURCECODE, 'Profisee') as SourceCode,
                                    json.providercode, 
                                    json.office_OFFICECODE as OfficeCode,
                                    json.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
                                    cp.clienttoproductid,
                                    rt.relationshiptypeid,
                                    rt.relationshiptypecode,
                                    row_number() over(partition by p.providerid, o.officeid order by CREATE_DATE desc) as RowRank
                                from raw.vw_PROVIDER_PROFILE as JSON
                                left join base.provider p on p.providercode = json.providercode
                                inner join base.office o on o.officecode = json.office_OfficeCode
                                left join base.relationshiptype rt on rt.relationshiptypecode='PROVTOOFF'
                                inner join base.clienttoproduct cp on cp.clienttoproductcode = json.customerproduct_CUSTOMERPRODUCTCODE
                                where json.provider_PROFILE is not null
                            )
                            
                            select 
                                s.relationshiptypeid,
                                cptep.clientproducttoentityid as ParentID,
                                cpteo.clientproducttoentityid as ChildID,
                                s.sourcecode,
                                s.lastupdatedate
                            from CTE_Swimlane s
                            inner join base.entitytype prov on prov.entitytypecode='PROV'
                            inner join base.entitytype off on off.entitytypecode='OFFICE'
                            inner join base.clientproducttoentity cptep on s.providerid = cptep.entityid
                                and prov.entitytypeid = cptep.entitytypeid 
                            inner join base.clientproducttoentity cpteo on s.officeid = cpteo.entityid
                                and off.entitytypeid = cpteo.entitytypeid
                            where s.rowrank = 1 and cptep.clienttoproductid = cpteo.clienttoproductid
                            $$;

------------ spuMergePracticeOfficeCustomerProduct ------------
select_statement_practice := $$
                            with CTE_swimlane as (
                                select distinct
                                -- ReltioEntityId (deprecated)
                                o.officeid,
                                p.practiceid,
                                -- SourceID (unused)
                                sysdate() as LastUpdateDate,
                                'Profisee' as SourceCode,
                                json.practice_PRACTICECODE as PracticeCode, 
                                json.officecode as OfficeCode,
                                providerjson.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
                                cp.clienttoproductid,
                                rt.relationshiptypeid,
                                rt.relationshiptypecode,
                                row_number() over(partition by o.officeid order by json.create_DATE desc) as RowRank
                            from raw.vw_OFFICE_PROFILE as JSON
                            left join base.practice p on p.practicecode = json.practice_PRACTICECODE
                            inner join base.office o on o.officecode = json.officecode
                            left join base.relationshiptype rt on rt.relationshiptypecode='PRACTOOFF'
                            left join raw.vw_PROVIDER_PROFILE ProviderJSON on json.officecode = providerjson.office_OFFICECODE
                            inner join base.clienttoproduct cp on cp.clienttoproductcode = ClientToProductCode
                            where json.office_PROFILE is not null
                        )
                        
                        select 
                            s.relationshiptypeid,
                            cptep.clientproducttoentityid as ParentID,
                            cpteo.clientproducttoentityid as ChildID,
                            s.sourcecode,
                            s.lastupdatedate
                        from CTE_Swimlane s
                        inner join base.entitytype prac on prac.entitytypecode='PRAC'
                        inner join base.entitytype off on off.entitytypecode='OFFICE'
                        inner join base.clientproducttoentity cptep on s.practiceid = cptep.entityid
                            and prac.entitytypeid = cptep.entitytypeid 
                        inner join base.clientproducttoentity cpteo on s.officeid = cpteo.entityid
                            and off.entitytypeid = cpteo.entitytypeid
                        where s.rowrank = 1 and cptep.clienttoproductid = cpteo.clienttoproductid
                        $$;

                
insert_statement := $$ 
                    insert  
                        (
                         ClientProductEntityRelationshipID, 
                         RelationshipTypeID, 
                         ParentID, 
                         ChildID, 
                         SourceCode,
                         LastUpdateDate
                         )
                    values 
                        (
                        uuid_string(),
                        source.relationshiptypeid,
                        source.parentid,
                        source.childid,
                        source.sourcecode,
                        source.lastupdatedate
                        )
                    $$;


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_facility := $$ merge into base.clientproductentityrelationship as target using 
                           ($$||select_statement_facility||$$) as source 
                           on source.relationshiptypeid = target.relationshiptypeid
                            and source.parentid = target.parentid and source.childid = target.childid
                           when not matched then $$||insert_statement;
                           

merge_statement_office := $$ merge into base.clientproductentityrelationship as target using 
                           ($$||select_statement_office||$$) as source 
                           on source.relationshiptypeid = target.relationshiptypeid
                            and source.parentid = target.parentid and source.childid = target.childid
                           when not matched then $$||insert_statement;


merge_statement_practice := $$ merge into base.clientproductentityrelationship as target using 
                           ($$||select_statement_practice||$$) as source 
                           on source.relationshiptypeid = target.relationshiptypeid
                            and source.parentid = target.parentid and source.childid = target.childid
                           when not matched then $$||insert_statement;

    
---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

execute immediate merge_statement_facility;
execute immediate merge_statement_office;
execute immediate merge_statement_practice;

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