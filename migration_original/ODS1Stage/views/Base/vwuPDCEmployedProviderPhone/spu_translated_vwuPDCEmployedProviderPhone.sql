CREATE OR REPLACE VIEW ODS1_STAGE.BASE.VWUPDCEMPLOYEDPROVIDERPHONE
AS
SELECT
  cpte.ClientToProductID,
  vw_cpetp.ClientProductToEntityID,
  vw_cpetp.PhoneNumber AS EmployedProviderPhone,
  vw_cpetp.PhoneTypeCode
FROM
  Base.ClientProductToEntity AS cpte
  INNER JOIN Base.vwuClientProductEntityToPhone AS vw_cpetp ON cpte.ClientProductToEntityID = vw_cpetp.ClientProductToEntityID
  INNER JOIN Base.ClientToProduct AS cp ON cpte.ClientToProductID = cp.ClientToProductID
WHERE
  vw_cpetp.PhoneTypeCode IN ('PTEMP', 'PTEMPM', 'PTEMPDTP', 'PTEMPT')
  AND cp.ActiveFlag = 1;