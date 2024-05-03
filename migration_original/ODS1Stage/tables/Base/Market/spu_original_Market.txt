SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Mid].[spuInsertRequestedMarketLocationsMissingFromODS2] 

as

/*************************************************************************
**
**	FILE:			spuInsertRequestedMarketLocationsMissingFromODS2.sql
**
**	CALLED BY:		
**	
**	PARAMATERS:		
**
**	CREATE BY:		Paul Orrison
**	CREATE DATE:	2013/03/01
**
**
**	MODIFY BY:	    
**	MODIFY DATE:	
**  MODIFICATION:   
**
**	PURPOSE:		This SP will create market reference data in the ODS
**					so the Admin tool can use them.  Not all market reference 
**					data exists in the ODS, it only contains data that is in
**					current use.  Based on specific location requests, this SP
**					will load all market reference data that does not already
**					exist.
**
**  Execution		exec req.spuInsertRequestedMarketLocationsMissingFromODS2
**************************************************************************
**	MODIFIED BY		MODIFIED DATE		COMMENTS
**************************************************************************
**
**************************************************************************/

insert Base.Market (MarketID, GeographicAreaID, LineOfServiceID, MarketCode, LegacyKey, LegacyKeyName, SourceCode, LastUpdateDate)
select distinct mk.MarketGUID as MarketID, mk.GeographicAreaGUID as GeographicAreaID, mk.LineOfServiceGUID as LineOfServiceID, 
		mk.MarketCode, mk.LegacyClientMarketID as LegacyKey, 'ClientMarketID' as LegacyKeyName, 
		ss.SourceCode, mk.LastUpdateDate
from Base.MarketMaster as mk
	inner join Base.GeographicArea ga on mk.GeographicAreaGUID = ga.GeographicAreaID
	inner join dbo.RequestedMarketLocationsMissingFromODS2 missing on ga.GeographicAreaValue1 = missing.GeographicAreaValue1
		and ISNULL(ga.GeographicAreaValue2,'') = isnull(missing.GeographicAreaValue2, '')
	left join Base.Market bm on mk.MarketGUID = bm.MarketID
	left join Base.Source ss ON mk.SYSTEM_SRC_GUID = ss.SourceID
where mk.EndDate > dateadd(day, -180, getdate()) or mk.EndDate is null
    and bm.MarketID is null --and GeographicAreaValue1 = '19129'
GO