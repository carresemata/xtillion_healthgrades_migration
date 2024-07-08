CREATE OR REPLACE FUNCTION ODS1_STAGE_TEAM.UTILS.generate_uuid(name VARCHAR(16777216) DEFAULT NULL)
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS
$$
CASE
    WHEN name IS NOT NULL THEN
        -- Snowflake provides this function for v5 UUID generation. The resulting ids are deterministic and depend on the two arguments: namespace (a uuid string) and name (any string)
        -- Passing the same arguments will always return the same UUID
        UUID_STRING('fe971b24-9572-4005-b22f-351e9c09274e', name)
    ELSE
        -- Snowflake provides this function for v4 UUID generation. No arguments are passed and the resulting ids are random
        UUID_STRING()
END
$$
;