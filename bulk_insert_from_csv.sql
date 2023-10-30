-- Insert a single CSV file
DECLARE @filePath VARCHAR(200) = 'C:\Data\file.csv'

BEGIN
BULK INSERT TABLE_NAME
FROM filePath
WITH
(
FIELDTERMINATOR = N',',
ROWTERMINATOR = N'\n',
FIRSTROW = 2 -- to remove header row
)

END;
-- Insert all CSV files in a folder
DECLARE @a INT = 660
DECLARE @sql VARCHAR(MAX)

WHILE @a <= 661
BEGIN
    SET @sql = 
	'	
		BULK INSERT [STAGE].[GENESYS_USER_PRESENCE]
		FROM ''E:\SSIS Packages\Parallel_Query_Data\USER_PRESENCE\data_batch_' + CONVERT(VARCHAR,@a) +'.csv''
		WITH
		(
		FIELDTERMINATOR = N'','',
		ROWTERMINATOR = N''\n'',
		FIRSTROW = 2
		)
	'
	EXEC (@sql);
    SET @a = @a + 1
END
