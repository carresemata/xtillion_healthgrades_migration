CREATE OR REPLACE FUNCTION ODS1_STAGE.UTILS.FNUREMOVESPECIALHEXADECIMALCHARACTERS("VALUE" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS 

select replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( replace( 
		value, '\\x00','') ,'\\x01','') ,'\\x02','') ,'\\x03','') ,'\\x04','') ,'\\x05','') ,'\\x06','') ,'\\x07','') ,'\\x08','') ,'\\x0b','') ,'\\x0c','') ,'\\x0e','') ,'\\x0f','') ,'\\x10','') ,'\\x11','') ,'\\x12','') ,'\\x13','') ,'\\x14','') ,'\\x15','') ,'\\x16','') ,'\\x17','') ,'\\x18','') ,'\\x19','') ,'\\x1a','') ,'\\x1b','') ,'\\x1c','') ,'\\x1d','') ,'\\x1e','') ,'\\x1f','')
;