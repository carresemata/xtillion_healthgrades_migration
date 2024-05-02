CREATE OR REPLACE FUNCTION ODS1_STAGE.UTILS.FNUREMOVESPECIALHEXADECIMALCHARACTERS("VALUE" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS '
	SELECT REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( 
		value, ''\\x00'','''') ,''\\x01'','''') ,''\\x02'','''') ,''\\x03'','''') ,''\\x04'','''') ,''\\x05'','''') ,''\\x06'','''') ,''\\x07'','''') ,''\\x08'','''') ,''\\x0B'','''') ,''\\x0C'','''') ,''\\x0E'','''') ,''\\x0F'','''') ,''\\x10'','''') ,''\\x11'','''') ,''\\x12'','''') ,''\\x13'','''') ,''\\x14'','''') ,''\\x15'','''') ,''\\x16'','''') ,''\\x17'','''') ,''\\x18'','''') ,''\\x19'','''') ,''\\x1A'','''') ,''\\x1B'','''') ,''\\x1C'','''') ,''\\x1D'','''') ,''\\x1E'','''') ,''\\x1F'','''')
';