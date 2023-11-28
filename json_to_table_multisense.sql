-- After
-- INSERT INTO @json (json_val) EXEC sp_OAGetProperty @token, 'responseText'
-- TRUNCATE TABLE dbo.Temp_Json
-- INSERT INTO dbo.Temp_Json SELECT * FROM @json

IF OBJECT_ID(N'Temp_Json', N'U') IS NULL
BEGIN
CREATE TABLE Temp_Json (
json nvarchar(MAX) NOT NULL
);
END

--DECLARE @fields nvarchar(max)
DECLARE @json nvarchar(max);
DECLARE @sql varchar(max);
DECLARE @fields nvarchar(max);
DECLARE @field_name nvarchar(50);

-- SELECT * FROM Temp_Json

SELECT @json = [json] FROM Temp_Json
SELECT @fields = fields FROM OPENJSON(@json) WITH (fields nvarchar(max) as JSON);

--PRINT @json
--PRINT @fields

DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)
DECLARE @TabChar AS CHAR(1) = CHAR(9)

DECLARE @i int;
DECLARE @length int = (SELECT COUNT(*) FROM OPENJSON(@fields));

DECLARE @fields_cs_list nvarchar(max) = '[time_stamp], [data_time_stamp], [max_age]';
SET @i = 0;
WHILE @i < @length
BEGIN
	SET @fields_cs_list = @fields_cs_list + ', [' + JSON_VALUE(@fields,CONCAT('$[',@i,']')) + ']'
	SET @i = @i + 1
END


--INSERT INTO @test
SET @sql = '
DECLARE @json nvarchar(max);
SELECT @json = [json] FROM Temp_Json;
INSERT INTO [dbo].[AQ_Data] ('
SET @i = 0;
SET @sql = @sql + @fields_cs_list + ')
SELECT
	DATEADD(SS, time_stamp, ''1970-01-01 00:00:00'') AS time_stamp,
	DATEADD(SS, data_time_stamp, ''1970-01-01 00:00:00'') AS data_time_stamp,
	max_age,' + @NewLineChar + @TabChar

SET @i = 0;
WHILE @i < @length
BEGIN
	SET @field_name = JSON_VALUE(@fields,CONCAT('$[',@i,']'))
	SET @sql = @sql + 'MIN(CASE JSON_VALUE(@json,CONCAT(''$.fields['',d.[key],'']'')) WHEN ''' + @field_name + ''' THEN d.value ELSE NULL END) AS [' + @field_name + ']'
	SET @i = @i + 1;
	IF @i <> @length
	SET @sql = @sql + ',' + @NewLineChar + @TabChar
END
SET @sql = @sql + @NewLineChar + '
FROM OPENJSON(@json)
WITH (
	time_stamp bigint ''$.time_stamp'',
	data_time_stamp bigint ''$.data_time_stamp'',
	max_age int ''$.max_age'',
	fields nvarchar(max) AS JSON,
	data nvarchar(max) AS JSON
) a
CROSS APPLY OPENJSON(@json, ''$.data'') as fields_data
CROSS APPLY OPENJSON(fields_data.value) as d
GROUP BY time_stamp, data_time_stamp, max_age, fields_data.value
EXCEPT
SELECT ' + @fields_cs_list + ' FROM [dbo].[AQ_Data];'

PRINT(@sql)

EXEC(@sql) -- Inserts into dbo.AQ_Data

SELECT * FROM [dbo].[AQ_Data]