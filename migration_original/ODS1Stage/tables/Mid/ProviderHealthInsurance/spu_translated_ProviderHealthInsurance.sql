CREATE OR REPLACE PROCEDURE ODS1_STAGE.MID.SP_LOAD_PROVIDERHEALTHINSURANCE(IsProviderDeltaProcessing BOOLEAN) -- Parameters
    RETURNS STRING
    LANGUAGE SQL
    EXECUTE AS CALLER
    AS  
DECLARE 
---------------------------------------------------------
--------------- 0. Table dependencies -------------------
---------------------------------------------------------
    
-- Mid.ProviderHealthInsurance depends on: 
--- Raw.ProviderDeltaProcessing
--- Base.Provider
--- Base.ProviderToHealthInsurance
--- Base.HealthInsurancePlanToPlanType
--- Base.HealthInsurancePlan
--- Base.HealthInsurancePayor
--- Base.HealthInsurancePlanType

---------------------------------------------------------
--------------- 1. Declaring variables ------------------
---------------------------------------------------------

    truncate_statement STRING;
    select_statement STRING; -- CTE and Select statement for the Merge
    update_statement STRING; -- Update statement for the Merge
    update_condition STRING;
    insert_statement STRING; -- Insert statement for the Merge
    merge_statement STRING; -- Merge statement to final table
    status STRING; -- Status monitoring
   
---------------------------------------------------------
--------------- 2.Conditionals if any -------------------
---------------------------------------------------------   
   
BEGIN
    IF (IsProviderDeltaProcessing) THEN
           select_statement := '
           WITH CTE_ProviderBatch AS (
            SELECT
                pdp.ProviderID
            FROM
                Raw.ProviderDeltaProcessing as pdp
        ),';
    ELSE
           truncate_statement := 'TRUNCATE TABLE Show.ProviderHealthInsurance';
           EXECUTE IMMEDIATE truncate_statement;
           select_statement := ' WITH CTE_ProviderBatch AS (
                                    SELECT
                                        p.ProviderID
                                    FROM
                                        Base.Provider as p
                                    ORDER BY
                                        p.ProviderID
                                ),';
    END IF;


---------------------------------------------------------
----------------- 3. SQL Statements ---------------------
---------------------------------------------------------     

--- Select Statement

select_statement := select_statement || 
                    $$ CTE_PayorProductCount AS (
                            SELECT
                            hipay.PayorCode,
                            COUNT(*) AS PayorProductCount
                            FROM
                                Base.HealthInsurancePlanToPlanType AS hipt
                                JOIN Base.HealthInsurancePlan AS hip ON hipt.HealthInsurancePlanID = hip.HealthInsurancePlanID
                                JOIN Base.HealthInsurancePayor AS hipay ON hip.HealthInsurancePayorID = hipay.HealthInsurancePayorID
                            WHERE
                                hipay.PayorName != hipt.ProductName
                            GROUP BY
                                hipay.PayorCode
                        )
                        SELECT
                            DISTINCT pthi.ProviderToHealthInsuranceID,
                            pthi.ProviderID,
                            hipt.HealthInsurancePlanToPlanTypeID,
                            hipt.ProductName,
                            hip.PlanName,
                            hip.PlanDisplayName,
                            hipay.PayorName,
                            hiptd.PlanTypeDescription,
                            hiptd.PlanTypeDisplayDescription,
                            CASE
                                WHEN hipay.PayorName IN (
                                    'Name of Insurance Unknown',
                                    'Accepts most insurance',
                                    'Accepts most major Health Plans. Please contact our office for details.'
                                ) THEN 0
                                ELSE 1
                            END AS Searchable,
                            hipay.PayorCode,
                            hipay.HealthInsurancePayorID,
                            pc.PayorProductCount
                        FROM
                            CTE_ProviderBatch as pb
                            JOIN Base.ProviderToHealthInsurance AS pthi ON pthi.ProviderID = pb.ProviderID
                            JOIN Base.HealthInsurancePlanToPlanType AS hipt ON pthi.HealthInsurancePlanToPlanTypeID = hipt.HealthInsurancePlanToPlanTypeID
                            JOIN Base.HealthInsurancePlan AS hip ON hipt.HealthInsurancePlanID = hip.HealthInsurancePlanID
                            JOIN Base.HealthInsurancePayor AS hipay ON hip.HealthInsurancePayorID = hipay.HealthInsurancePayorID
                            JOIN Base.HealthInsurancePlanType AS hiptd ON hipt.HealthInsurancePlanTypeID = hiptd.HealthInsurancePlanTypeID
                            JOIN CTE_PayorProductCount as pc ON pc.PayorCode = hipay.PayorCode
                    $$;

