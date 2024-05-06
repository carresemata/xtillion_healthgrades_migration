	if object_id('tempdb..#swimlane') is not null drop table #swimlane
    select distinct x.ReltioEntityID,
        x.OfficeID,
        convert(uniqueidentifier, convert(varbinary(20), y.PracticeCode)) as PracticeID,
        convert(uniqueidentifier, convert(varbinary(20), y.SourceCode)) as SourceID, 
        y.LastUpdateDate, y.SourceCode, x.OfficeCode, y.PracticeCode, y.CustomerProductCode as ClientToProductCode,
		cp.ClientToProductID,
		convert(uniqueidentifier, HASHBYTES('SHA1', Concat(y.CustomerProductCode,rt.RelationshipTypeCode,y.PracticeCode,x.OfficeCode) )) as ClientProductEntityRelationshipID,
		rt.RelationshipTypeID,
        ROW_NUMBER() over(partition by x.OfficeID order by x.CREATE_DATE desc) as RowRank
    into #swimlane
    from
    (
        select w.* 
        from
        (
            select p.CREATE_DATE, p.RELTIO_ID as ReltioEntityID, p.OFFICE_CODE as OfficeCode, p.OfficeID, 
                json_query(p.PAYLOAD, '$.EntityJSONString.Practice') as OfficeJSON
            from raw.OfficeProfileProcessingDeDup as d with (nolock)
            inner join raw.OfficeProfileProcessing as p with (nolock) on p.rawOfficeProfileID = d.rawOfficeProfileID
            where p.PAYLOAD is not null
        ) as w
        where w.OfficeJSON is not null
    ) as x
	join ODS1Stage.Base.RelationshipType rt on rt.RelationshipTypeCode = 'PRACTOOFF'
    cross apply 
    (
        select *
        from openjson(x.OfficeJSON) with (
            CustomerProductCode varchar(50) '$.CustomerProductCode', 
            LastUpdateDate datetime '$.LastUpdateDate', 
            PracticeCode varchar(50) '$.PracticeCode', 
            SourceCode varchar(25) '$.SourceCode')
    ) as y
    join ODS1Stage.Base.ClientToProduct as cp on cp.ClientToProductCode = y.CustomerProductCode
	where y.CustomerProductCode is not null and y.PracticeCode is not null


	if @OutputDestination = 'ODS1Stage' begin
	    --Insert all ClientProductEntityRelationship records for PRACTOOFF
		insert into ODS1Stage.Base.ClientProductEntityRelationship (ClientProductEntityRelationshipID, RelationshipTypeID, ParentID, ChildID, SourceCode, LastUpdateDate)
		select s.ClientProductEntityRelationshipID, s.RelationshipTypeID, convert(uniqueidentifier, hashbytes('SHA1', concat(ClientToProductCode,pe.EntityTypeCode, s.PracticeCode) )) as ParentID,
			convert(uniqueidentifier, hashbytes('SHA1', concat(ClientToProductCode,ce.EntityTypeCode,ReltioEntityID) )) as ChildID, isnull(s.SourceCode, 'Reltio') as SourceCode, 
			isnull(s.LastUpdateDate, getutcdate()) as LastUpdateDate
		from #swimlane s
			join ODS1Stage.Base.EntityType pe on pe.EntityTypeCode='PRAC'
			join ODS1Stage.Base.EntityType ce on ce.EntityTypeCode='OFFICE'
			join ODS1Stage.Base.ClientProductToEntity cpep 
				on convert(uniqueidentifier, HASHBYTES('SHA1', Concat(ClientToProductCode,pe.EntityTypeCode,PracticeCode) ))=cpep.ClientProductToEntityID
			join ODS1Stage.Base.ClientProductToEntity cpeo 
			on convert(uniqueidentifier, HASHBYTES('SHA1', Concat(ClientToProductCode,ce.EntityTypeCode,OfficeCode) ))=cpeo.ClientProductToEntityID
		left join	ODS1Stage.Base.ClientProductEntityRelationship t
					on t.ClientProductEntityRelationshipID = s.ClientProductEntityRelationshipID
		where s.RowRank = 1
			and cpep.ClientToProductID=cpeo.ClientToProductID
			and t.ClientProductEntityRelationshipID is null
	end