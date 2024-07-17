-- etl.spumergeofficephone
begin
	if object_id('tempdb..#swimlane') is not null drop table #swimlane
	select		distinct identity(int, 1,1) as swimlaneID
				,x.OfficeID
				,y.PhoneTypeCode
				,case when len(y.PhoneNumber)>15 then left(y.PhoneNumber,charindex(y.PhoneNumber,'x')) else y.PhoneNumber end as PhoneNumber
				,case when len(y1.PhoneNumber)>15 then left(y1.PhoneNumber,charindex(y1.PhoneNumber,'x')) else y1.PhoneNumber end as PhoneNumberCustomerProduct
				,isnull(y.PhoneRank,1) as PhoneRank
				,'Reltio' as SourceCode
				,x.LastUpdateDate
				,convert(uniqueidentifier, convert(varbinary(20), y.PhoneNumber)) as PhoneID
				,pt.PhoneTypeID
				,x.OfficeCode
				,row_number() over(partition by x.OfficeID, convert(uniqueidentifier, convert(varbinary(20), y.PhoneNumber)), pt.PhoneTypeID order by x.LastUpdateDate desc) as PhoneRowRank
    into		#swimlane
    from(
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, CREATE_DATE as LastUpdateDate, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Phone')  as OfficeJSON
				,json_query(p.PAYLOAD, '$.EntityJSONString.CustomerProduct')  as CustomerProductJSON
            from raw.OfficeProfileProcessingDeDup as d with (nolock)
            inner join raw.OfficeProfileProcessing as p with (nolock) on p.rawOfficeProfileID = d.rawOfficeProfileID
            where p.PAYLOAD is not null 
        ) as w
        where w.OfficeJSON is not null
    ) as x
    cross apply 
    (
        select z.PhoneTypeCode, z.PhoneRank,
            case when z.PhoneNumber not like '%ext.%' then z.PhoneNumber
            else replace(replace(replace(replace(replace(replace(z.PhoneNumber, 'ext', 'x'), '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
            end as PhoneNumber
        from
        (
            select *
            from openjson(x.OfficeJSON) with (
                PhoneTypeCode varchar(50) '$.Type', 
                PhoneNumber varchar(100) '$."FormattedNumber"',
                PhoneRank varchar(100) '$."Rank"')
        ) as z
    ) as y
    outer apply 
    (
        select 
            case when z.PhoneNumber not like '%ext.%' then z.PhoneNumber
            else replace(replace(replace(replace(replace(replace(z.PhoneNumber, 'ext', 'x'), '(', ''), ')', ''), '.', ''), '-', ''), ' ', '')
            end as PhoneNumber
        from
        (
            select *
            from openjson(x.CustomerProductJSON) with (
                PhoneNumber varchar(100) '$."PhonePTODS"'
				)
        ) as z
    ) as y1
    inner join 
    (
        select PhoneTypeID, PhoneTypeCode as PhoneTypeCodeOriginal,
            case when PhoneTypeCode = 'service' then 'Main'
                when PhoneTypeCode = 'fax' then 'Fax'
                else 'unknown' -- won't join below
            end as PhoneTypeCode
        from ODS1Stage.Base.PhoneType 
    ) as pt on pt.PhoneTypeCode = y.PhoneTypeCode
    where nullif(y.PhoneNumber,'') is not null and nullif(y.PhoneTypeCode,'') is not null
  
   	if @OutputDestination = 'ODS1Stage' begin
	
	    --Delete existing office phones
	    delete pc
	    --select *
	    from (select distinct OfficeID from #swimlane) as p
	    inner join ODS1Stage.Base.OfficeToPhone as pc on pc.OfficeID = p.OfficeID
	
	    --Insert office phones
	    insert into ODS1Stage.Base.OfficeToPhone (OfficeToPhoneID, PhoneTypeID, PhoneID, OfficeID, SourceCode, LastUpdateDate, PhoneRank)
	    select newid(), PhoneTypeID, PhoneID, OfficeID, SourceCode, LastUpdateDate, PhoneRank
	    from 
	    (
	        select s.OfficeID, PhoneID, PhoneTypeID, PhoneRank, s.SourceCode, s.LastUpdateDate, s.PhoneRowRank
	        from #swimlane s
			join ODS1Stage.Base.Office o
			on s.OfficeID=o.OfficeID
	    ) as ph
	    where ph.PhoneRowRank = 1
		and (PhoneID is not null and OfficeID is not null)
	end