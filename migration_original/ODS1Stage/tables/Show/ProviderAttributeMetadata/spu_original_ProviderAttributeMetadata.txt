-- etl_spuMergeProviderBridgeCalcsAndRanks (snowflake)

-- #ProviderIDs
		INSERT #ProviderIDList (ProviderID, ProviderCode)
		SELECT DISTINCT CASE WHEN P.ProviderID IS NOT NULL THEN p.ProviderID ELSE PDP.ProviderID END AS ProviderID, 
			PDP.PROVIDER_CODE AS ProviderCode 
		FROM Snowflake.raw.ProviderProfileProcessing PDP 
		INNER JOIN ODS1Stage.Base.Provider P ON PDP.PROVIDER_CODE = P.ProviderCode
		ORDER BY (CASE WHEN P.ProviderID IS NOT NULL THEN p.ProviderID ELSE PDP.ProviderID END)

-- #MedicalTerm 
insert into #MedicalTerm (MedicalTermID, MedicalTermTypeCode, RefMedicalTermCode, MedicalTermDescription1)
        select mt.MedicalTermID, mtt.MedicalTermTypeCode, mt.RefMedicalTermCode, mt.MedicalTermDescription1
        from ODS1Stage.Base.MedicalTerm as mt with (nolock)
        inner join ODS1Stage.Base.MedicalTermType as mtt with (nolock) on mtt.MedicalTermTypeID = mt.MedicalTermTypeID
        where mtt.MedicalTermTypeCode in ('Condition', 'Procedure')
        order by mt.MedicalTermID

-- #ProviderEntityToMedicalTermList
insert #ProviderEntityToMedicalTermList (ProviderID, EntityID, MedicalTermID, MedicalTermTypeCode, RefMedicalTermCode, SourceCode, LastUpdateDate,
            isPreview, NationalRankingA, NationalRankingB, NationalRankingBCalc)
		select distinct x.ProviderID, x.EntityID, x.MedicalTermID, mt.MedicalTermTypeCode, mt.RefMedicalTermCode, x.SourceCode, x.LastUpdateDate, 
            x.IsPreview, x.NationalRankingA, x.NationalRankingB, x.NationalRankingBCalc
        from
        (
            select p.ProviderID, emt.EntityID, emt.MedicalTermID, emt.SourceCode, emt.LastUpdateDate, 
            isnull(emt.IsPreview,0) IsPreview, emt.NationalRankingA, emt.NationalRankingB, emt.NationalRankingBCalc
			from #ProviderIDList as p
			inner join ODS1Stage.Base.EntityToMedicalTerm as emt with(nolock) on emt.EntityID = p.ProviderID
        ) as x
		inner join #MedicalTerm as mt on mt.MedicalTermID = x.MedicalTermID
		order by x.EntityID, x.MedicalTermID, mt.MedicalTermTypeCode

