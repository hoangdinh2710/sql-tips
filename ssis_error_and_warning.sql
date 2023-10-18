/****************************** SSIS Error Message *****************************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Create view for execution error messages
 */

-- Drop view if existed
IF EXISTS (
    SELECT
        *
    FROM
        sys.views
    WHERE
        name='BACKEND_EXECUTION_ERROR_MESSAGES_VW'
) DROP VIEW [PROD].[BACKEND_SSIS_EXECUTION_ERROR_MESSAGES_VW];

GO

-- Create view: Error message (Only pull warning, and Error message)
CREATE VIEW
    PROD.BACKEND_SSIS_EXECUTION_ERROR_MESSAGES_VW AS
SELECT
    [EVENT_MESSAGE_ID],
    [OPERATION_ID] AS [EXECUTION_ID],
    [MESSAGE_TIME],
    [MESSAGE],
    [PACKAGE_NAME],
    [EVENT_NAME] AS [MESSAGE_TYPE],
    [MESSAGE_SOURCE_NAME],
    [SUBCOMPONENT_NAME],
    [PACKAGE_PATH],
    [EXECUTION_PATH],
    [MESSAGE_CODE],
    [EVENT_MESSAGE_GUID]
FROM
    [SSISDB].[catalog].[event_messages]
WHERE
    message_type IN ('120', '110')