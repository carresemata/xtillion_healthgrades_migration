create or replace procedure ods1_stage_team.show.sp_load_solrproviderredirect()
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
    merge_condition string; -- merge condition to final table
    update_statement string; -- update statement to final table
    insert_statement string; -- insert statement to final table
    merge_statement string; -- merge statement
    delete_statement string; -- delete statement to final table
    merge_statement_else_1 string; -- insert into statement to final table
    merge_statement_else_2 string; -- merge statement to final table
    status string; -- status monitoring
    procedure_name varchar(50) default('sp_load_solrproviderredirect');
    execution_start datetime default getdate();


   
begin   
        
                                


---------------------------------------------------------
----------------- 3. sql statements ---------------------
---------------------------------------------------------     


        
select_statement := ' with cte_providernotinsolr as (
                        	select	providercodeold 
                        			,providercodenew 
                        			,providerurlold 
                        			,providerurlnew 
                        			,hgidold 
                        			,hgidnew 
                        			,hgid8old 
                        			,hgid8new 
                        			,lastname 
                        			,firstname 
                        			,middlename 
                        			,suffix 
                        			,displayname 
                        			,degree 
                        			,degreepriority 
                        			,providertypeid 
                        			,citystate
                        			,specialtycode
                        			,specialtylegacykey
                        			,deactivationreason
                        			,lastupdatedate 
                        			,row_number() over(partition by providercodeold order by lastupdatedate desc) as sequenceid
                        	from	base.providerredirect
                        	where	providercodeold not in (select providercode from show.solrprovider )
                        )
                        
    
                            select	providercodeold 
                        			,providercodenew 
                        			,providerurlold 
                        			,providerurlnew 
                        			,hgidold 
                        			,hgidnew 
                        			,hgid8old 
                        			,hgid8new 
                        			,lastname 
                        			,firstname 
                        			,middlename 
                        			,suffix 
                        			,displayname 
                        			,degree 
                        			,degreepriority 
                        			,providertypeid 
                        			,citystate
                        			,specialtycode
                        			,specialtylegacykey
                        			,deactivationreason
                        			,lastupdatedate 
                            from cte_providernotinsolr
                            where sequenceid = 1
                            ';

merge_condition := '  ctefinal.providercodeold != solrprovred.providercodeold
                or ctefinal.providercodenew != solrprovred.providercodenew
                or ctefinal.providerurlold != solrprovred.providerurlold
                or ctefinal.providerurlnew != solrprovred.providerurlnew
                or ctefinal.hgidold != solrprovred.hgidold
                or ctefinal.hgidnew != solrprovred.hgidnew
                or ctefinal.hgid8old != solrprovred.hgid8old
                or ctefinal.hgid8new != solrprovred.hgid8new
                or ctefinal.lastname != solrprovred.lastname
                or ctefinal.firstname != solrprovred.firstname
                or ctefinal.middlename != solrprovred.middlename
                or ctefinal.suffix != solrprovred.suffix
                or ctefinal.displayname != solrprovred.displayname
                or ctefinal.degree != solrprovred.degree
                or ctefinal.degreepriority != solrprovred.degreepriority
                or ctefinal.providertypeid != solrprovred.providertypeid
                or ctefinal.citystate != solrprovred.citystate
                or ctefinal.specialtycode != solrprovred.specialtycode
                or ctefinal.specialtylegacykey != solrprovred.specialtylegacykey
                or ctefinal.deactivationreason != solrprovred.deactivationreason
                or ctefinal.lastupdatedate != solrprovred.lastupdatedate';

update_statement := 'update
                        set
                            providercodeold = ctefinal.providercodeold,
                            providercodenew = ctefinal.providercodenew,
                            providerurlold = ctefinal.providerurlold,
                            providerurlnew = ctefinal.providerurlnew,
                            hgidold = ctefinal.hgidold,
                            hgidnew = ctefinal.hgidnew,
                            hgid8old = ctefinal.hgid8old,
                            hgid8new = ctefinal.hgid8new,
                            lastname = ctefinal.lastname,
                            firstname = ctefinal.firstname,
                            middlename = ctefinal.middlename,
                            suffix = ctefinal.suffix,
                            displayname = ctefinal.displayname,
                            degree = ctefinal.degree,
                            degreepriority = ctefinal.degreepriority,
                            providertypeid = ctefinal.providertypeid,
                            citystate = ctefinal.citystate,
                            specialtycode = ctefinal.specialtycode,
                            specialtylegacykey = ctefinal.specialtylegacykey,
                            deactivationreason = ctefinal.deactivationreason,
                            lastupdatedate = ctefinal.lastupdatedate,
                            updatedate = current_timestamp(),
                            updatesource = current_user()';

 insert_statement := 'insert(
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
                        updatesource
                    )
                    values
                    (ctefinal.providercodeold,
                        ctefinal.providercodenew,
                        ctefinal.providerurlold,
                        ctefinal.providerurlnew,
                        ctefinal.hgidold,
                        ctefinal.hgidnew,
                        ctefinal.hgid8old,
                        ctefinal.hgid8new,
                        ctefinal.lastname,
                        ctefinal.firstname,
                        ctefinal.middlename,
                        ctefinal.suffix,
                        ctefinal.displayname,
                        ctefinal.degree,
                        ctefinal.degreepriority,
                        ctefinal.providertypeid,
                        ctefinal.citystate,
                        ctefinal.specialtycode,
                        ctefinal.specialtylegacykey,
                        ctefinal.deactivationreason,
                        ctefinal.lastupdatedate,
                        current_timestamp(),
                        current_user() );';

