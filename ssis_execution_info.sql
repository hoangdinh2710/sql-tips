/***************************** SSIS Execution Info View ***********************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Create view for executon info 
*/

-- Drop view if existed
IF EXISTS (
    SELECT
        *
    FROM
        sys.views
    WHERE
        name='BACKEND_SSIS_EXECUTION_INFO_VW'
) DROP VIEW [PROD].[BACKEND_SSIS_EXECUTION_INFO_VW];

GO

--  Create view: Stats for each execution (package-level)
CREATE VIEW PROD.BACKEND_SSIS_EXECUTION_INFO_VW
    AS
SELECT
    EXECUTION_ID,
    FOLDER_NAME,
    PROJECT_NAME,
    PACKAGE_NAME,
    START_TIME,
    END_TIME,
    SERVER_NAME,
    DATEDIFF(s,START_TIME,END_TIME) AS DURATION_SECONDS,
CASE 
    WHEN [status] =  1 THEN 'Created'
    WHEN [status] =  2 THEN 'Running'
    WHEN [status] =  3 THEN 'Canceled'
    WHEN [status] =  4 THEN 'Failed'
    WHEN [status] =  5 THEN 'Pending'
    WHEN [status] =  6 THEN 'Ended Unexpectedly'
    WHEN [status] =  7 THEN 'Succeeded'
    WHEN [status] =  8 THEN 'Stopping'
    WHEN [status] =  9 THEN 'Completed'
END AS RUN_STATUS
FROM [SSISDB].[internal].[execution_info]