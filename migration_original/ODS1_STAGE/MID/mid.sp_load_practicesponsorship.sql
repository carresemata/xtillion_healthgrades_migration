CREATE or REPLACE PROCEDURE ODS1_STAGE_TEAM.MID.SP_LOAD_PRACTICESPONSORSHIP(is_full BOOLEAN)
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE as CALLER
    as  
declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- mid.practicesponsorship depends on: 
--- mdm_team.mst.provider_profile_processing
--- base.practice
--- base.providertooffice
--- base.office
--- base.clienttoproduct
--- base.client
--- base.product
--- base.provider
--- base.productgroup
--- base.clientproducttoentity
--- base.entitytype
--- mid.providersponsorship

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte and select statement for the merge
    update_statement string; -- update statement for the merge
    insert_statement string; -- insert statement for the merge
    merge_statement string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_practicesponsorship');
    execution_start datetime default getdate();
    mdm_db string default('mdm_team');
    
---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

begin

-- select Statements
select_statement := 
$$ with CTE_PracticeBatch as (
                    select 
                        pa.practiceid, 
                        pa.practicecode
                    from $$ || mdm_db || $$.mst.Provider_Profile_Processing as ppp
                    join base.provider as P on p.providercode = ppp.ref_provider_code
                    join base.providertooffice pto on p.providerid = pto.providerid
                    join base.office o on pto.officeid = o.officeid
                    join base.practice as pa on pa.practiceid = o.practiceid
                    group by 
                        pa.practiceid, 
                        pa.practicecode
                    order by pa.practiceid
                    ),
CTE_RawPracData as (
    select	
        pract.practiceid,
        pract.practicecode,
        prod.productcode,
        prod.productdescription,
        prodgrp.productgroupcode,
        prodgrp.productgroupdescription,
        clitoprod.clienttoproductid,
        cli.clientcode,
        cli.clientname,
        row_number() over (
            partition by pract.practiceid, 
                         pract.practicecode, 
                         prod.productcode, 
                         prod.productdescription, 
                         prodgrp.productgroupcode, 
                         prodgrp.productgroupdescription  
            order by 
                cliprodtoent.lastupdatedate ASC) as recID -- This assignes a sequential recID to rows that have the same PracticeID, PracticeCode, ProductCode, ProductDescription, ProductGroupCode, ProductGroupDescription
    from	
        base.clienttoproduct as cliToProd
        join base.client as cli on clitoprod.clientid = cli.clientid
        join base.product as prod on clitoprod.productid = prod.productid
        join base.productgroup as prodGrp on prod.productgroupid = prodgrp.productgroupid
        join base.clientproducttoentity as cliProdToEnt on clitoprod.clienttoproductid = cliprodtoent.clienttoproductid
        join base.entitytype as entType on cliprodtoent.entitytypeid = enttype.entitytypeid and enttype.entitytypecode = 'PRAC'
        join base.practice as pract on cliprodtoent.entityid = pract.practiceid
        join CTE_PracticeBatch as practBatch on cliprodtoent.entityid = practbatch.practiceid 
    where	
        clitoprod.activeflag = 1
),
CTE_PractMultClientRank as (
    select 
        rawpracdata.clientcode as ClientCode, 
        rawpracdata.practicecode as PracticeCode, 
        rawpracdata.productcode as ProductCode, 
        row_number() over ( 
            partition by rawpracdata.practicecode
            order by 
                rawpracdata.productcode, 
                ifnull(providercount.provcount, 0) desc, 
                rawpracdata.clientcode 
        ) as ClientPractRank
    from  
        CTE_RawPracData as rawPracData
        left join ( 
            select 
                provspon.clientcode as ClientCode, 
                provspon.practicecode as PracticeCode, 
                provspon.productcode as ProductCode, 
                COUNT(distinct provspon.providercode) as ProvCount
            from 
                mid.providersponsorship as provSpon
            join CTE_RawPracData as rawPracDataInner on 
                rawpracdatainner.practicecode = provspon.practicecode and 
                rawpracdatainner.clientcode = provspon.clientcode and 
                rawpracdatainner.productcode = provspon.productcode
            group by 
                provspon.clientcode, 
                provspon.practicecode, 
                provspon.productcode 
        ) as providerCount on 
            providercount.clientcode = rawpracdata.clientcode and 
            providercount.productcode = rawpracdata.productcode and 
            providercount.practicecode = rawpracdata.practicecode
)
            select 
                rawpracdatainner.practiceid, 
                rawpracdatainner.practicecode, 
                rawpracdatainner.productcode, 
                rawpracdatainner.productdescription, 
                rawpracdatainner.productgroupcode, 
                rawpracdatainner.productgroupdescription, 
                rawpracdatainner.clienttoproductid, 
                rawpracdatainner.clientcode, 
                rawpracdatainner.clientname, 
                ifnull(practmultclientrank.clientpractrank, rawpracdatainner.recid) as ClientPractRank
            from 
                CTE_RawPracData as rawPracDataInner
                left join CTE_PractMultClientRank as practMultClientRank on 
                    practmultclientrank.practicecode = rawpracdatainner.practicecode and 
                    practmultclientrank.clientcode = rawpracdatainner.clientcode and 
                    practmultclientrank.productcode = rawpracdatainner.productcode
            where 
                practmultclientrank.clientpractrank = 1


$$;

--- update Statement
update_statement := ' update 
                     SET 
                        PRACTICEID = source.practiceid, 
                        PRACTICECODE = source.practicecode, 
                        PRODUCTCODE = source.productcode, 
                        PRODUCTDESCRIPTION = source.productdescription, 
                        PRODUCTGROUPCODE = source.productgroupcode, 
                        PRODUCTGROUPDESCRIPTION = source.productgroupdescription, 
                        CLIENTTOPRODUCTID = source.clienttoproductid, 
                        CLIENTCODE = source.clientcode, 
                        CLIENTNAME = source.clientname';

--- insert Statement
insert_statement := ' insert  
                        (practiceid, 
                       practicecode, 
                       productcode, 
                       productdescription, 
                       productgroupcode, 
                       productgroupdescription, 
                       clienttoproductid, 
                       clientcode, 
                       clientname )
                      values 
                        (source.practiceid, 
                        source.practicecode, 
                        source.productcode, 
                        source.productdescription, 
                        source.productgroupcode, 
                        source.productgroupdescription, 
                        source.clienttoproductid, 
                        source.clientcode, 
                        source.clientname)';

---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  


merge_statement := ' merge into mid.practicesponsorship as target using 
                   ('||select_statement||') as source 
                   on source.practiceid = target.practiceid
                   when matched then '||update_statement|| '
                   when not matched then '||insert_statement;
                   
---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Mid.PracticeSponsorship;
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

            raise;
end;