merge_statement_else_1 := 'merge into show.solrproviderredirect as target
                                    using (
                                        select
                                            solrprov.providercode as providercodeold,
                                            solrprov.providercode as providercodenew,
                                            solrprov.providerurl as providerurlold,
                                            solrprov.providerurl as providerurlnew,
                                            solrprov.lastname,
                                            solrprov.firstname,
                                            solrprov.middlename,
                                            solrprov.suffix,
                                            solrprov.firstname || '' '' || iff(solrprov.middlename is null, '''', solrprov.middlename || '' '') || solrprov.lastname || iff(solrprov.suffix is null,'''', '' '' || solrprov.suffix) as displayname,
                                            solrprov.degree,
                                            solrprov.title,
                                            solrprov.providertypeid,
                                            solrprov.providertypegroup,
                                            ''deactivated'' as deactivationreason,
                                            solrprov.gender as gender,
                                            solrprov.dateofbirth,
                                            solrprov.practiceofficexml,
                                            solrprov.specialtyxml,
                                            solrprov.educationxml,
                                            solrprov.imagexml,
                                            current_timestamp() as lastupdatedate,
                                            current_timestamp() as updatedate,
                                            current_user() as updatesource
                                        from
                                            show.solrprovider solrprov
                                            left join base.provider baseprov on baseprov.providerid = solrprov.providerid
                                            left join show.solrproviderredirect solrprovred on solrprovred.providercodeold = solrprov.providercode
                                            and solrprovred.providercodenew = solrprov.providercode
                                            and solrprovred.deactivationreason = ''deactivated''
                                        where
                                            baseprov.providerid is null
                                            and solrprovred.solrproviderredirectid is null
                                    ) as source
                                    on target.providercodeold = source.providercodeold
                                    when not matched then 
                                        insert (
                                            providercodeold,
                                            providercodenew,
                                            providerurlold,
                                            providerurlnew,
                                            lastname,
                                            firstname,
                                            middlename,
                                            suffix,
                                            displayname,
                                            degree,
                                            title,
                                            providertypeid,
                                            providertypegroup,
                                            deactivationreason,
                                            gender,
                                            dateofbirth,
                                            practiceofficexml,
                                            specialtyxml,
                                            educationxml,
                                            imagexml,
                                            lastupdatedate,
                                            updatedate,
                                            updatesource
                                        )
                                        values (
                                            source.providercodeold,
                                            source.providercodenew,
                                            source.providerurlold,
                                            source.providerurlnew,
                                            source.lastname,
                                            source.firstname,
                                            source.middlename,
                                            source.suffix,
                                            source.displayname,
                                            source.degree,
                                            source.title,
                                            source.providertypeid,
                                            source.providertypegroup,
                                            source.deactivationreason,
                                            source.gender,
                                            source.dateofbirth,
                                            source.practiceofficexml,
                                            source.specialtyxml,
                                            source.educationxml,
                                            source.imagexml,
                                            source.lastupdatedate,
                                            source.updatedate,
                                            source.updatesource
                                        );';
                                                                
            
                        
     merge_statement_else_2 := 'merge into show.solrproviderredirect as solrprovred using (
                                 select
                                    provurl.url,
                                    baseprov.providercode
                                from
                                    base.providerurl as provurl
                                    join base.provider as baseprov on provurl.providerid = baseprov.providerid
                           ) as url on solrprovred.providercodeold = url.providercode
                            and solrprovred.providerurlold is null
                            when matched then
                        update
                        set
                            solrprovred.providerurlold = url.url;';
                
---------------------------------------------------------
--------- 4. actions (inserts and updates) --------------
---------------------------------------------------------  
                     

merge_statement := 'merge into show.solrproviderredirect as solrprovred
                        using ('  || select_statement || ') as ctefinal 
                        on ctefinal.providercodeold = solrprovred.providercodeold
                        when matched and (' || merge_condition ||') then '
                            || update_statement ||
                        'when not matched then '
                            || insert_statement;

                         
delete_statement := 'delete from
                show.solrproviderredirect
            where
                providercodeold in (
                    select
                        providercode
                    from
                        show.solrprovider);';

                    
                        

---------------------------------------------------------
------------------- 5. execution ------------------------
--------------------------------------------------------- 

execute immediate merge_statement_else_1;
execute immediate merge_statement_else_2;
execute immediate merge_statement;
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
