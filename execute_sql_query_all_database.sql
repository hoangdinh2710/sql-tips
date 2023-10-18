/*************************** SQL SERVER Get All Tables ***************************
 -------------------------------------------------------------------------------
 Author:           Harry Dinh
 Purpose:          Loop through each database and execute SQL Query
 */

-- For all databases
DECLARE @SQL NVARCHAR(4000)
SET
    @SQL = '
            SELECT  
            *
            FROM TABLE_A
           ' EXEC sp_MSforeachdb @SQL;

-- Exclude system databases
SET
    @SQL = '
    
    IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'', ''ssisdb'') 
    BEGIN 
    USE ? 

    SELECT  
            *
            FROM TABLE_A
    
    END
' EXEC sp_MSforeachdb @SQL;