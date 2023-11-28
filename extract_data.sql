-- Requires running set_sensor_table, set_aqdata_table, and compute_aqi_func

-- Need to enable OLE automation procedures to make an HTTP request call from a stored procedure
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO

-- Variable declaration related to the Object.
DECLARE @token INT;
DECLARE @ret INT;

-- Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX);
DECLARE @contentType NVARCHAR(64);
DECLARE @fieldsData NVARCHAR(MAX);
DECLARE @apiKey NVARCHAR(40);
DECLARE @sensorIDs NVARCHAR(MAX); -- 7 for 1 sensor
DECLARE @fields NVARCHAR(MAX);
DECLARE @parameters NVARCHAR(MAX);
DECLARE @CSV NVARCHAR(MAX);
DECLARE @col_cost INT;
DECLARE @num_sensors INT;

-- Response Variables
DECLARE @status NVARCHAR(32);
DECLARE @statusText NVARCHAR(32);
DECLARE @responseText NVARCHAR(MAX);

-- Variable declaration related to the JSON string.
DECLARE @json AS TABLE(json_val NVARCHAR(MAX));

-- Set Content Type
SET @contentType = 'application/json'

IF OBJECT_ID(N'dbo.Known_Sensor_IDs', N'U') IS NOT NULL
BEGIN
SELECT @sensorIDs = COALESCE(@sensorIDs + ',','') + id FROM [dbo].[Known_Sensor_IDs] WHERE [id] IS NOT NULL
SET @num_sensors = (SELECT COUNT(*) FROM [dbo].[Known_Sensor_IDs] WHERE [id] IS NOT NULL)
END
ELSE
BEGIN
SET @sensorIDs = '131305,102884' -- Sample sensor IDs
SET @num_sensors = 2
END
SET @sensorIDs = '131305,102884' -- Sample sensor IDs
SET @num_sensors = 2

IF OBJECT_ID(N'dbo.Known_Sensor_IDs', N'U') IS NOT NULL
BEGIN
SELECT @fieldsData = COALESCE(@fieldsData + ',','') + field_name FROM dbo.Fields WHERE include=1
END
ELSE
BEGIN
SET @fieldsData = -- CSV fields list
'name,temperature,pressure,pm2.5' -- Sample fields to include
--'name, model, location_type, latitude, longitude, altitude, last_seen, last_modified, date_created, confidence, humidity, temperature, pressure, pm2.5, pm2.5_atm, pm2.5_cf_1'
END
SET @fieldsData = -- CSV fields list
'name,temperature,pressure,pm2.5' -- Sample fields to include

SET @parameters = '?'
SET @parameters = @parameters + 'show_only=' + @sensorIDs
SET @parameters = @parameters + '&fields=' + @fieldsData

-- Set api 
SET @apiKey = 'B0333C6B-8CCC-11EE-8616-42010A80000B' -- Ho read API key

-- Define the URL
SET @url = 'https://api.purpleair.com/v1/sensors' + @parameters

PRINT @url;
SELECT @col_cost = SUM([point_cost]) FROM [dbo].[Fields] WHERE [include]=1;
PRINT 'Number of sensors: ' + CONVERT(varchar(10),@num_sensors) + ', Cost of columns per sensor: '+ CONVERT(varchar(10),@col_cost) + ', Estimate cost: ' + CONVERT(varchar(10),(@col_cost * @num_sensors))

-- This creates an instance of an OLE object
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- This calls the necessary methods.

EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';
EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'X-API-Key', @apiKey;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
--EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'sensor_index', @sensorID;
--EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'fields', @fields;
EXEC @ret = sp_OAMethod @token, 'send';

-- Grab the responseText property, and insert the JSON string into a table temporarily. 
-- This is very important, if you don't do this step you'll run into problems.
--INSERT into @json (Json_Table) EXEC sp_OAGetProperty @token, 'responseText' -- Insert into json table
EXEC @ret = sp_OAGetProperty @token, 'status', @status OUT;
EXEC @ret = sp_OAGetProperty @token, 'statusText', @statusText OUT;
EXEC @ret = sp_OAGetProperty @token, 'responseText', @responseText OUT;

