CREATE OR REPLACE FUNCTION ODS1_STAGE_TEAM.UTILS.generate_uuid(name VARCHAR(16777216) DEFAULT NULL)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS
$$
CASE
    WHEN name IS NOT NULL THEN
        UUID_STRING('fe971b24-9572-4005-b22f-351e9c09274e', name)
    ELSE
        UUID_STRING()
END
$$
;