create or replace procedure ods1_stage_team.show.sp_load_solrproviderredirect(is_full BOOLEAN)
    returns string
    language sql
    as  

declare 
---------------------------------------------------------
--------------- 1. table dependencies -------------------
---------------------------------------------------------
    
-- show.solrproviderredirect depends on: 
--- base.providerredirect 
--- base.provider 
--- base.providerurl 
--- show.solrprovider 

---------------------------------------------------------
--------------- 2. declaring variables ------------------
---------------------------------------------------------

    select_statement string; -- cte statement
    select_statement_1 string; 
    merge_condition string; -- merge condition to final table
    update_statement string; -- update statement to final table
    insert_statement string; -- insert statement to final table
    update_statement_1 string; -- merge statement
    delete_statement string; -- delete statement to final table
    merge_statement_1 string; -- insert into statement to final table
    merge_statement_2 string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrproviderredirect');
    execution_start datetime default getdate();
   
begin   

---------------------------------------------------------
----------------- 3. sql statements ---------------------
---------------------------------------------------------     
        
select_statement := $$ select distinct
                            providercodeold,
                            providercodenew,
                            providerurlold,
                            providerurlnew,
                            hgidold,
                            hgidnew,
                            hgid8old,
                            hgid8new,
                            lastname,
                            firstname,
                            middlename,
                            suffix,
                            displayname,
                            degree,
                            degreepriority,
                            providertypeid,
                            citystate,
                            specialtycode,
                            specialtylegacykey,
                            case when deactivationreason = 'duplicate' then 'Duplicate' else deactivationreason end as deactivationreason,
                            lastupdatedate,
                            null as title,
                            null as gender,
                            null as updatedate,
                            null as updatesource,
                            null as providertypegroup,
                            null as dateofbirth,
                            null as practiceofficexml,
                            null as specialtyxml,
                            null as educationxml,
                            null as imagexml,
                    from	base.providerredirect
                    where	providercodeold not in (select providercode from show.solrprovider )
                    qualify row_number() over(partition by providercodeold order by lastupdatedate desc) = 1
                    $$;

select_statement_1 := $$select
                        solrprov.providercode as providercodeold,
                        solrprov.providercode as providercodenew,
                        solrprov.providerurl as providerurlold,
                        solrprov.providerurl as providerurlnew,
                        solrprov.lastname,
                        solrprov.firstname,
                        solrprov.middlename,
                        solrprov.suffix,
                        solrprov.firstname || ' ' || iff(solrprov.middlename is null, '', solrprov.middlename || ' ') || solrprov.lastname || iff(solrprov.suffix is null,'', ' ' || solrprov.suffix) as displayname,
                        solrprov.degree,
                        solrprov.title,
                        solrprov.providertypeid,
                        solrprov.providertypegroup,
                        'Deactivated' as deactivationreason,
                        solrprov.gender as gender,
                        solrprov.dateofbirth,
                        solrprov.practiceofficexml,
                        solrprov.specialtyxml,
                        solrprov.educationxml,
                        solrprov.imagexml,
                        current_timestamp() as lastupdatedate,
                        current_timestamp() as updatedate,
                        current_user() as updatesource,
                        solrprovred.hgidold,
                        solrprovred.hgidnew,
                        solrprovred.hgid8old,
                        solrprovred.hgid8new,
                        solrprovred.degreepriority,
                        solrprovred.citystate,
                        solrprovred.specialtycode,
                        solrprovred.specialtylegacykey  
                    from
                        show.solrprovider solrprov
                        join base.provider baseprov on baseprov.providerid = solrprov.providerid
                        left join show.solrproviderredirect solrprovred on solrprovred.providercodeold = solrprov.providercode
                        and solrprovred.providercodenew = solrprov.providercode
                        and solrprovred.deactivationreason = 'Deactivated'
                    where
                        solrprovred.solrproviderredirectid is null
                    qualify row_number() over(partition by providercodeold order by current_timestamp() desc) = 1 $$;

