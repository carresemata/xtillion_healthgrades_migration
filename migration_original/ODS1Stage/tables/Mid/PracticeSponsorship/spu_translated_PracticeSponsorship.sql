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
),

CTE_InsertPracticeSponsorship as (
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
                ifnull(practmultclientrank.clientpractrank, rawpracdatainner.recid) as ClientPractRank, -- Equivlaent to ISNULL in SQL Server
                0 as ActionCode -- Create a new column ActionCode and set it to 0 (default value: no change)

            from 
                CTE_RawPracData as rawPracDataInner
                left join CTE_PractMultClientRank as practMultClientRank on 
                    practmultclientrank.practicecode = rawpracdatainner.practicecode and 
                    practmultclientrank.clientcode = rawpracdatainner.clientcode and 
                    practmultclientrank.productcode = rawpracdatainner.productcode
            where 
                practmultclientrank.clientpractrank = 1
),
-- insert Action
CTE_Action_1 as (
    select temppracspon.practiceid, 1 as ActionCode
    from CTE_InsertPracticeSponsorship as tempPracSpon
    left join mid.practicesponsorship as midPracSpon on 
        temppracspon.practiceid = midpracspon.practiceid and 
        temppracspon.practicecode = midpracspon.practicecode
    where midpracspon.practiceid is null
    group by temppracspon.practiceid
),
-- update Action
CTE_Action_2 as (
    select temppracspon.practiceid, 2 as ActionCode
    from CTE_InsertPracticeSponsorship as tempPracSpon
    join mid.practicesponsorship PracSpon on 
        temppracspon.practiceid = pracspon.practiceid and 
        temppracspon.practicecode = pracspon.practicecode
    where 
        MD5(ifnull(temppracspon.productdescription::varchar, '''''''')) <> MD5(ifnull(pracspon.productdescription::varchar, ''''''''))
        or MD5(ifnull(temppracspon.productgroupcode::varchar, '''''''')) <> MD5(ifnull(pracspon.productgroupcode::varchar, ''''''''))
        or MD5(ifnull(temppracspon.productgroupdescription::varchar, '''''''')) <> MD5(ifnull(pracspon.productgroupdescription::varchar, ''''''''))
        or MD5(ifnull(temppracspon.clienttoproductid::varchar, '''''''')) <> MD5(ifnull(pracspon.clienttoproductid::varchar, ''''''''))
        or MD5(ifnull(temppracspon.clientcode::varchar, '''''''')) <> MD5(ifnull(pracspon.clientcode::varchar, ''''''''))
        or MD5(ifnull(temppracspon.clientname::varchar, '''''''')) <> MD5(ifnull(pracspon.clientname::varchar, ''''''''))
    group by temppracspon.practiceid
)
select 
distinct
    A0.PracticeID,
    A0.PracticeCode,
    A0.ProductCode,
    A0.ProductDescription,
    A0.ProductGroupCode ,
    A0.ProductGroupDescription,
    A0.ClientToProductId,
    A0.ClientCode,
    A0.ClientName,
    ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) as ActionCode
from CTE_InsertPracticeSponsorship as A0
left join
    CTE_ACTION_1 as A1 on A0.PracticeID = A1.PracticeID
left join
    CTE_ACTION_2 as A2 on A0.PracticeID = A2.PracticeID
where
    ifnull(A1.ActionCode,ifnull(A2.ActionCode, A0.ActionCode)) <> 0


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
                        (PRACTICEID, 
                        PRACTICECODE, 
                        PRODUCTCODE, 
                        PRODUCTDESCRIPTION, 
                        PRODUCTGROUPCODE, 
                        PRODUCTGROUPDESCRIPTION, 
                        CLIENTTOPRODUCTID, 
                        CLIENTCODE, 
                        CLIENTNAME)
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
                   WHEN MATCHED and ActionCode = 2 then '||update_statement|| '
                   when not matched and ActionCode = 1 then '||insert_statement;
                   
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

            return status;
end;