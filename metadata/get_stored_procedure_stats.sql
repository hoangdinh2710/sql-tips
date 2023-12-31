/***************************** Stored Procedure Stats *************************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Get store procedure status for all database in a server
Usage:            Update DATABASE_NAME.SCHEMA_NAME.TABLE_NAME for the destination table of this data
*/

CREATE PROCEDURE dbo.MANAGE_STORE_PROCEDURE_STATS 

AS BEGIN
-- START PROCEDURE

SET
NOCOUNT ON DECLARE @AllTables
TABLE (
    DATABASE_NAME NVARCHAR(200),
    UNIQUE_ID NVARCHAR(200),
    PROC_NAME NVARCHAR(200),
    PROC_ID NVARCHAR(200),
    PROC_CREATE_DATE DATETIME2,
    PROC_MODIFY_DATE DATETIME2,
    PROC_TYPE NVARCHAR(200),
    CACHED_TIME DATETIME2,
    TOTAL_ELAPSED_TIME_SECONDS INT,
    TOTAL_WORKER_TIME_SECONDS INT,
    TOTAL_LOGICAL_READS INT,
    TOTAL_LOGICAL_WRITES INT,
    TOTAL_PHYSICAL_READS INT,
    TOTAL_SPILLS INT
) DECLARE @SQL NVARCHAR(4000)
SET
    @SQL='
    
    IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''ssisdb'',''ctl_awdb'',''lvlt_hds'') 
    BEGIN 
    USE ? 

    SELECT
    ''?'' AS DATABASE_NAME,
    CONCAT(''?'',''_'',P.object_id,''_'',CAST(PS.cached_time AS INT))  AS UNIQUE_ID, 
    P.name AS [PROC_NAME],
    P.object_id AS [PROC_ID],
    P.create_date AS [PROC_CREATE_DATE],
    P.modify_date AS [PROC_MODIFY_DATE],
    PS.type AS [PROC_TYPE],
    PS.CACHED_TIME,
    PS.total_elapsed_time/1000000 AS TOTAL_ELAPSED_TIME_SECONDS,
    PS.total_worker_time /1000000 AS TOTAL_WORKER_TIME_SECONDS,
    PS.TOTAL_LOGICAL_READS,
    PS.TOTAL_LOGICAL_WRITES,
    PS.TOTAL_PHYSICAL_READS,
    PS.TOTAL_SPILLS
FROM
    sys.procedures AS P
LEFT JOIN sys.dm_exec_procedure_stats AS PS ON P.object_id = PS.object_id
WHERE PS.CACHED_TIME IS NOT NULL

    END
    '
INSERT INTO
    @AllTables (
        DATABASE_NAME,
        UNIQUE_ID,
        PROC_NAME,
        PROC_ID,
        PROC_CREATE_DATE,
        PROC_MODIFY_DATE,
        PROC_TYPE,
        CACHED_TIME,
        TOTAL_ELAPSED_TIME_SECONDS,
        TOTAL_WORKER_TIME_SECONDS,
        TOTAL_LOGICAL_READS,
        TOTAL_LOGICAL_WRITES,
        TOTAL_PHYSICAL_READS,
        TOTAL_SPILLS
    ) EXEC sp_MSforeachdb @SQL;

SET
NOCOUNT OFF

-- Merge data into main table (to avoid duplicate data)
MERGE DATABASE_NAME.SCHEMA_NAME.TABLE_NAME AS T
USING @AllTables AS S
ON T.UNIQUE_ID = S.UNIQUE_ID AND T.DATABASE_NAME = S.DATABASE_NAME
WHEN MATCHED THEN
    UPDATE SET
    T.DATABASE_NAME = S.DATABASE_NAME, 
    T.UNIQUE_ID = S.UNIQUE_ID, 
    T.PROC_NAME = S.PROC_NAME,
    T.PROC_ID = S.PROC_ID,
    T.PROC_CREATE_DATE = S.PROC_CREATE_DATE,
    T.PROC_MODIFY_DATE = S.PROC_MODIFY_DATE,
    T.PROC_TYPE = S.PROC_TYPE,
    T.CACHED_TIME = S.CACHED_TIME,
    T.TOTAL_ELAPSED_TIME_SECONDS = S.TOTAL_ELAPSED_TIME_SECONDS,
    T.TOTAL_WORKER_TIME_SECONDS = S.TOTAL_WORKER_TIME_SECONDS,
    T.TOTAL_LOGICAL_READS = S.TOTAL_LOGICAL_READS,
    T.TOTAL_LOGICAL_WRITES = S.TOTAL_LOGICAL_WRITES,
    T.TOTAL_PHYSICAL_READS = S.TOTAL_PHYSICAL_READS,
    T.TOTAL_SPILLS = S.TOTAL_SPILLS
WHEN NOT MATCHED BY TARGET THEN
    INSERT 
    (
        DATABASE_NAME,
        UNIQUE_ID,
        PROC_NAME,
        PROC_ID,
        PROC_CREATE_DATE,
        PROC_MODIFY_DATE,
        PROC_TYPE,
        CACHED_TIME,
        TOTAL_ELAPSED_TIME_SECONDS,
        TOTAL_WORKER_TIME_SECONDS,
        TOTAL_LOGICAL_READS,
        TOTAL_LOGICAL_WRITES,
        TOTAL_PHYSICAL_READS,
        TOTAL_SPILLS    
    ) 
    VALUES 
    (
        S.DATABASE_NAME,
        S.UNIQUE_ID,
        S.PROC_NAME,
        S.PROC_ID,
        S.PROC_CREATE_DATE,
        S.PROC_MODIFY_DATE,
        S.PROC_TYPE,
        S.CACHED_TIME,
        S.TOTAL_ELAPSED_TIME_SECONDS,
        S.TOTAL_WORKER_TIME_SECONDS,
        S.TOTAL_LOGICAL_READS,
        S.TOTAL_LOGICAL_WRITES,
        S.TOTAL_PHYSICAL_READS,
        S.TOTAL_SPILLS    
    );

-- END PROCEDURE
END