update_statement := 'update
                        set
                            providercodeold = source.providercodeold,
                            providercodenew = source.providercodenew,
                            providerurlold = source.providerurlold,
                            providerurlnew = source.providerurlnew,
                            hgidold = source.hgidold,
                            hgidnew = source.hgidnew,
                            hgid8old = source.hgid8old,
                            hgid8new = source.hgid8new,
                            lastname = source.lastname,
                            firstname = source.firstname,
                            middlename = source.middlename,
                            suffix = source.suffix,
                            displayname = source.displayname,
                            degree = source.degree,
                            degreepriority = source.degreepriority,
                            providertypeid = source.providertypeid,
                            citystate = source.citystate,
                            specialtycode = source.specialtycode,
                            specialtylegacykey = source.specialtylegacykey,
                            deactivationreason = source.deactivationreason,
                            lastupdatedate = source.lastupdatedate,
                            updatedate = current_timestamp(),
                            updatesource = current_user()';

 insert_statement := 'insert(
                        solrproviderredirectid,
                        providercodeold,
                        providercodenew,
                        providerurlold,
                        providerurlnew,
                        hgidold,
                        hgidnew,
                        hgid8old,
                        hgid8new,
                        lastname,
                        firstname,
                        middlename,
                        suffix,
                        displayname,
                        degree,
                        degreepriority,
                        providertypeid,
                        citystate,
                        specialtycode,
                        specialtylegacykey,
                        deactivationreason,
                        lastupdatedate,
                        updatedate,
                        updatesource,
                        title,
                        providertypegroup,
                        gender,
                        dateofbirth,
                        practiceofficexml,
                        specialtyxml,
                        educationxml,
                        imagexml
                    )
                    values
                        (uuid_string(),
                        source.providercodeold,
                        source.providercodenew,
                        source.providerurlold,
                        source.providerurlnew,
                        source.hgidold,
                        source.hgidnew,
                        source.hgid8old,
                        source.hgid8new,
                        source.lastname,
                        source.firstname,
                        source.middlename,
                        source.suffix,
                        source.displayname,
                        source.degree,
                        source.degreepriority,
                        source.providertypeid,
                        source.citystate,
                        source.specialtycode,
                        source.specialtylegacykey,
                        source.deactivationreason,
                        source.lastupdatedate,
                        current_timestamp(),
                        current_user(),
                        source.title,
                        source.providertypegroup,
                        source.gender,
                        source.dateofbirth,
                        source.practiceofficexml,
                        source.specialtyxml,
                        source.educationxml,
                        source.imagexml );';

   
                
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  
                     

    merge_statement_1 := 'merge into show.solrproviderredirect as target
                        using ('  || select_statement || ') as source 
                        on source.providercodeold = target.providercodeold and source.providercodenew = target.providercodenew
                        when matched then ' || update_statement ||
                        'when not matched then ' || insert_statement;

    -- this gives no rows in sql server, it does not insert anything
    merge_statement_2 := $$ merge into show.solrproviderredirect as target
                                using ( $$  || select_statement_1 || $$  ) as source
                                on source.providercodenew = target.providercodenew
                                when not matched then $$ || insert_statement;
                                                                
            
    -- this updates the urlold column                   
    update_statement_1 := '  UPDATE show.solrproviderredirect as target 
                                    SET target.providerurlold = source.url
                                    FROM (select
                                        provurl.url,
                                        baseprov.providercode
                                      from
                                        base.providerurl as provurl
                                        join base.provider as baseprov on provurl.providerid = baseprov.providerid) as source
                                    WHERE target.providercodeold = source.providercode
                                    and providerurlold is null; ';                            

                         
    delete_statement := 'delete from
                show.solrproviderredirect
            where
                providercodeold in (
                    select
                        providercode
                    from
                        show.solrprovider);';
                       

---------------------------------------------------------
-------------------  5. execution ------------------------
---------------------------------------------------------

if (is_full) then
    truncate table Show.SOLRProviderRedirect;
end if; 
execute immediate merge_statement_1;
execute immediate merge_statement_2;
execute immediate update_statement_1;
execute immediate delete_statement;

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