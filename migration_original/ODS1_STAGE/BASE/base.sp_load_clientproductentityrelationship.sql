CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.BASE.SP_LOAD_CLIENTPRODUCENTITYRELATIONSHIP(is_full BOOLEAN)
RETURNS STRING
LANGUAGE SQL
EXECUTE as CALLER
as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
--- base.clientproductentityrelationship depends on:
-- mdm_team.mst.provider_profile_processing 
-- mdm_team.mst.office_profile_processing 
-- base.provider
-- base.facility
-- base.office
-- base.relationshiptype
-- base.clienttoproduct
-- base.entitytype
-- base.clientproducttoentity

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

select_statement_facility string;
select_statement_office string;
select_statement_practice string;
insert_statement string; 
update_statement string;
merge_statement_facility string;
merge_statement_office string;
merge_statement_practice string;
status string; -- status monitoring
procedure_name varchar(50) default('sp_load_clientproductentityrelationship');
execution_start datetime default getdate();
mdm_db string default('mdm_team');

begin

---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------  

------------ spuMergeProviderFacilityCustomerProduct ------------
select_statement_facility := $$ with Cte_customer_product as (
                                SELECT
                                    p.ref_provider_code as providercode,
                                    to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
                                    to_varchar(json.value:DATA_SOURCE_CODE) as CustomerProduct_SourceCode,
                                    to_timestamp_ntz(json.value:UPDATED_DATETIME) as CustomerProduct_LastUpdateDate,
                                FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                                , lateral flatten(input => p.PROVIDER_PROFILE:CUSTOMER_PRODUCT) as json
                            ),
                            Cte_facility as (
                                SELECT
                                    p.ref_provider_code as providercode,
                                    to_varchar(json.value:FACILITY_CODE) as Facility_FacilityCode,
                                    to_varchar(json.value:DATA_SOURCE_CODE) as Facility_SourceCode,
                                    to_timestamp_ntz(json.value:UPDATED_DATETIME) as Facility_LastUpdateDate
                                FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                                , lateral flatten(input => p.PROVIDER_PROFILE:FACILITY) as json
                            ),
                            CTE_swimlane as (
                                    select distinct
                                    -- ReltioEntityId (deprecated)
                                    p.providerid,
                                    f.facilityid,
                                    ifnull(json_cp.CUSTOMERPRODUCT_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
                                    ifnull(json_cp.CUSTOMERPRODUCT_SOURCECODE, 'Profisee') as SourceCode,
                                    json_cp.providercode, 
                                    json_f.facility_facilitycode as facilitycodeCode,
                                    json_cp.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
                                    cp.clienttoproductid,
                                    rt.relationshiptypeid,
                                    rt.relationshiptypecode
                                from cte_customer_product as json_cp
                                    join cte_facility as json_f on json_cp.providercode = json_f.providercode
                                left join base.provider p on p.providercode = json_cp.providercode
                                inner join base.facility f on f.facilitycode = json_f.facility_facilitycode
                                left join base.relationshiptype rt on rt.relationshiptypecode='PROVTOFAC'
                                inner join base.clienttoproduct cp on cp.clienttoproductcode = json_cp.customerproduct_CUSTOMERPRODUCTCODE
                                
                            )
                            select 
                                s.relationshiptypeid,
                                cptep.clientproducttoentityid as ParentID,
                                cpteo.clientproducttoentityid as ChildID,
                                s.sourcecode,
                                s.lastupdatedate
                            from CTE_Swimlane s
                                join base.clientproducttoentity cptep on s.providerid = cptep.entityid and cptep.entitytypeid = (select entitytypeid from base.entitytype where entitytypecode ='PROV')
                                join base.clientproducttoentity cpteo on s.facilityid = cpteo.entityid and cpteo.entitytypeid = (select entitytypeid from base.entitytype where entitytypecode ='FAC')
                            qualify row_number() over(partition by s.relationshiptypeid, s.providerid, s.facilityid order by s.lastupdatedate desc) = 1
                           $$;


------------ spuMergeProviderOfficeCustomerProduct ------------
select_statement_office := $$ with Cte_customer_product as (
                                SELECT
                                    p.ref_provider_code as providercode,
                                    to_varchar(json.value:CUSTOMER_PRODUCT_CODE) as CustomerProduct_CustomerProductCode,
                                    to_varchar(json.value:DATA_SOURCE_CODE) as CustomerProduct_SourceCode,
                                    to_timestamp_ntz(json.value:UPDATED_DATETIME) as CustomerProduct_LastUpdateDate,
                                FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                                , lateral flatten(input => p.PROVIDER_PROFILE:CUSTOMER_PRODUCT) as json
                            ),
                            Cte_office as (
                                SELECT
                                    p.ref_provider_code as providercode,
                                    to_varchar(json.value:OFFICE_CODE) as Office_OfficeCode,
                                    to_varchar(json.value:DATA_SOURCE_CODE) as Office_SourceCode,
                                    to_timestamp_ntz(json.value:UPDATED_DATETIME) as Office_LastUpdateDate
                                FROM $$ || mdm_db || $$.mst.provider_profile_processing as p
                                , lateral flatten(input => p.PROVIDER_PROFILE:OFFICE) as json
                            ),
                            CTE_swimlane as (
                                    select distinct
                                    -- ReltioEntityId (deprecated)
                                    p.providerid,
                                    o.officeid,
                                    ifnull(json_cp.CUSTOMERPRODUCT_LASTUPDATEDATE, sysdate()) as LastUpdateDate,
                                    ifnull(json_cp.CUSTOMERPRODUCT_SOURCECODE, 'Profisee') as SourceCode,
                                    json_cp.providercode, 
                                    json_o.office_OFFICECODE as OfficeCode,
                                    json_cp.customerproduct_CUSTOMERPRODUCTCODE as ClientToProductCode,
                                    cp.clienttoproductid,
                                    rt.relationshiptypeid,
                                    rt.relationshiptypecode
                                from cte_customer_product as json_cp
                                    join cte_office as json_o on json_cp.providercode = json_o.providercode
                                left join base.provider p on p.providercode = json_cp.providercode
                                inner join base.office o on o.officecode = json_o.office_OfficeCode
                                left join base.relationshiptype rt on rt.relationshiptypecode='PROVTOOFF'
                                inner join base.clienttoproduct cp on cp.clienttoproductcode = json_cp.customerproduct_CUSTOMERPRODUCTCODE
                                
                            )
                            select 
                                s.relationshiptypeid,
                                cptep.clientproducttoentityid as ParentID,
                                cpteo.clientproducttoentityid as ChildID,
                                s.sourcecode,
                                s.lastupdatedate
                            from CTE_Swimlane s
                                join base.clientproducttoentity cptep on s.providerid = cptep.entityid and cptep.entitytypeid = (select entitytypeid from base.entitytype where entitytypecode ='PROV')
                                join base.clientproducttoentity cpteo on s.officeid = cpteo.entityid and cpteo.entitytypeid = (select entitytypeid from base.entitytype where entitytypecode ='OFFICE')
                            qualify row_number() over(partition by s.relationshiptypeid, s.providerid, s.officeid order by s.lastupdatedate desc) = 1
                            
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
                        utils.generate_uuid(source.relationshiptypeid || source.parentid || source.childid), 
                        source.relationshiptypeid,
                        source.parentid,
                        source.childid,
                        source.sourcecode,
                        source.lastupdatedate
                        )
                    $$;

update_statement := $$ 
    update
    set
        target.SourceCode = source.sourcecode,
        target.LastUpdateDate = source.lastupdatedate $$;


---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  

merge_statement_facility := $$ merge into base.clientproductentityrelationship as target using 
                           ($$||select_statement_facility||$$) as source 
                           on source.relationshiptypeid = target.relationshiptypeid and source.parentid = target.parentid and source.childid = target.childid
                           when matched then $$ || update_statement || $$
                           when not matched then $$||insert_statement;
                           

merge_statement_office := $$ merge into base.clientproductentityrelationship as target using 
                           ($$||select_statement_office||$$) as source 
                           on source.relationshiptypeid = target.relationshiptypeid and source.parentid = target.parentid and source.childid = target.childid
                           when matched then $$ || update_statement || $$
                           when not matched then $$||insert_statement;

    
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Base.ClientProductEntityRelationship;
end if; 
execute immediate merge_statement_facility;
execute immediate merge_statement_office;

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

            raise;
end;
