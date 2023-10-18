/*********************************** Remove Duplicate  **********************
-------------------------------------------------------------------------------
Author:           Harry Dinh
Purpose:          Template to remove duplicate rows
 */

-- Sort by field and select the first row only
SELECT
    *
INTO
    [SILVER].[PROD].[IP_CENTER_INCIDENT_N_SERVICE_REQUEST]
FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY
                    TICKET_NUMBER
                ORDER BY
                    CLOSED_DT DESC
            ) RECORD_RANK
        FROM
            #tbl_MAIN
    ) AS [FINAL]
WHERE
    RECORD_RANK=1