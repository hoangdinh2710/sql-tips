/*************************** SQL SERVER Get All Tables Size ***************************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Get all tables size from all databases in a server
Usage:            DEST_DATABASE_NAME.DEST_SCHEMA_NAME.DEST_TABLE_NAME for the destination table of this data
 */

ALTER PROCEDURE [dbo].[MANAGE_TABLE_SIZE]

AS
-- START PROCEDURE
BEGIN

SET NOCOUNT OFF

IF OBJECT_ID('SCHEMA_NAME.TABLE_NAME', 'U') IS NOT NULL
DROP TABLE SCHEMA_NAME.TABLE_NAME;

DECLARE @AllTables
TABLE (
    DATABASE_NAME NVARCHAR(200),
    SCHEMA_NAME NVARCHAR(200),
    TABLE_NAME NVARCHAR(200),
    TOTAL_COLUMNS INT,
    TOTAL_ROWS INT,
    TOTAL_SPACE_MB INT,
    USED_SPACE_MB INT,
    UNUSED_SPACE_MB INT
) DECLARE @SQL NVARCHAR(4000)
SET
    @SQL='
    IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''ssisdb'') 
    BEGIN 

    SELECT 
        ''?'' AS DATABASE_NAME,
        s.name AS SCHEMA_NAME,
        t.name AS TABLE_NAME,
        t.max_column_id_used AS TOTAL_COLUMNS,
        p.rows AS TOTAL_ROWS,
        CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 0) AS INT) AS TOTAL_SPACE_MB,
        CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 0) AS INT) AS USED_SPACE_MB, 
        CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 0) AS INT) AS UNUSED_SPACE_MB
    FROM 
        sys.tables t
    INNER JOIN      
        sys.indexes i ON t.object_id = i.object_id
    INNER JOIN 
        sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN 
        sys.allocation_units a ON p.partition_id = a.container_id
    LEFT OUTER JOIN 
        sys.schemas s ON t.schema_id = s.schema_id
    GROUP BY 
        t.name, s.name, p.rows
    END
           '

INSERT INTO
    @AllTables (
        DATABASE_NAME,
        SCHEMA_NAME,
        TABLE_NAME,
        TOTAL_COLUMNS,
        TOTAL_ROWS,
        TOTAL_SPACE_MB,
        USED_SPACE_MB,
        UNUSED_SPACE_MB
    )
    
EXEC sp_MSforeachdb @SQL;

SELECT
    *
INTO
    DEST_DATABASE_NAME.DEST_SCHEMA_NAME.DEST_TABLE_NAME
FROM
    @AllTables
ORDER BY
    1,
    2,
    3,
    4

-- END PROCEDURE
END