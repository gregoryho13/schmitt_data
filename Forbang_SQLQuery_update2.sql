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
DECLARE @authHeader NVARCHAR(64);
DECLARE @contentType NVARCHAR(64);
DECLARE @apiKey NVARCHAR(40);

-- Variable declaration related to the JSON string.
DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX));

-- Set Authentications
--SET @authHeader = 'HTTP/1.1'
--SET @apiKey = @authHeader+'X-API-Key: A4C1A5B7-6715-11EE-A8AF-42010A80000A'
SET @contentType = 'application/json'
-- Set Authentications
SET @authHeader = '{"X-API-Key": "A4C1A5B7-6715-11EE-A8AF-42010A80000A"}'
-- SET @contentType = 'application/x-www-form-urlencoded';

-- Set api 
SET @apiKey = 'A4C1A5B7-6715-11EE-A8AF-42010A80000A'
--SET @apikey = 'A4C1A5B7-6715-11EE-A8AF-42010A80000A'

-- Define the URL
-- SET @url = 'https://api.purpleair.com/v1/sensors?fields=name'
SET @url = 'https://api.purpleair.com/v1/sensors/131305'

-- This creates the new object.
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- This calls the necessary methods.
EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';
EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'X-API-Key', @apiKey;
--EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Authentication', @authHeader;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
EXEC @ret = sp_OAMethod @token, 'send'

-- Grab the responseText property, and insert the JSON string into a table temporarily. 
-- This is very important, if you don't do this step you'll run into problems.
INSERT into @json (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

-- Select the JSON string from the Table we just inserted it into. You'll also be able to see the entire string with this statement.
SELECT * FROM @json

SELECT 

[SensorData_Break1].[name],
[SensorData_Break1].[sensor_index],
[SensorData_Break1].[private], 
[SensorData_Break1].[last_seen],
[SensorData_Break1].[hardware],
[SensorData_Break1].[firmware_version],
[SensorData_Break1].[rssi],
[SensorData_Break1].[uptime],
[SensorData_Break1].[memory],
[SensorData_Break1].[last_modified], 
[SensorData_Break1].[date_created],
[SensorData_Break1].[model],
[SensorData_Break1].[location_type], 
[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[position_rating],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
[SensorData_Break2].[pm2.5],
[SensorData_Break2].[pm2.5_10minute],
[SensorData_Break2].[pm2.5_30minute],
[SensorData_Break2].[pm2.5_60minute],
[SensorData_Break2].[pm2.5_6hour],
[SensorData_Break2].[pm2.5_24hour],
[SensorData_Break2].[pm2.5_1week]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[name] VARCHAR(MAX),
	[sensor_index] INT,
	[private] INT, 
	[last_seen] BIGINT,
	[hardware] VARCHAR(MAX),
	[firmware_version] FLOAT,
	[rssi] SMALLINT,
	[uptime] INT,
	[memory] INT,
	[last_modified] BIGINT, 
	[date_created] BIGINT,
	[model] VARCHAR(MAX),
	[location_type] INT, 
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[position_rating] INT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[stats] NVARCHAR(MAX) AS JSON
	-- [stats_a] NVARCHAR(MAX) AS JSON,
	-- [stats_b] NVARCHAR(MAX) AS JSON
) AS SensorData_Break1

CROSS APPLY OPENJSON([SensorData_Break1].[stats])
WITH(
	[pm2.5] FLOAT,
	[pm2.5_10minute] FLOAT,
	[pm2.5_30minute] FLOAT,
	[pm2.5_60minute] FLOAT,
	[pm2.5_6hour] FLOAT,
	[pm2.5_24hour] FLOAT,
	[pm2.5_1week] FLOAT
) SensorData_Break2

