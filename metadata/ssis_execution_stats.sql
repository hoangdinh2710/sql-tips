/*********************************** SSIS Execution Stats  **********************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Create view for Execution stats 
 */

-- Drop view if existed
IF EXISTS (
    SELECT
        *
    FROM
        sys.views
    WHERE
        name='BACKEND_SSIS_EXECUTION_DETAILS_VW'
) DROP VIEW [PROD].[BACKEND_SSIS_EXECUTION_DETAILS_VW];

GO

-- Create view: Execution stats for each component in package
CREATE VIEW
    PROD.BACKEND_SSIS_EXECUTION_DETAILS_VW AS
SELECT
    STATISTICS_ID,
    EXECUTION_ID,
    EXECUTION_PATH,
    START_TIME AS EXECUTION_START_TIME,
    END_TIME AS EXECUTION_END_TIME,
    CAST(EXECUTION_DURATION AS DECIMAL)/1000 AS EXECUTION_SECONDS,
    CASE
        WHEN execution_result=0 THEN 'Sucess'
        WHEN execution_result=1 THEN 'Failure'
        WHEN execution_result=2 THEN 'Completion'
        WHEN execution_result=3 THEN 'Cancelled'
    END AS EXECUTION_STATUS
FROM
    [SSISDB].[internal].[executable_statistics]