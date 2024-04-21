	INSERT INTO ODS1Stage.Base.ClientFeatureToClientFeatureValue(ClientFeatureToClientFeatureValueId, ClientFeatureId, ClientFeatureValueId, SourceCode, LastUpdateDate)
	SELECT	X.*
	FROM(
		SELECT		DISTINCT 
					convert(uniqueidentifier, hashbytes('SHA1',  concat(T.ClientFeatureCode,T.ClientFeatureValueCode))) as ClientFeatureToClientFeatureValueID
					,ClientFeatureId
					,ClientFeatureValueId
					,'Reltio' as SourceCode, getutcdate() as LastUpdateDate
		FROM		#tmp_Features T
		INNER JOIN	ODS1Stage.Base.ClientFeature CF
					ON CF.ClientFeatureCode = T.ClientFeatureCode
		INNER JOIN	ODS1Stage.Base.ClientFeatureValue CFV
					ON CFV.ClientFeatureValueCode = T.ClientFeatureValueCode
	)X
	LEFT JOIN	ODS1Stage.Base.ClientFeatureToClientFeatureValue T
				ON T.ClientFeatureToClientFeatureValueId = X.ClientFeatureToClientFeatureValueId
	WHERE		T.ClientFeatureToClientFeatureValueId IS NULL