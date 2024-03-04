------- 1. HACK.SPUSOLRPRACTICE

	update sp
	set SponsorshipXML = null
	--select * 
	from Show.SOLRPractice sp
	join Mid.PracticeSponsorship ps on ps.PracticeID = sp.PracticeID
	join Base.Client c on ps.ClientCode = c.ClientCode
	join Show.ClientContract cc on c.ClientID = cc.ClientID
	where cc.ContractStartDate > getdate()
	
	--THIS IS A HACK FOR THE HGID FIELD FOR SOLRPRACTICE
	update a
	set a.LegacyKeyPractice = 'HGPPZ'+left(replace(PracticeID,'-',''), 16)
	--select *
	from Show.SOLRPractice a
	where LegacyKeyPractice is null



------- 2. SHOW.SPUREMOVEPRACTICEWITHNOPROVIDER

delete p
-- SELECT p.PracticeID,PracticeCode, PracticeName,OfficeXML, ISNULL(a1.PhysicianCount,0) AS PhysicianCount
FROM Show.SOLRPractice p
LEFT JOIN
            (
                        SELECT            DISTINCT c.PracticeID, COUNT (a.ProviderID) as 'PhysicianCount'
                        FROM  Base.ProviderToOffice AS a WITH (NOLOCK)
                                                JOIN Base.Office AS b WITH (NOLOCK) ON b.OfficeID = a.OfficeID
                                                JOIN Base.Practice AS c WITH (NOLOCK) ON c.PracticeID = b.PracticeID
                                                JOIN Show.SOLRProvider d ON a.ProviderID = d.ProviderID
                        GROUP BY c.PracticeID          
 
            ) a1      ON p.PracticeID = a1.PracticeID
WHERE ISNULL(a1.PhysicianCount,0) = 0