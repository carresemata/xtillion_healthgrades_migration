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
			
		
		    /*Insert new method records*/
		    insert into ODS1Stage.Base.TelehealthMethod(TelehealthMethodTypeId, TelehealthMethod, ServiceName, SourceCode, LastUpdatedDate)
		    select		MT.TelehealthMethodTypeId, X.TelehealthMethod, X.ServiceName, X.SourceCode, X.LastUpdatedDate
		    from(
			    select	distinct TeleHealthPhone as TelehealthMethod, 'PHONE' as MethodTypeCode, TeleHealthVendorName as ServiceName, SourceCode, LastUpdatedDate from #swimlane where TeleHealthPhone is not null
			    union all
			    select	distinct TeleHealthURL as TelehealthMethod, 'URL' as MethodTypeCode, TeleHealthVendorName as ServiceName, SourceCode, LastUpdatedDate from #swimlane where TeleHealthURL is not null
			    union all
			    select	distinct TeleHealthURL as TelehealthMethod, 'NA' as MethodTypeCode, TeleHealthVendorName as ServiceName, SourceCode, LastUpdatedDate from #swimlane where TeleHealthURL is null and TeleHealthPhone is null
		    )X
		    inner join	ODS1Stage.Base.TelehealthMethodType MT on MT.MethodTypeCode = X.MethodTypeCode
		    left join	ODS1Stage.Base.TelehealthMethod T on T.TelehealthMethodTypeId = MT.TelehealthMethodTypeId and T.TelehealthMethod = X.TelehealthMethod
		    where		X.TelehealthMethod is not null
					    and T.TelehealthMethodId is null
		
	    end