-- #UPDATEs
IF OBJECT_ID('tempdb..#UPDATEs') IS NOT NULL DROP TABLE #UPDATEs
		CREATE table #UPDATEs (
			ProviderID uniqueidentifier not null,
			DataElement VARCHAR(100) not null,
			SourceCode VARCHAR(25) not null,
			LastUPDATEDate datetime
		);

		--About Me
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT ptam.ProviderID,'AboutMe ' + AboutMeCode AS DataElement, ISNULL(SourceCode,'N/A'), MAX(ptam.LastUPDATEdDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToAboutMe ptam ON pid.ProviderID = ptam.ProviderID
			INNER JOIN ODS1Stage.Base.AboutMe am ON ptam.AboutMeID = am.AboutMeID
		GROUP BY ptam.ProviderID,AboutMeCode,SourceCode
        order by ptam.ProviderID, AboutMeCode, SourceCode

		--Provider Address:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pto.ProviderID,'Address',ISNULL(ota.SourceCode,'N/A'),MAX(ota.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToOffice PTO ON pid.ProviderID = pto.ProviderID
			INNER JOIN ODS1Stage.Base.OfficeToAddress OTA ON ota.OfficeID = pto.OfficeID
		GROUP BY pto.ProviderID,ota.SourceCode
		order by pto.ProviderID,ota.SourceCode

		--Appointment Availability:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT paa.ProviderID,'Appointment Availability',ISNULL(paa.SourceCode,'N/A'),MAX(paa.InsertedOn)
		FROM #ProviderIDList pid 
			INNER JOIN ODS1Stage.Base.ProviderToAppointmentAvailability paa ON pid.ProviderID = paa.ProviderID
		GROUP BY paa.ProviderID,paa.SourceCode

		--Provider Availability Statement: 
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pas.ProviderID,'Availability Statement',ISNULL(pas.SourceCode,'N/A'),MAX(pas.LastUPDATEdDate)
		FROM #ProviderIDList pid 
			INNER JOIN ODS1Stage.Base.ProviderAppointmentAvailabilityStatement pas ON pid.ProviderID = pas.ProviderID
		GROUP BY pas.ProviderID,pas.SourceCode
		order by pas.ProviderID,pas.SourceCode

        --Certifications: 
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT ptc.ProviderID,'Certifications',ISNULL(ptc.SourceCode,'N/A'),MAX(ptc.InsertedOn)
		FROM #ProviderIDList pid 
			INNER JOIN ODS1Stage.Base.ProviderToCertificationSpecialty ptc ON pid.ProviderID = ptc.ProviderID
		GROUP BY ptc.ProviderID,ptc.SourceCode
		order by ptc.ProviderID,ptc.SourceCode

		--Condition:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT emt.EntityID, MedicalTermTypeCode, ISNULL(emt.SourceCode,'N/A'), LastUPDATEDate = MAX(emt.LastUPDATEDate)
		FROM #ProviderEntityToMedicalTermList AS emt
		WHERE emt.MedicalTermTypeCode = 'Condition'
		GROUP BY emt.EntityID, emt.MedicalTermTypeCode, emt.SourceCode
		order by emt.EntityID, emt.MedicalTermTypeCode, emt.SourceCode

		--Degree:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT ptd.ProviderID,'Degree',ISNULL(ptd.SourceCode,'N/A'),MAX(ptd.LastUPDATEDate)
		FROM #ProviderIDList pid 
			INNER JOIN  ODS1Stage.Base.ProviderToDegree ptd ON pid.ProviderID = ptd.ProviderID
		GROUP BY ptd.ProviderID,ptd.SourceCode

		--FirstName:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT a.ProviderID,'FirstName',ISNULL(a.SourceCode,'N/A'),MAX(a.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.provider a ON pid.ProviderID = a.ProviderID
		GROUP BY a.ProviderID,a.SourceCode
		order by a.ProviderID,a.SourceCode

		--Health Insurance:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT phi.ProviderID,'Health Insurance',ISNULL(phi.SourceCode,'N/A'),MAX(phi.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToHealthInsurance phi ON pid.ProviderID = phi.ProviderID
		GROUP BY phi.ProviderID,phi.SourceCode
		order by phi.ProviderID,phi.SourceCode

		--Hospital Affiliation
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT ptf.ProviderID,'Hospital Affiliation',ISNULL(ptf.SourceCode,'N/A'),MAX(ptf.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToFacility ptf ON pid.ProviderID = ptf.ProviderID
		GROUP BY ptf.ProviderID,ptf.SourceCode
		order by ptf.ProviderID,ptf.SourceCode

		--Languages Spoken:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pl.ProviderID,'Languages Spoken',ISNULL(pl.SourceCode,'N/A'),MAX(pl.LastUPDATEDate)
		FROM  #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToLanguage pl ON pid.ProviderID = pl.ProviderID
		GROUP BY pl.ProviderID,pl.SourceCode
		order by pl.ProviderID,pl.SourceCode

		--LastName:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT a.ProviderID,'LastName',ISNULL(a.SourceCode,'N/A'),MAX(a.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.provider a ON pid.ProviderID = a.ProviderID
		GROUP BY a.ProviderID,a.SourceCode
		order by a.ProviderID,a.SourceCode
		
		--Malpractice:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pm.ProviderID,'Malpractice',ISNULL(pm.SourceCode,'N/A'),MAX(pm.LastUPDATEDate)
		FROM  #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderMalpractice pm ON pid.ProviderID = pm.ProviderID
		GROUP BY pm.ProviderID,pm.SourceCode
		order by pm.ProviderID,pm.SourceCode

		--Media:
        INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pm.ProviderID,'Media',ISNULL(pm.SourceCode,'N/A'),MAX(pm.LastUPDATEDate)
		FROM  #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderMedia pm ON pid.ProviderID = pm.ProviderID
		GROUP BY pm.ProviderID,pm.SourceCode
   
		--Office:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pto.ProviderID,'Office',ISNULL(pto.SourceCode,'N/A'),MAX(pto.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToOffice pto ON pid.ProviderID = pto.ProviderID
		GROUP BY pto.ProviderID,pto.SourceCode
		order by pto.ProviderID,pto.SourceCode

		--Office Fax:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pto.ProviderID,'Office Fax',ISNULL(op.SourceCode,'N/A'),MAX(op.LastUPDATEDate)
		FROM #ProviderIDList pid 
			INNER JOIN ODS1Stage.Base.ProviderToOffice PTO ON pid.ProviderID = PTO.ProviderID
			INNER JOIN ODS1Stage.Base.OfficeToPhone op ON pto.OfficeID = op.OfficeID
			INNER JOIN ODS1Stage.Base.PhoneType pt ON pt.PhoneTypeID = op.PhoneTypeID
		WHERE pt.PhoneTypeCode = 'FAX'
		GROUP BY pto.ProviderID,  op.SourceCode
		order by pto.ProviderID,  op.SourceCode

		--Office Name:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT a.ProviderID,'Office Name',ISNULL(b.SourceCode,'N/A'),MAX(b.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderToOffice a ON pid.ProviderID = a.ProviderID
			INNER JOIN ODS1Stage.Base.Office b ON b.officeID = a.OfficeID
		GROUP BY a.ProviderID,b.SourceCode
		order by a.ProviderID,b.SourceCode

		--Photo:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pimg.ProviderID,'Photo',ISNULL(pimg.SourceCode,'N/A'),MAX(pimg.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderImage pimg ON pid.ProviderID = pimg.ProviderID
		GROUP BY pimg.ProviderID,pimg.SourceCode
		order by pimg.ProviderID,pimg.SourceCode

		--Positions:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT po.ProviderID,'Positions',ISNULL(po.SourceCode,'N/A'),MAX(po.LastUPDATEDate)
		FROM  #ProviderIDList pid 
			INNER JOIN ODS1Stage.Base.ProviderToOrganization po ON pid.ProviderID = po.ProviderID
		WHERE po.PositionEndDate IS NULL
		GROUP BY po.ProviderID,po.SourceCode

		--Practice Name:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT po.ProviderID,'Practice Name',isnull(a.SourceCode,''),MAX(a.LastUPDATEDate)
		FROM ODS1Stage.Base.Practice a 
			INNER JOIN ODS1Stage.Base.Office o ON a.practiceid = o.practiceid 
			INNER JOIN ODS1Stage.Base.ProviderToOffice po ON po.officeid = o.officeid
			INNER JOIN #ProviderIDList pid  ON pid.ProviderID = po.ProviderID
		GROUP BY po.ProviderID,a.SourceCode
		order by po.ProviderID,a.SourceCode

		--Procedure:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT emt.EntityID, MedicalTermTypeCode, ISNULL(emt.SourceCode,'N/A'), LastUPDATEDate = MAX(emt.LastUPDATEDate)
		FROM #ProviderEntityToMedicalTermList AS emt
		WHERE emt.MedicalTermTypeCode ='Procedure'
		GROUP BY emt.EntityID, emt.MedicalTermTypeCode, emt.SourceCode
		order by emt.EntityID, emt.MedicalTermTypeCode, emt.SourceCode

		-- Sanctions:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT ps.ProviderID,'Sanctions',ISNULL(ps.SourceCode,'N/A'),MAX(ps.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderSanction ps ON pid.ProviderID = ps.ProviderID
		GROUP BY ps.ProviderID,ps.SourceCode
		order by ps.ProviderID,ps.SourceCode

		--Specialty:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT pts.ProviderID,'Specialty',ISNULL(pts.SourceCode,'N/A'),MAX(pts.InsertedOn)
		FROM  #ProviderIDList pid 
			INNER JOIN ODS1Stage.Base.ProviderToSpecialty pts ON pid.ProviderID = pts.ProviderID
		GROUP BY pts.ProviderID,pts.SourceCode
		order by pts.ProviderID,pts.SourceCode

		--Video:
		INSERT INTO #UPDATEs (ProviderID, DataElement, SourceCode, LastUPDATEDate)
		SELECT a.ProviderID,'Video',ISNULL(a.SourceCode,'N/A'),MAX(a.LastUPDATEDate)
		FROM #ProviderIDList pid
			INNER JOIN ODS1Stage.Base.ProviderVideo a ON pid.ProviderID = a.ProviderID
		GROUP BY a.ProviderID,a.SourceCode
		order by a.ProviderID,a.SourceCode

-- #UpdateTrackingXML
insert into #UpdateTrackingXML (ProviderID, ProviderCode, UpdateTrackingXML)
        select x.ProviderID, x.ProviderCode, x.UpdateTrackingXML
		from 
        (
            select p.ProviderID, p.ProviderCode,
                (
                    select u.DataElement as elem,
						u.SourceCode as src,
						u.LastUPDATEDate as upd
						from #UPDATEs u
						where u.ProviderID = p.ProviderID
						order by u.DataElement
						for xml raw('de'), elements, root('prov'), type
				) as UpdateTrackingXML
		    from #ProviderIDList p
			group by p.ProviderID, p.ProviderCode
        ) as x

update c set c.UpdateTrackingXML = null
        --select c.UpdateTrackingXML
        from #ProviderIDList as p
        inner join ODS1Stage.Show.ProviderAttributeMetadata as c on c.ProviderID = p.ProviderID
        where c.UpdateTrackingXML is not null


update dest set dest.ProviderCode = src.ProviderCode, dest.UpdateTrackingXML = src.UpdateTrackingXML
		from #UpdateTrackingXML as src
        inner join ODS1Stage.Show.ProviderAttributeMetadata as dest on dest.ProviderID = src.ProviderID

insert into ODS1Stage.Show.ProviderAttributeMetadata(ProviderID, ProviderCode, UpdateTrackingXML)
        select src.ProviderID, src.ProviderCode, src.UpdateTrackingXML
		from #UpdateTrackingXML as src
        where not exists (select 1 from ODS1Stage.Show.ProviderAttributeMetadata as dest where dest.ProviderID = src.ProviderID)