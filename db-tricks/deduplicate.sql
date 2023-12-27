/*********************************** Remove Duplicate  **********************
 -------------------------------------------------------------------------------
 Author:           Harry Dinh
 Purpose:          Template to remove duplicate rows
 */
   
-- Sort by field and select the first row only
SELECT
    * INTO [DATABASE_NAME].[SCHEMA_NAME].[TABLE_NAME]
FROM
    (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY COLUMN_NAME
                ORDER BY
                    SORT_COLUMN_NAME DESC
            ) RECORD_RANK
        FROM
            #tbl_MAIN
    ) AS [FINAL]
WHERE
    RECORD_RANK = 1