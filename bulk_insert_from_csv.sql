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
-- Assume CSV name in this format: file0.csv, file1.csv, file2.csv...
DECLARE @a INT = 0
DECLARE @sql VARCHAR(MAX)
DECLARE @filePath VARCHAR(200) = 'C:\Data\file_.csv'

WHILE @a <= 100
BEGIN
    SET @sql = 
	'	
		BULK INSERT TABLE_NAME
		FROM ''C:\Data\file_' + CONVERT(VARCHAR,@a) +'.csv''
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

--Insert all CSV files in a folder, regardless of file name pattern

--create a table to loop thru filenames drop table ALLFILENAMES
CREATE TABLE ALLFILENAMES(FILE_PATH VARCHAR(255),FILE_NAME varchar(255))

--some variables
declare @fileName varchar(255),
        @filePath varchar(255),
        @sql      varchar(8000),
        @cmd      varchar(1000)

-- NOTE: need to update the drive name if file in different drive. In this example, file is in E drive
--get the list of files to process
SET @filePath = 'E:\Data\'
-- write a command line query to get all file in folder
SET @cmd = 'E: & cd ' + @filePath + '& dir *.csv /b' 

INSERT INTO  ALLFILENAMES(FILE_NAME)
EXEC Master..xp_cmdShell @cmd
UPDATE ALLFILENAMES SET FILE_PATH = @filePath where FILE_PATH is null

--cursor loop
declare c1 cursor for SELECT FILE_PATH,FILE_NAME FROM ALLFILENAMES where FILE_NAME like '%.csv%'
open c1
fetch next from c1 into @filePath,@fileName
While @@fetch_status <> -1
    begin
    --bulk insert won't take a variable name, so make a sql and execute it instead:
    set @sql = 'BULK INSERT TABLE_NAME FROM ''' + @filePath + @fileName + ''' '
        + '     WITH ( 
                FIELDTERMINATOR = '','', 
                ROWTERMINATOR = ''\n'', 
                FIRSTROW = 2 
            ) '
print @sql
exec (@sql)

    fetch next from c1 into @filePath,@fileName
    end
close c1
deallocate c1

drop table ALLFILENAMES

