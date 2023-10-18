/***************************** SQL SERVER Get All Columns *****************************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Get all columns from all tables from all databases
Usage:            Update DATABASE_NAME.SCHEMA_NAME.TABLE_NAME for the destination table of this data
 */


ALTER PROCEDURE [dbo].[MANAGE_COLUMN_INFO]

AS
-- START PROCEDURE
BEGIN
    -- Drop table if exist
    IF OBJECT_ID ('SCHEMA_NAME.TABLE_NAME', 'U') IS NOT NULL
    DROP TABLE SCHEMA_NAME.TABLE_NAME;

DECLARE @AllTables
TABLE (
    SERVER_NAME NVARCHAR(200),
    DATABASE_NAME NVARCHAR(200),
    SCHEMA_NAME NVARCHAR(200),
    TABLE_NAME NVARCHAR(200),
    TABLE_TYPE NVARCHAR(200),
    TABLE_ID NVARCHAR(200),
    COLUMN_NAME NVARCHAR(200),
    COLUMN_ID INT,
    COLUMN_UID NVARCHAR(200),
    COLUMN_TYPE NVARCHAR(200)
) DECLARE @SQL NVARCHAR(4000)
SET
    @SQL='
            SELECT  
            @@SERVERNAME,
            ''?'',
            s.name AS SCHEMA_NAME,
            o.name AS TABLE_NAME,
            CASE 
                WHEN o.type = ''V'' THEN ''View Table''
                ELSE ''Managed Table''
            END AS [TABLE_TYPE],
            ''?'' + ''_'' + CONVERT(varchar(10),o.object_id) AS TABLE_ID, 
            c.name AS COLUMN_NAME,
            c.column_id AS COLUMN_ID,
            ''?'' + ''_'' + CONVERT(varchar(10),o.object_id) +''_''+ CONVERT(varchar(10),c.column_id) AS COLUMN_UID,
            ty.name AS COLUMN_TYPE

            FROM [?].sys.columns AS c
            LEFT JOIN [?].sys.all_objects AS o ON c.object_id = o.object_id
            LEFT JOIN [?].sys.schemas s ON s.schema_id= o.schema_id
            LEFT JOIN [?].sys.types AS ty ON c.user_type_id = ty.user_type_id
            WHERE o.type IN (''V'',''U'')
            AND ''?'' NOT IN (''master'',''model'',''msdb'',''tempdb'',''SSISDB'')
           '
    --PRINT(@SQL)
INSERT INTO
    @AllTables (
        SERVER_NAME,
        DATABASE_NAME,
        SCHEMA_NAME,
        TABLE_NAME,
        TABLE_TYPE,
        TABLE_ID,
        COLUMN_NAME,
        COLUMN_ID,
        COLUMN_UID,
        COLUMN_TYPE
    ) EXEC sp_MSforeachdb @SQL;

-- Insert data to table
SELECT
    * 
INTO DATABASE_NAME.SCHEMA_NAME.TABLE_NAME
FROM
    @AllTables
ORDER BY
    1,
    2,
    3,
    4

-- END PROCEDURE
END