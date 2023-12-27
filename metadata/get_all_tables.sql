/*************************** SQL SERVER Get All Tables ***************************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Get all tables from all databases in a server
Usage:            Update DATABASE_NAME.SCHEMA_NAME.TABLE_NAME for the destination table of this data
 */

ALTER PROCEDURE [dbo].[MANAGE_TABLE_INFO]

AS
-- START PROCEDURE
BEGIN

SET NOCOUNT OFF

IF OBJECT_ID('SCHEMA_NAME.TABLE_NAME', 'U') IS NOT NULL
DROP TABLE SCHEMA_NAME.TABLE_NAME;

DECLARE @AllTables
TABLE (
    SERVER_NAME NVARCHAR(200),
    DATABASE_NAME NVARCHAR(200),
    SCHEMA_NAME NVARCHAR(200),
    TABLE_NAME NVARCHAR(200),
    TABLE_ID NVARCHAR(200),
    TABLE_TYPE NVARCHAR(200),
    CREATE_DATE DATETIME2,
    MODIFY_DATE DATETIME2
) DECLARE @SQL NVARCHAR(4000)
SET
    @SQL='
            SELECT  
            @@SERVERNAME,
            ''?'',
            S.NAME AS [SCHEMA_NAME],
            A.TABLE_NAME,
            ''?'' + ''_'' + CONVERT(varchar(10),A.TABLE_ID) AS TABLE_ID,
            A.TABLE_TYPE,
            A.CREATE_DATE,
            A.MODIFY_DATE
        FROM
            (
                SELECT
                    T.name AS TABLE_NAME,
                    t.object_id AS TABLE_ID,
                    t.schema_id,
                    T.create_date AS CREATE_DATE,
                    T.modify_date AS MODIFY_DATE,
                    ''Managed Table'' AS TABLE_TYPE
                FROM
                    [?].sys.tables AS T
                UNION
                SELECT
                    V.name AS TABLE_NAME,
                    V.object_id AS TABLE_ID,
                    V.schema_id,
                    V.create_date AS CREATE_DATE,
                    V.modify_date AS MODIFY_DATE,
                    ''View Table'' AS TABLE_TYPE
                FROM
                    [?].sys.views V
            ) A
            LEFT JOIN [?].sys.schemas S ON S.schema_id=A.schema_id
            WHERE ''?'' NOT IN (''master'',''model'',''msdb'',''tempdb'',''SSISDB'')
           '

INSERT INTO
    @AllTables (
        SERVER_NAME,
        DATABASE_NAME,
        SCHEMA_NAME,
        TABLE_NAME,
        TABLE_ID,
        TABLE_TYPE,
        CREATE_DATE,
        MODIFY_DATE
    )
    
EXEC sp_MSforeachdb @SQL;

SELECT
    *
INTO
    DATABASE_NAME.SCHEMA_NAME.TABLE_NAME
FROM
    @AllTables
ORDER BY
    1,
    2,
    3,
    4

-- END PROCEDURE
END