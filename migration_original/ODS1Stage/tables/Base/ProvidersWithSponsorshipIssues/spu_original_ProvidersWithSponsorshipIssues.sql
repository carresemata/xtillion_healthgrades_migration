SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Mid].[spuRecordPostRulesEngineDataIssues]
as
/*-------------------------------------------------------------------------------------------------------------
Created By    : Erik Shaw
Created On    : 8/28/17
Description   : Record a list of Post-RulesEngine issues into Base.ProvidersWithSponsorshipIssues

Test:
    exec Mid.spuRecordPostRulesEngineDataIssues

--------------------------------------------------------------------------------------------------------------*/
declare @_ErrorProcedure varchar(max), @_ErrorLine int, @_ErrorMessage varchar(1000), @IssueDescription varchar(max)

begin try
    --Base.ProvidersWithSponsorshipIssues is reset every time this proc is run
    truncate table Base.ProvidersWithSponsorshipIssues

    --http://hgprodbiapp01/ReportServer/Pages/ReportViewer.aspx?%2fOperational+Monitoring%2fTest+Case+Result+Detail&TestCaseId=744&TestCaseBatchId=373852
    --ODS_Mid: Providers should only have a max of one sponsorship

    /*
        select distinct ProviderCode, ClientCode  
         from  mid.providersponsorship
         WHERE ProductCode<>'lid'

        select providercode, COUNT(*) as sponsors from $1  group by providercode having COUNT(*) > 1
    */
    create table #provider (ProviderCode varchar(50) primary key clustered)

    truncate table #provider        

    insert into #provider (ProviderCode)
    select distinct ProviderCode
    from
    (
        select ProviderCode, ClientCode
        from ODS1Stage.Mid.ProviderSponsorship with (nolock)
        where ProductCode <> 'lid'
        group by ProviderCode, ClientCode
    ) as y
    group by ProviderCode
    having count(*) > 1
    order by ProviderCode

    if @@ROWCOUNT > 0 begin
        set @IssueDescription = 'Non-LID Provider has more than one sponsorship record in ODS1Stage.Mid.ProviderSponsorship'

        insert into Base.ProvidersWithSponsorshipIssues (ProviderCode, IssueDescription)
        select p.ProviderCode, @IssueDescription
        from #provider as p
        where not exists (select 1 from Base.ProvidersWithSponsorshipIssues as i where i.ProviderCode = p.ProviderCode and i.IssueDescription = @IssueDescription)
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------
    --http://hgprodbiapp01/ReportServer/Pages/ReportViewer.aspx?%2fOperational+Monitoring%2fTest+Case+Result+Detail&TestCaseId=745&TestCaseBatchId=373852
    --ODS_Mid: Providers for PDC-Practice having no Office/Practice sponsorship data
    /*
	
        SELECT            [ProviderCode]
        FROM              [ODS1Stage].[Mid].[ProviderSponsorship]
        WHERE            [ProductCode] = 'PDCPRAC'
                                AND OfficeCode IS NULL
    */
    truncate table #provider        

    insert into #provider (ProviderCode)
    select distinct ProviderCode
    from ODS1Stage.Mid.ProviderSponsorship with (nolock)
    where ProductCode = 'PDCPRAC' and OfficeCode is null
    order by ProviderCode

    if @@ROWCOUNT > 0 begin
        set @IssueDescription = 'PDCPRAC Provider has a null OfficeCode in ODS1Stage.Mid.ProviderSponsorship'

        insert into Base.ProvidersWithSponsorshipIssues (ProviderCode, IssueDescription)
        select p.ProviderCode, @IssueDescription
        from #provider as p
        where not exists (select 1 from Base.ProvidersWithSponsorshipIssues as i where i.ProviderCode = p.ProviderCode and i.IssueDescription = @IssueDescription)
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------
    --http://hgprodbiapp01/ReportServer/Pages/ReportViewer.aspx?%2fOperational+Monitoring%2fTest+Case+Result+Detail&TestCaseId=746&TestCaseBatchId=373852
    --ODS_Mid: PhoneXML is NULL in Mid.ProviderSponsorship for PDC Hospital
    /*
        SELECT ps.providercode,ClientCode,ClientName,p.FirstName,p.LastName--,*
        FROM mid.providersponsorship ps with(nolock)
        join Mid.Provider p with(nolock) on p.ProviderCode = ps.ProviderCode
        WHERE ProductCode in ('PDCHSP','PDCPRAC')
        AND PhoneXML is NULL
    */
    truncate table #provider        

    insert into #provider (ProviderCode)
    select distinct ps.ProviderCode
    from ODS1Stage.Mid.ProviderSponsorship ps with (nolock)
    join ODS1Stage.Mid.Provider p with (nolock) on p.ProviderCode = ps.ProviderCode
    where ps.ProductCode in ('PDCHSP', 'PDCPRAC') and ps.PhoneXML is null
    order by ProviderCode

    if @@ROWCOUNT > 0 begin
        set @IssueDescription = 'PDCHSP/PDCPRAC Provider has more a null PhoneXML in ODS1Stage.Mid.ProviderSponsorship'

        insert into Base.ProvidersWithSponsorshipIssues (ProviderCode, IssueDescription)
        select p.ProviderCode, @IssueDescription
        from #provider as p
        where not exists (select 1 from Base.ProvidersWithSponsorshipIssues as i where i.ProviderCode = p.ProviderCode and i.IssueDescription = @IssueDescription)
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------
    --http://hgprodbiapp01/ReportServer/Pages/ReportViewer.aspx?%2fOperational+Monitoring%2fTest+Case+Result+Detail&TestCaseId=747&TestCaseBatchId=373852
    --ODS_Mid: FacilityCode is NULL in Mid.ProviderSponsorship for PDC Hospital
    /*
        SELECT ps.providercode,ClientCode,ClientName,p.FirstName,p.LastName--,*
        FROM mid.providersponsorship ps with(nolock)
        join Mid.Provider p with(nolock) on p.ProviderCode = ps.ProviderCode
        WHERE ProductCode = 'PDCHSP'
        AND FacilityCode IS NULL
    */
    truncate table #provider        

    insert into #provider (ProviderCode)
    select distinct ps.ProviderCode
    from ODS1Stage.Mid.ProviderSponsorship ps with (nolock)
    join ODS1Stage.Mid.Provider p with (nolock) on p.ProviderCode = ps.ProviderCode
    where ps.ProductCode = 'PDCHSP' and ps.FacilityCode is null
    order by ProviderCode

    if @@ROWCOUNT > 0 begin
        set @IssueDescription = 'PDCHSP Provider has a null FacilityCode in ODS1Stage.Mid.ProviderSponsorship'

        insert into Base.ProvidersWithSponsorshipIssues (ProviderCode, IssueDescription)
        select p.ProviderCode, @IssueDescription
        from #provider as p
        where not exists (select 1 from Base.ProvidersWithSponsorshipIssues as i where i.ProviderCode = p.ProviderCode and i.IssueDescription = @IssueDescription)
    end

    ------------------------------------------------------------------------------------------------------------------------------------------------

end try     
begin catch
    select @_ErrorProcedure = object_name(@@PROCID), @_ErrorLine = error_line(), @_ErrorMessage = error_message()
    raiserror('Error in procedure %s on line %i: %s', 18, 1, @_ErrorProcedure, @_ErrorLine, @_ErrorMessage)
end catch

GO