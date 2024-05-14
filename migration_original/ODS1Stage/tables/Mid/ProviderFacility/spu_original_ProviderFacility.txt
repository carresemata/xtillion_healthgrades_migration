begin try drop table #ProviderBatch end try begin catch end catch
        create table #ProviderBatch (ProviderID uniqueidentifier)
        
        if @IsProviderDeltaProcessing = 0 begin
		
			truncate table mid.ProviderFacility

            insert into #ProviderBatch (ProviderID) 
			select a.ProviderID 
			from ODS1Stage.Base.Provider as a 
			order by a.ProviderID

          end
        else begin
			insert into #ProviderBatch (ProviderID)
            select a.ProviderID
            from Snowflake.etl.ProviderDeltaProcessing as a
        end
        
						
	--build a temp table to hold the Service Line To Specialty Mappings
		begin try drop table #ServiceLineSpecialty end try begin catch end catch
		select distinct a.ServiceLineCode, b.LegacyKey, a.SpecialtyCode as MedicalTermCode
		into #ServiceLineSpecialty
		from Base.TempSpecialtyToServiceLineGhetto a  --removed view Base.vwuSpecialtyToServiceLine so that join of b.SpecialtyGroupCode = a.SpecialtyCode is not mistakenly left in place when Base.vwuSpecialtyToServiceLine is changed to use new specialy model
		inner join Base.SpecialtyGroup as b on b.SpecialtyGroupCode = a.SpecialtyCode

	--build a temp table with the same structure as the Mid.ProviderFacility
		begin try drop table #ProviderFacility end try begin catch end catch
		select top 0 *
		into #ProviderFacility
		from Mid.ProviderFacility
		
		alter table #ProviderFacility
		add ActionCode int default 0

	begin try drop table #ParentChild end try begin catch end catch

	-- Creating the Parent-Child temp table for all the facilities
		SELECT	a.FacilityIDParent,
				a.FacilityIDChild,
				b.Name AS ChildFacilityName,
				1 AS CurrentMerge
		INTO	#ParentChild       
		FROM	ERMART1.Facility.FacilityParentChild a
				JOIN ERMART1.Facility.Facility b ON a.FacilityIDChild = b.FacilityID		
		WHERE	a.IsMaxYear = 1
				AND b.IsClosed = 0
				
		UNION
		
		SELECT	a.FacilityIDParent,
				a.FacilityIDChild,
				b.Name AS ChildFacilityName,
				0 AS CurrentMerge
		FROM	ERMART1.Facility.FacilityParentChild a
				JOIN ERMART1.Facility.Facility b on (a.FacilityIDChild = b.FacilityID)
		WHERE	a.IsMaxYear = 0
				AND b.IsClosed = 0


	-- Creating Temp Table to Calculate QualitySort Value
	begin try drop table #TempQualityScoreTable end try begin catch end catch

    SELECT            DISTINCT qq.FacilityID,qq.ServiceLineCode, qq.ServiceLineDescription,
                            (
                  
                            SELECT  AVG((ISNULL(z.OverallSurvivalStar,1) * ISNULL(z.OverallRecovery30Star,1)) + (0.5 * ISNULL(z.OverallSurvivalStar,0.001)) + (ISNULL(z.OverallRecovery30Star,0.001))) 
                                                    + ( COUNT(z.OverallSurvivalStar) + COUNT(z.OverallRecovery30Star) )* 0.25

                            FROM  ERMART1.Facility.FacilityToProcedureRating z
                                                    JOIN ERMART1.Facility.[Procedure] b on (z.ProcedureID = b.ProcedureID)
                                                    JOIN ERMART1.Facility.ProcedureToServiceLine y on (z.ProcedureID = y.ProcedureID)
                                                    JOIN 
                                                                (
                                                                            select MedicalTermCode as ProcedureCode, a.LegacyKey, MedicalTermDescription1 as ProcedureDescription
                                                                            from Base.MedicalTerm a
                                                                            join Base.MedicalTermType b on (a.MedicalTermTYpeID = b.MedicalTermTypeID)
                                                                            where b.MedicalTermTypeCode = 'COHORT'
                                                                )zz on (y.ProcedureID = zz.LegacyKey)
                            WHERE            z.FacilityID = qq.FacilityID
                                                    and z.IsMaxYear = qq.IsMaxYear
                                                    and 'SL'+y.ServiceLineID = qq.LegacyKey
                                                    and z.RatingSourceID = qq.RatingSourceID
                                                    and (z.OverallSurvivalStar IS NOT NULL OR z.OverallRecovery30Star IS NOT NULL)
                         
                                                                
                ) AS ratingsSortValue                                                                                                              
    INTO #TempQualityScoreTable
	FROM
		(	SELECT	zz.FacilityID, zz.ProcedureID, zz.RatingSourceID, zz.IsMaxYear, 
					aa.ServiceLineCode, aa.ServiceLineDescription, aa.LegacyKey

			FROM	ERMART1.Facility.FacilityToProcedureRating zz
					JOIN ERMART1.Facility.vwuFacilityHGDisplayProcedures yy on (zz.ProcedureID = yy.ProcedureID and zz.RatingSourceID = yy.RatingSourceID)
					JOIN ERMART1.Facility.ProcedureToServiceLine xx on (yy.ProcedureID = xx.ProcedureID)
					JOIN ERMART1.Facility.ServiceLine ww on (xx.ServiceLineID = ww.ServiceLineID)
					LEFT JOIN ERMART1.Facility.FacilityToServiceLineRating vv on (ww.ServiceLineID = vv.ServiceLineID and zz.FacilityID = vv.FacilityID and vv.IsMaxYear = 1)
					JOIN 
						(
							select MedicalTermCode as ServiceLineCode, a.LegacyKey, MedicalTermDescription1 as ServiceLineDescription
							from Base.MedicalTerm a
							join Base.MedicalTermType b on (a.MedicalTermTYpeID = b.MedicalTermTypeID)
							where b.MedicalTermTypeCode = 'SERVICELINE'																		
						)aa on ('SL'+ww.ServiceLineID = aa.LegacyKey)
			WHERE	zz.IsMaxYear = 1	
		) qq	
	
	create index temp1 on #TempQualityScoreTable (ServiceLineCode)			
		
		
	
	--creating a temp table to store the Provider, Specialty, Serviceline combo	for a Providers Primary Specialty
	begin try drop table #tempProviderSpecialtyServiceLine end try begin catch end catch
	select a.ProviderID, a.SpecialtyCode, b.ServiceLineCode
	into #tempProviderSpecialtyServiceLine
	from Base.vwuProviderSpecialty a
	join #ServiceLineSpecialty b on (a.SpecialtyCode = b.MedicalTermCode)
	where SpecialtyRank = 1	
	
	create index temp2 on #tempProviderSpecialtyServiceLine (ServiceLineCode)
		
				
		--populate the temp table with data from Base schemas
		insert into #ProviderFacility 
			(
				ProviderToFacilityID,ProviderID,FacilityID,FacilityCode,FacilityName,IsClosed,ImageFilePath,	
				RoleCode,RoleDescription,LegacyKey,FiveStarXML,HasAward,ServiceLineAward,AddressXML,AwardXML,PDCPhoneXML,FacilityURL,FacilityType,FacilityTypeCode,FacilitySearchType,FiveStarProcedureCount,QualityScore
			)
		select a.ProviderToFacilityID,a.ProviderID, a.FacilityID,b.FacilityCode,ff.FacilityName,b.IsClosed, h.FacilityImagePath, c.RoleCode,c.RoleDescription,b.LegacyKey
			,(
				select svcCd,svcNm,specL
				from 
					(
					select y.ServiceLineID as svcCd, z.ServiceLineDescription as svcNm,
						(
							select LegacyKey as lKey, MedicalTermCode as spCd
							from #ServiceLineSpecialty z
							where z.ServiceLineCode = y.ServiceLineID
							order by MedicalTermCode
							for xml raw('spec'), elements, type
						) as specL
					from ERMART1.Facility.FacilityToServicelineRating y/*REFACTOR ONCE FACILITY DATA IS IN THE EDW... THIS IS USING LEGACY FOR NOW*/
					join ERMart1.Facility.ServiceLine z on (y.ServiceLineID = z.ServiceLineID)/*REFACTOR ONCE FACILITY DATA IS IN THE EDW... THIS IS USING LEGACY FOR NOW*/
					where y.IsMaxYear = 1
					and y.SurvivalStar = 5
					and y.FacilityID = b.LegacyKey		
					
					union all
					--THIS IS A PATCH FOR THE WAY MATERNITY CARE IS CONFIGURED IN THE LEGACY SYSTEM
					select q.ServiceLineID as svcCd, z.ServiceLineDescription as svcNm,
						(
							select LegacyKey as lKey, MedicalTermCode as spCd
							from #ServiceLineSpecialty z
							where z.ServiceLineCode = q.ServiceLineID
							order by MedicalTermCode
							for xml raw('spec'), elements, type
						) as specL
					from ERMART1.Facility.FacilityTOProcedureRating y/*REFACTOR ONCE FACILITY DATA IS IN THE EDW... THIS IS USING LEGACY FOR NOW*/
					join ERMART1.Facility.ProcedureToServiceLine q on (y.ProcedureID = q.ProcedureID)/*REFACTOR ONCE FACILITY DATA IS IN THE EDW... THIS IS USING LEGACY FOR NOW*/
					join ERMart1.Facility.ServiceLine z on (q.ServiceLineID = z.ServiceLineID)
					where y.IsMaxYear = 1
					and y.OverallSurvivalStar = 5
					and y.ProcedureID = 'OB1'
					and y.FacilityID = b.LegacyKey		
				)a	
				for xml raw('svcLn'), elements, type	
			) FiveStarXML
			,(
				select distinct case 
					when x.FacilityID is not NULL then 1 
				end 
				from ERMART1.Facility.FacilityToAward x/*REFACTOR ONCE FACILITY DATA IS IN THE EDW... THIS IS USING LEGACY FOR NOW*/
				where x.IsMaxYear = 1
				and x.FacilityID = b.LegacyKey
			) HasAward
			,(
				select q.SpecialtyCode as svcCd,			
					(
						select LegacyKey as lKey, MedicalTermCode as spCd
						from #ServiceLineSpecialty z
						where z.ServiceLineCode = q.SpecialtyCode
						order by MedicalTermCode
						for xml raw('spec'), elements, type
					) as specL
				from ERMART1.Facility.FacilityToAward q/*REFACTOR ONCE FACILITY DATA IS IN THE EDW... THIS IS USING LEGACY FOR NOW*/
				where q.IsMaxYear = 1
				and q.SpecialtyCode is not null
				and q.FacilityID = b.LegacyKey
				order by q.SpecialtyCode
				for xml raw('svcLn'), elements, type	
			) ServiceLineAward,
			
			(
				SELECT	DISTINCT u.Address as ad1,u.City as city, u.State as st, u.Zipcode as zip, CONVERT(DECIMAL(9,6),u.Latitude ) as lat, CONVERT(DECIMAL(9,6),u.Longitude ) as lng
				FROM	ERMART1.Facility.FacilityAddressDetail u
				WHERE	u.FacilityID = b.LegacyKey
				FOR XML RAW ('addr'), ELEMENTS , TYPE 
			) AS AddressXML,  
			(
				SELECT	y.AwardCode AS awCd, 
						w.AwardCategoryCode AS awTypCd,
						y.AwardDisplayName AS awNm, 
						x.Year AS awYr, 
						x.DisplayDataYear AS dispAwYr,
						x.MergedData AS mrgd, 
						x.IsBestInd AS isBest,
						x.IsMaxYear AS isMaxYr,
						(	
							SELECT	DISTINCT f.FacilityCode as facCd,
									p.ChildFacilityName as facNm
							FROM	#ParentChild p
									JOIN Base.Facility f ON p.FacilityIDChild = f.LegacyKey
							WHERE	p.FacilityIDParent = x.FacilityID
									AND (
											(z.RatingSourceID = 1 AND p.CurrentMerge = 0)
											OR	(z.RatingSourceID IS NULL AND p.CurrentMerge = 1)
											OR	(z.RatingSourceID = 0 AND p.CurrentMerge = 1)
										)
									AND p.FacilityIDChild IN (	
																SELECT	w.FacilityID 
																FROM	ERMART1.Facility.FacilityToAward w
																WHERE	w.AwardName = x.AwardName
																		AND ISNULL(w.SpecialtyCode,'') = ISNULL(x.SpecialtyCode,'')
																		AND w.MergedData = 1
  															)
							ORDER	BY p.ChildFacilityName
							FOR XML RAW ('child'),ELEMENTS, ROOT('childL'),Type 
						)
				FROM	ERMART1.Facility.FacilityToAward x
						JOIN Base.Award y ON  x.AwardName = y.AwardName
						JOIN Base.AwardCategory w ON w.AwardCategoryID = y.AwardCategoryID
						LEFT JOIN ERMART1.Facility.ServiceLine z ON x.SpecialtyCode = z.ServiceLineID
				WHERE	x.FacilityID = b.LegacyKey
				GROUP	BY x.FacilityID,y.AwardCode,y.AwardDisplayName,x.DisplayDataYear,x.MergedData,x.IsBestInd,x.AwardID,
						x.SpecialtyCode,z.RatingSourceID,x.IsMaxYear,x.AwardName,w.AwardCategoryCode,x.Year
				FOR XML RAW  ('award'),ELEMENTS, Type
			) AS AwardXML,
			
			CASE
				WHEN (ISNULL(CAST(kk.ClientToProductID AS VARCHAR(50)),'') <> '') -- Facility Level Phone
				THEN	(
							SELECT	DISTINCT DesignatedProviderPhone AS ph, PhoneTypeCode as phTyp
							FROM	Base.vwuPDCFacilityDetail fa
							WHERE	fa.PhoneTypeCode = 'PTHFS' -- Hospital - Facility Specific
									AND ii.ClientProductToEntityID = fa.ClientProductToEntityID
							FOR XML RAW ('phone'), ELEMENTS, TYPE							
						)
				ELSE	
						(
							SELECT	DISTINCT cl.DesignatedProviderPhone AS ph, PhoneTypeCode as phTyp
							FROM	Base.vwuPDCClientDetail cl
							WHERE	cl.PhoneTypeCode = 'PTHOS' -- PDC Affiliated Hospital
									AND ii.ClientToProductID = cl.ClientToProductID
							FOR XML RAW ('phone'), ELEMENTS, TYPE						
						)
			END AS PDCPhoneXML,			
			ff.FacilityURL,
			ff.FacilityType,
			ff.FacilityTypeCode,
			ff.FacilitySearchType,
			ff.FiveStarProcedureCount,
			(AVG(ll.ratingsSortValue) + COUNT(ll.ServiceLineCode)*0.25) AS QualityScore

		from  #ProviderBatch as pb  --When not migrating a batch, this is all providers in Base.Provider. Otherwise it is just the providers in the batch
		JOIN Base.ProviderToFacility as a with (nolock) on a.ProviderID = pb.ProviderID
		JOIN Base.Facility as b with (nolock) on a.FacilityID = b.FacilityID
		JOIN ERMART1.Facility.FacilityAddressDetail e with (nolock) on b.LegacyKey = e.FacilityID
		JOIN Mid.Facility ff with (nolock) ON b.FacilityID = ff.FacilityID
		left join Base.ProviderRole as c with (nolock) on a.ProviderRoleID = c.ProviderRoleID
		
		LEFT JOIN
				(
					SELECT	d.FacilityID, d.FacilityImageID, 
							ISNULL(e.MediaRelativePath,'') + CASE WHEN RIGHT(ISNULL(e.MediaRelativePath,''),1) <> '/' then '/' else '' end + d.FileName as FacilityImagePath, 
							e.MediaImageTypeCode 
					FROM	Base.FacilityImage d
							JOIN Base.MediaImageType e on e.MediaImageTypeID = d.MediaImageTypeID
							JOIN Base.MediaSize f on (d.MediaSizeID = f.MediaSizeID)
					WHERE	MediaImageTypeCode = 'FACIMAGE'
				
				) h ON h.FacilityID = b.FacilityID		
		
		LEFT JOIN
				(
					SELECT  d.ClientProductToEntityID,a.ClientToProductID,b.ClientCode,b.ClientName,f.FacilityID,c.ProductCode,pg.ProductGroupCode
					FROM	Base.ClientToProduct a
							JOIN Base.Client b ON a.ClientID = b.ClientID
							JOIN Base.Product c ON a.ProductID = c.ProductID
							JOIN Base.ProductGroup pg ON c.ProductGroupID = pg.ProductGroupID
							JOIN Base.ClientProductToEntity d ON a.ClientToProductID = d.ClientToProductID
							JOIN Base.EntityType e ON d.EntityTypeID = e.EntityTypeID AND e.EntityTypeCode = 'FAC'
							JOIN Base.Facility f ON d.EntityID = f.FacilityID
					WHERE	a.ActiveFlag = 1
							AND ProductGroupCode = 'PDC'
							AND f.IsClosed = 0
				) ii ON ii.FacilityID = b.FacilityID
		LEFT JOIN 
					(
						SELECT	a.EntityID AS ClientToProductID, d.ClientFeatureCode AS feCd, 
								d.ClientFeatureDescription AS feDes, e.ClientFeatureValueCode, e.ClientFeatureValueDescription
						FROM	Base.ClientEntityToClientFeature a
								JOIN Base.EntityType b ON a.EntityTypeID = b.EntityTypeID 
								JOIN Base.ClientFeatureToClientFeatureValue c ON a.ClientFeatureToClientFeatureValueID = c.ClientFeatureToClientFeatureValueID
								JOIN Base.ClientFeature d ON c.ClientFeatureID = d.ClientFeatureID
								JOIN Base.ClientFeatureValue e ON e.ClientFeatureValueID = c.ClientFeatureValueID
						WHERE	b.EntityTypeCode = 'CLPROD'
								AND d.ClientFeatureCode = 'FCCCP' -- Call Center Phone Numbers
								AND e.ClientFeatureValueCode = 'FVFAC' -- Facility
					) kk ON ii.ClientToProductID = kk.ClientToProductID	
		LEFT JOIN 
					(
						SELECT b.ProviderID, a.FacilityID, a.ServiceLineCode, a.ratingsSortValue
						FROM	#TempQualityScoreTable a 
								JOIN #tempProviderSpecialtyServiceLine b ON a.ServiceLineCode = b.ServiceLineCode 
								JOIN
									(
										select ProviderID, b.LegacyKey
										from Base.ProviderToFacility a
										join Base.Facility b on (a.FacilityID = b.FacilityID)
									)c on (a.FacilityID = c.LegacyKey and b.ProviderID = c.ProviderID)
						WHERE	ISNULL(a.ratingsSortValue,-1) <> -1 				
					) ll ON ll.FacilityID = b.LegacyKey	AND ll.ProviderID = a.ProviderID	
		
		GROUP BY a.ProviderToFacilityID,a.ProviderID,a.FacilityID,b.FacilityCode,ff.FacilityName,
		b.IsClosed,h.FacilityImagePath,c.RoleCode,c.RoleDescription,b.LegacyKey,ff.FacilityURL,ff.FacilityType,ff.FacilityTypeCode,ff.FacilitySearchType,
		ff.FiveStarProcedureCount,ii.ClientProductToEntityID,kk.ClientToProductID,ii.ClientToProductID

		create index temp on #ProviderFacility (ProviderToFacilityID)


	/*
		Flag record level actions for ActionCode
			0 = No Change
			1 = Insert
			2 = Update
	*/
		--ActionCode Insert
			update a
			set a.ActionCode = 1
			--select *
			from #ProviderFacility a
			left join Mid.ProviderFacility b on (a.ProviderToFacilityID = b.ProviderToFacilityID)
			where b.ProviderToFacilityID is null
		
		--ActionCode Update
			begin try drop table #ColumnsUpdates end try begin catch end catch
			
			select name, identity(int,1,1) as recId
			into #ColumnsUpdates
			from tempdb..syscolumns 
			where id = object_id('TempDB..#ProviderFacility')
			and name not in ('ProviderToFacilityID'/*PK*/, 'ActionCode')
				
			--build the sql statement with dynamic sql to check if we need to update any columns
				declare @sql varchar(8000)
				declare @min int
				declare @max int
				declare @whereClause varchar(8000)
				declare @column varchar(100)
				declare @newline char(1)
				declare @globalCheck varchar(3)

				set @min = 1
				set @whereClause = ''
				set @newline = char(10)
				set @sql = 'update a'+@newline+ 
						   'set a.ActionCode = 2'+@newline+
						   '--select *'+@newline+
						   'from #ProviderFacility a'+@newline+
						   'join Mid.ProviderFacility b with (nolock) on (a.ProviderToFacilityID = b.ProviderToFacilityID)'+@newline+
						   'where '
						   
				select @max = MAX(recId) from #ColumnsUpdates

				while @min <= @max	
					begin
						select @column = name from #ColumnsUpdates where recId = @min 
						set @whereClause = @whereClause +'BINARY_CHECKSUM(isnull(cast(a.'+@column+' as varchar(max)),'''')) <> BINARY_CHECKSUM(isnull(cast(b.'+@column+' as varchar(max)),''''))'+@newline
							--put an OR for all except for the last column check
							if @min < @max 
								begin
									set @whereClause = @whereClause+' or '
								end

						
						set @min = @min + 1
					end

				set @sql = @sql + @whereClause
				exec (@sql)

	/*
		Complete the ActionCode
	*/
	
		--define column set for INSERTS 
		begin try drop table #ColumnInserts end try begin catch end catch

		select name, identity(int,1,1) as recId
		into #ColumnInserts
		from tempdb..syscolumns 
		where id = object_id('TempDB..#ProviderFacility')
		and name <> 'ActionCode'--do not need to insert/update this field
		
		--create the column set
		declare @columnInsert varchar(100)
		declare @columnListInsert varchar(8000)
		declare @minInsert int
		declare @maxInsert int
		
		set @minInsert = 1
		set @columnListInsert = ''
		select @maxInsert = MAX(recId) from #ColumnInserts 
		
		while @minInsert <= @maxInsert
			begin
				select @columnInsert = name from #ColumnInserts where recId = @minInsert
				set @columnListInsert = @columnListInsert + @columnInsert
				
				if @minInsert <@maxInsert
					begin
						set @columnListInsert = @columnListInsert+','
					end
				
				set @minInsert = @minInsert + 1
			end
		
		--ActionCode = 1 (Inserts)
			declare @sqlInsert varchar(8000)
			set @sqlInsert = 
			'insert into Mid.ProviderFacility ('+@columnListInsert+')
			select '+@columnListInsert+' from #ProviderFacility where ActionCode = 1'
			
			exec (@sqlInsert)
		
		--ActionCode = 2 (Updates)	
			declare @minUpdates int
			declare @maxUpdates int
			declare @sqlUpdates varchar(8000)
			declare @sqlUpdatesClause varchar(500)
			declare @columnUpdates varchar(150)
			declare @columnListUpdates varchar(8000)
			declare @newlineUpdates char(1)
			
			set @newlineUpdates = char(10)
			set @columnListUpdates = ''
			set @sqlUpdates = 'update a'+@newlineUpdates+
							  'set '	
			set @sqlUpdatesClause = '--select *'+@newlineUpdates+
							  'from Mid.ProviderFacility a with (nolock)'+@newlineUpdates+
							  'join #ProviderFacility b on (a.ProviderToFacilityID = b.ProviderToFacilityID)'+@newlineUpdates+
							  'where b.ActionCode = 2'
							  
			select @minUpdates = MIN(recId) from #ColumnsUpdates 
			select @maxUpdates = MAX(recId) from #ColumnsUpdates
			
			while @minUpdates <= @maxUpdates
				begin
					select @columnUpdates = name from #ColumnsUpdates where recId = @minUpdates
					set @columnListUpdates = @columnListUpdates + 'a.'+@columnUpdates+' = b.'+@columnUpdates
					
					if @minUpdates < @maxUpdates
						begin
							set @columnListUpdates = @columnListUpdates+','+@newlineUpdates+''
						end
					else
						begin
							set @columnListUpdates = @columnListUpdates+@newlineUpdates+@sqlUpdatesClause
						end
					
					set @minUpdates = @minUpdates + 1
				end
			
			set @sqlUpdates = @sqlUpdates + @columnListUpdates
			
			exec (@sqlUpdates)

		--ActionCode = N (Deletes)
			delete a
			--select *
			from Mid.ProviderFacility a with (nolock)
			inner join #ProviderBatch as pb on pb.ProviderID = a.ProviderID
			left join #ProviderFacility b on (a.ProviderToFacilityID = b.ProviderToFacilityID)
			where b.ProviderToFacilityID is null
	
	/*Marionjoy Rehab (MJR) HG0675*/
	DELETE ODS1Stage.Mid.ProviderFacility WHERE FacilityId = (select DISTINCT facilityid from ods1STAGE.mid.ProviderFacility_MJR )
	insert into ODS1Stage.Mid.ProviderFacility(ProviderToFacilityID, ProviderID, FacilityID, FacilityCode, FacilityName, IsClosed, ImageFilePath, RoleCode, RoleDescription, LegacyKey, FiveStarXML, HasAward, ServiceLineAward, AddressXML, AwardXML, PDCPhoneXML, FacilityURL, FacilityType, FacilityTypeCode, FacilitySearchType, FiveStarProcedureCount, QualityScore)
	select NEWID() AS ProviderToFacilityID, P.ProviderID, F.FacilityID, F.FacilityCode, F.FacilityName, F.IsClosed, F.ImageFilePath, F.RoleCode, F.RoleDescription, F.LegacyKey, F.FiveStarXML, F.HasAward, F.ServiceLineAward, F.AddressXML, F.AwardXML, F.PDCPhoneXML, F.FacilityURL, F.FacilityType, F.FacilityTypeCode, F.FacilitySearchType, F.FiveStarProcedureCount, F.QualityScore
	from mid.ProviderSponsorship PS
	INNER JOIN ODS1STAGE.BASE.PROVIDER P ON P.ProviderCode = PS.ProviderCode
	CROSS APPLY(SELECT TOP 1 FacilityID, FacilityCode, FacilityName, IsClosed, ImageFilePath, RoleCode, RoleDescription, LegacyKey, FiveStarXML, HasAward, ServiceLineAward, AddressXML, AwardXML, PDCPhoneXML, FacilityURL, FacilityType, FacilityTypeCode, FacilitySearchType, FiveStarProcedureCount, QualityScore FROM ods1STAGE.mid.ProviderFacility_MJR)F
	where PS.facilitycode = 'HG0675'	
	
	;WITH cte_DeleteDups AS (
		SELECT *, ROW_NUMBER()OVER(PARTITION BY ProviderId, FacilityId ORDER BY ProviderToFacilityId) AS RN1 FROM ODS1Stage.Mid.ProviderFacility
	)
	DELETE cte_DeleteDups WHERE RN1 > 1