--- Update Statement
update_statement := ' UPDATE
                        SET
                            target.HealthInsurancePayorID = source.HealthInsurancePayorID,
                            target.HealthInsurancePlanToPlanTypeID = source.HealthInsurancePlanToPlanTypeID,
                            target.PayorCode = source.PayorCode,
                            target.PayorName = source.PayorName,
                            target.PlanDisplayName = source.PlanDisplayName,
                            target.PlanName = source.PlanName,
                            target.PlanTypeDescription = source.PlanTypeDescription,
                            target.PlanTypeDisplayDescription = source.PlanTypeDisplayDescription,
                            target.ProductName = source.ProductName,
                            target.ProviderID = source.ProviderID,
                            target.Searchable = source.Searchable';

--- Update Condition
update_condition := 'target.HealthInsurancePayorID != source.HealthInsurancePayorID
        OR target.HealthInsurancePlanToPlanTypeID != source.HealthInsurancePlanToPlanTypeID
        OR target.PayorCode != source.PayorCode
        OR target.PayorName != source.PayorName
        OR target.PlanDisplayName != source.PlanDisplayName
        OR target.PlanName != source.PlanName
        OR target.PlanTypeDescription != source.PlanTypeDescription
        OR target.PlanTypeDisplayDescription != source.PlanTypeDisplayDescription
        OR target.ProductName != source.ProductName
        OR target.ProviderID != source.ProviderID
        OR target.Searchable != source.Searchable';

--- Insert Statement
insert_statement := ' INSERT
                        (   HealthInsurancePayorID,
                            HealthInsurancePlanToPlanTypeID,
                            PayorCode,
                            PayorName,
                            PayorProductCount,
                            PlanDisplayName,
                            PlanName,
                            PlanTypeDescription,
                            PlanTypeDisplayDescription,
                            ProductName,
                            ProviderID,
                            ProviderToHealthInsuranceID,
                            Searchable
                        )
                    VALUES
                        (
                            source.HealthInsurancePayorID,
                            source.HealthInsurancePlanToPlanTypeID,
                            source.PayorCode,
                            source.PayorName,
                            source.PayorProductCount,
                            source.PlanDisplayName,
                            source.PlanName,
                            source.PlanTypeDescription,
                            source.PlanTypeDisplayDescription,
                            source.ProductName,
                            source.ProviderID,
                            source.ProviderToHealthInsuranceID,
                            source.Searchable
                        );';

---------------------------------------------------------
--------- 4. Actions (Inserts and Updates) --------------
---------------------------------------------------------  


merge_statement := ' MERGE INTO Show.ProviderHealthInsurance as target USING 
                   ('||select_statement||') as source 
                   ON target.ProviderToHealthInsuranceID = source.ProviderToHealthInsuranceID
                   WHEN MATCHED AND (' || update_condition || ') THEN '||update_statement|| '
                   WHEN NOT MATCHED THEN '||insert_statement;
                   
---------------------------------------------------------
------------------- 5. Execution ------------------------
--------------------------------------------------------- 
                    
EXECUTE IMMEDIATE merge_statement ;

---------------------------------------------------------
--------------- 6. Status monitoring --------------------
--------------------------------------------------------- 

status := 'Completed successfully';
    RETURN status;


        
EXCEPTION
    WHEN OTHER THEN
          status := 'Failed during execution. ' || 'SQL Error: ' || SQLERRM || ' Error code: ' || SQLCODE || '. SQL State: ' || SQLSTATE;
          RETURN status;


    
END;