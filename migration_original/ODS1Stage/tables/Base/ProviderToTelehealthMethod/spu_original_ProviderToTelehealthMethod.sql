-- etl.spumergeprovidertelehealth
    begin
        --Reltio telehealth JSON
	    if object_id('tempdb..#swimlane') is not null drop table #swimlane
        select		distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID
					,x.ProviderCode
				    ,convert(uniqueidentifier, convert(varbinary(20), y.SourceCode)) as SourceID
				    ,y.HasTeleHealth
				    ,y.TeleHealthURL
				    ,y.TeleHealthPhone
				    ,y.TeleHealthVendorName
				    ,y.SourceCode
				    ,CREATE_DATE as LastUpdatedDate
				    ,row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end) order by y.ProviderCode, x.CREATE_DATE desc) as RowRank
        into		#swimlane
        from(
            select		p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
					    json_query(p.PAYLOAD, '$.EntityJSONString') as ProviderJSON
		    from		raw.ProviderProfileProcessingDeDup as d with (nolock)
		    inner join	raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
        ) as x
        left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
        cross apply(
			select case when isnull(HasTeleHealth, 'N') in ('yes', 'true', '1', 'Y', 'T') then 'TRUE' else 'FALSE' end as HasTeleHealth,
				TeleHealthURL, TeleHealthPhone, TeleHealthVendorName, SourceCode, ProviderCode
            from	openjson(x.ProviderJSON) with 
		    (
			    HasTeleHealth varchar(10) '$.HasTeleHealth'
                ,TeleHealthURL varchar(1000) '$.TeleHealthURL'
			    ,TeleHealthPhone varchar(50) '$.TeleHealthPhone'
                ,TeleHealthVendorName varchar(50) '$.TeleHealthVendorName'
                ,SourceCode varchar(50) '$.SourceCode'
                ,ProviderCode varchar(50) '$.ProviderCode'
		    )
        )y
	    where	HasTeleHealth = 'TRUE'
	
        if (select count(*) from #swimlane) = 0 begin
            --Profisee telehealth format
            insert into #swimlane (ProviderID, ProviderCode, SourceID, HasTeleHealth, TeleHealthURL, TeleHealthPhone, TeleHealthVendorName, SourceCode, LastUpdatedDate, RowRank)
            select		distinct case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end as ProviderID
						,x.ProviderCode
				        ,convert(uniqueidentifier, convert(varbinary(20), y.SourceCode)) as SourceID
				        ,y.HasTeleHealth
				        ,y.TeleHealthURL
				        ,y.TeleHealthPhone
				        ,y.TeleHealthVendorName
				        ,y.SourceCode
				        ,isnull(y.LastUpdatedDate, getutcdate()) as LastUpdatedDate
				        ,row_number() over(partition by (case when pID.ProviderID is not null then pID.ProviderID else x.ProviderID end) order by y.ProviderCode, x.CREATE_DATE desc) as RowRank
            from(
                select		p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.PROVIDER_CODE as ProviderCode, p.ProviderID, 
					        json_query(p.PAYLOAD, '$.EntityJSONString.Telehealth') as ProviderJSON
		        from		raw.ProviderProfileProcessingDeDup as d with (nolock)
		        inner join	raw.ProviderProfileProcessing as p with (nolock) on p.rawProviderProfileID = d.rawProviderProfileID
            ) as x
            left join ODS1Stage.Base.Provider as pID on pID.ProviderCode = x.ProviderCode
            cross apply(
                select case when isnull(tHasTeleHealth, 'N') in ('yes', 'true', '1', 'Y', 'T') then 'TRUE' else 'FALSE' end as HasTeleHealth,
                    TeleHealthURL, TeleHealthPhone, TeleHealthVendorName, SourceCode, ProviderCode, LastUpdatedDate
                from	openjson(x.ProviderJSON) with 
		        (
 			        tHasTeleHealth varchar(10) '$.HasTelehealth'
                    ,TeleHealthURL varchar(1000) '$.TelehealthURL'
			        ,TeleHealthPhone varchar(50) '$.TelehealthPhone'
                    ,TeleHealthVendorName varchar(50) '$.TelehealthVendorName'
                    ,SourceCode varchar(50) '$.SourceCode'
					,LastUpdatedDate datetime '$.LastUpdateDate'
                    ,ProviderCode varchar(50) '$.ProviderCode'
		        )
            )y
	        where	HasTeleHealth = 'TRUE'
        end

	    if @OutputDestination = 'ODS1Stage' begin
		    update	#swimlane
		    set		SourceCode = 'Profisee'
				    ,SourceID = convert(uniqueidentifier, convert(varbinary(20), 'Profisee')) 
		    where	SourceCode is null
			
		    /*Delete existing records*/
	        delete		T
	        --select *
	        from		raw.ProviderProfileProcessingDeDup as d with (nolock)
			inner join ODS1Stage.Base.Provider as p on p.ProviderCode = d.ProviderCode
	        inner join	ODS1Stage.Base.ProviderToTelehealthMethod as T on T.ProviderId = p.ProviderID
		
		
		    /*Insert new provider records*/
		    insert into ODS1Stage.Base.ProviderToTelehealthMethod(ProviderId, TelehealthMethodId, SourceCode, LastUpdatedDate)
		    select	P.ProviderID, M.TelehealthMethodId, X.SourceCode, X.LastUpdatedDate
		    from(
			    select	distinct ProviderID, ProviderCode, TeleHealthPhone as TelehealthMethod, 'PHONE' as MethodTypeCode, SourceCode, LastUpdatedDate from #swimlane as s where TeleHealthPhone is not null
			    union all
			    select	distinct ProviderID, ProviderCode, TeleHealthURL as TelehealthMethod, 'URL' as MethodTypeCode, SourceCode, LastUpdatedDate from #swimlane where TeleHealthURL is not null
			    union all
			    select	distinct ProviderID, ProviderCode, 'NONE' as TelehealthMethod, 'NA' as MethodTypeCode, SourceCode, LastUpdatedDate from #swimlane where TeleHealthURL is null and TeleHealthPhone is null
		    )X
		    inner join	ODS1Stage.Base.TelehealthMethodType MT on MT.MethodTypeCode = X.MethodTypeCode
		    inner join	ODS1Stage.Base.TelehealthMethod M on M.TelehealthMethodTypeId = MT.TelehealthMethodTypeId and M.TelehealthMethod = X.TelehealthMethod
		    inner join	ODS1Stage.Base.Provider P on P.ProviderCode = X.ProviderCode
		    left join	ODS1Stage.Base.ProviderToTelehealthMethod T on T.ProviderId = P.ProviderID and T.TelehealthMethodId = M.TelehealthMethodId 
		    where		T.ProviderToTelehealthMethodId is null
	    end