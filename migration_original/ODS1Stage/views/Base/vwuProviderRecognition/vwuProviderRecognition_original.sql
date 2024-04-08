ALTER VIEW [Base].[vwuProviderRecognition]
as

select distinct 
p.ProviderID, a.AwardID
from Base.Provider p
inner join Base.Award a on a.AwardCode = 'HGRECOG'
inner join Base.ProviderToCertificationSpecialty ptcs on ptcs.ProviderID = p.ProviderID
inner join Base.CertificationStatus as cs on cs.CertificationStatusID = ptcs.CertificationStatusID and cs.CertificationStatusCode = 'C' 
left outer join --exclude providers with severe sanctions or any sanctions within last 5 years
  (select distinct x.ProviderID
   from
     (select ps.ProviderID, sa.SanctionActionDescription, ps.SanctionDate
      from Base.ProviderSanction ps
      left outer join Base.SanctionAction sa
        on ps.SanctionActionID = sa.SanctionActionID
     ) x
   where x.SanctionActionDescription in ('Probation','Revocation','Probation Modification Order','Probation Terminated (Ended)','Surrender','Suspension')
      or DATEADD(yy,5,SanctionDate) > GETDATE()
  ) ps
  on p.ProviderID = ps.ProviderID
left outer join Base.ProviderMalpractice pm --exclude providers with malpractice within last 5 years
  on p.ProviderID = pm.ProviderID
 and (
		DATEADD(yy,5,TRY_CONVERT(DATE, CASE WHEN pm.ClaimDate > '5000-01-01' THEN '5000-01-01' ELSE pm.ClaimDate END)) > GETDATE() 
		OR DATEADD(yy,5,TRY_CONVERT(DATE, pm.ClosedDate)) > GETDATE() 
		OR DATEADD(yy,5,TRY_CONVERT(DATE, pm.IncidentDate)) > GETDATE()  
		OR DATEADD(yy,5,TRY_CONVERT(DATE, pm.ReportDate)) > GETDATE()  
		OR DATEADD(yy,5,convert(datetime, '12/31/'+convert(varchar,pm.ClaimYear))) > GETDATE()
	)
where ps.ProviderID IS NULL
and pm.ProviderID IS NULL;

GO