INSERT INTO @json (json_val) EXEC sp_OAGetProperty @token, 'responseText'

-- See the Json_Table in @Json variable.
--SELECT * FROM @json
PRINT 'Status: ' + @status + ' (' + @statusText + ')'; -- Status 402: Payment Required
PRINT 'Response Text: ' + @responseText;

-- Close connection
EXEC @ret = sp_OADestroy @token;
IF @ret <> 0 RAISERROR('Unable to close HTTP connection.', 10, 1);

DECLARE @json_obj nvarchar(max)
SELECT @json_obj = [json_val] FROM @json

SELECT @fields = fields FROM OPENJSON(@json_obj) WITH (fields nvarchar(max) AS JSON);

-- PRINT @json_obj

IF (OBJECT_ID('tempdb..#Temp_Json') IS NOT NULL) DROP TABLE #Temp_Json;
CREATE TABLE #Temp_Json (
	json_val nvarchar(max)
)

--TRUNCATE TABLE dbo.Temp_Json
INSERT INTO dbo.#Temp_Json SELECT * FROM @json
--INSERT INTO dbo.Temp_Json EXEC sp_OAGetProperty @token, 'responseText'


-- Build dynamic SQL query

DECLARE @sql varchar(max);

DECLARE @NewLnChar AS CHAR(2) = CHAR(13) + CHAR(10);
DECLARE @TabChar AS CHAR(1) = CHAR(9);
DECLARE @field_name nvarchar(50);

DECLARE @i int;
DECLARE @length int = (SELECT COUNT(*) FROM OPENJSON(@fields));

DECLARE @fields_cs_list nvarchar(max) = '[time_stamp], [data_time_stamp], [max_age]';
SET @i = 0;
WHILE @i < @length
BEGIN
	SET @fields_cs_list = @fields_cs_list + ', [' + JSON_VALUE(@fields,CONCAT('$[',@i,']')) + ']'
	SET @i = @i + 1
END

-- Dynamic SQL to INSERT INTO dbo.AQ_Data
SET @sql = '
DECLARE @json_obj nvarchar(max);
SELECT @json_obj = [json_val] FROM #Temp_Json;
INSERT INTO [dbo].[AQ_Data] ('
SET @i = 0;
SET @sql = @sql + @fields_cs_list + ')
SELECT
	DATEADD(SS, time_stamp, ''1970-01-01 00:00:00'') AS time_stamp,
	DATEADD(SS, data_time_stamp, ''1970-01-01 00:00:00'') AS data_time_stamp,
	max_age,' + @NewLnChar + @TabChar

SET @i = 0;
WHILE @i < @length
BEGIN
	SET @field_name = JSON_VALUE(@fields,CONCAT('$[',@i,']'))
	SET @sql = @sql + 'MIN(CASE JSON_VALUE(@json_obj,CONCAT(''$.fields['',d.[key],'']'')) WHEN ''' + @field_name + ''' THEN d.value ELSE NULL END) AS [' + @field_name + ']'
	SET @i = @i + 1;
	IF @i <> @length
	SET @sql = @sql + ',' + @NewLnChar + @TabChar
END
SET @sql = @sql + @NewLnChar + '
FROM OPENJSON(@json_obj)
WITH (
	time_stamp bigint ''$.time_stamp'',
	data_time_stamp bigint ''$.data_time_stamp'',
	max_age int ''$.max_age'',
	fields nvarchar(max) AS JSON,
	data nvarchar(max) AS JSON
) a
CROSS APPLY OPENJSON(@json_obj, ''$.data'') AS fields_data
CROSS APPLY OPENJSON(fields_data.value) AS d
GROUP BY time_stamp, data_time_stamp, max_age, fields_data.value
EXCEPT
SELECT ' + @fields_cs_list + ' FROM [dbo].[AQ_Data];'

PRINT(@sql)

EXEC(@sql) -- Inserts into dbo.AQ_Data

IF (OBJECT_ID('tempdb..#Temp_Json') IS NOT NULL) DROP TABLE #Temp_Json;

SELECT * FROM [dbo].[AQ_Data]