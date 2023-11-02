DROP PROCEDURE IF EXISTS dbo.Potomac_High_PRO
GO

CREATE PROCEDURE dbo.Potomac_High_PRO
AS BEGIN

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE

-- Variable declaration related to the Object.
DECLARE @token INT;
DECLARE @ret INT;

-- Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX);
DECLARE @contentType NVARCHAR(64);
DECLARE @apiKey NVARCHAR(40);

-- Variable declaration related to the JSON string.
DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX));

-- Set Content Type
SET @contentType = 'application/json'

-- Set api 
SET @apiKey = 'A4C1A5B7-6715-11EE-A8AF-42010A80000A'

-- Define the URL
SET @url = 'https://api.purpleair.com/v1/sensors/131305'

-- This creates the new object.
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- This calls the necessary methods.

EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';
EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'X-API-Key', @apiKey;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
EXEC @ret = sp_OAMethod @token, 'send'

-- Grab the responseText property, and insert the JSON string into a table temporarily. 
-- This is very important, if you don't do this step you'll run into problems.
INSERT into @json (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

-- See the Json_Table in @Json variable.
SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_Key, Name, 
                        Private, Hardware, 
						Firmware_Version, RSSI,
						Uptime, Memory,
						Last_Modified, Date_Created,
						Model)
SELECT 

[SensorData_Break1].[sensor_index],
[SensorData_Break1].[name],
[SensorData_Break1].[private],
[SensorData_Break1].[hardware],
[SensorData_Break1].[firmware_version],
[SensorData_Break1].[rssi],
[SensorData_Break1].[uptime],
[SensorData_Break1].[memory],
[SensorData_Break1].[last_modified],
[SensorData_Break1].[date_created],
[SensorData_Break1].[model]


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
	[model] VARCHAR(MAX)

) AS SensorData_Break1

-- Merge and update/insert
MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_Key = Target.Sensor_Key

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_Key, Name, 
            Private, Hardware, 
			Firmware_Version, RSSI,
			Uptime, Memory,
			Last_Modified, Date_Created,
			Model)
	VALUES (Source.Sensor_Key, Source.Name, 
            Source.Private, Source.Hardware, 
		    Source.Firmware_Version, Source.RSSI,
			Source.Uptime, Source.Memory,
			Source.Last_Modified, Source.Date_Created,
		    Source.Model)

WHEN MATCHED THEN UPDATE SET 
	Target.Sensor_Key = Source.Sensor_Key, 
	Target.Name = Source.Name, 
    Target.Private = Source.Private, 
	Target.Hardware = Source.Hardware, 
	Target.Firmware_Version = Source.Firmware_Version, 
	Target.RSSI = Source.RSSI,
	Target.Uptime = Source.Uptime, 
	Target.Memory = Source.Memory,
	Target.Last_Modified = Source.Last_Modified, 
	Target.Date_Created = Source.Date_Created,
	Target.Model = Source.Model;

-- Truncate Sensor test table
TRUNCATE TABLE dbo.Sensor_Test;

-- Lacation Test table insert code

INSERT INTO dbo.Location_Test (Location_Key, Location_Type, 
						  Latitude, Longitude,
						  Altitude, Position_Rating)
SELECT 

[SensorData_Break1].[sensor_index],
[SensorData_Break1].[location_type], 
[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[position_rating]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT,
	[location_type] INT, 
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[position_rating] INT
) AS SensorData_Break1

MERGE dbo.Location AS Target 
USING dbo.Location_Test AS Source 
ON Source.Location_Key = Target.Location_Key

WHEN NOT MATCHED BY Target THEN
	INSERT (Location_Key, Location_Type, 
			Latitude, Longitude,
			Altitude, Position_Rating)
	VALUES (Source.Location_Key, Source.Location_Type, 
			Source.Latitude, Source.Longitude,
			Source.Altitude, Source.Position_Rating)

WHEN MATCHED THEN UPDATE SET
	Target.Location_Key = Source.Location_Key, 
	Target.Location_Type = Source.Location_Type, 
	Target.Latitude = Source.Latitude, 
	Target.Longitude = Source.Longitude,
	Target.Altitude = Source.Altitude, 
	Target.Position_Rating = Source.Position_Rating;

-- Truncate Location test table
TRUNCATE TABLE dbo.Location_Test;


 -- Temp table insert code

INSERT INTO dbo.Temp (Temperature_Key, Humidity, 
						  Temperature, Pressure,
						  Date_Collected)
SELECT 

[SensorData_Break1].[sensor_index],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970')

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[stats] NVARCHAR(MAX) AS JSON
) AS SensorData_Break1



-- PM table insert code

INSERT INTO dbo.Mass_Concentration_PM (Mass_Concentration_Key, [PM2.5],
                                       [PM2.5_10Minute], [PM2.5_30Minute],
									   [PM2.5_60Minute], [PM2.5_6Hours],
									   [PM2.5_24Hours], [PM2.5_1Week], Date_Collected)
SELECT 

[SensorData_Break1].[sensor_index],
[SensorData_Break2].[pm2.5],
[SensorData_Break2].[pm2.5_10minute],
[SensorData_Break2].[pm2.5_30minute],
[SensorData_Break2].[pm2.5_60minute],
[SensorData_Break2].[pm2.5_6hour],
[SensorData_Break2].[pm2.5_24hour],
[SensorData_Break2].[pm2.5_1week], 
DATEADD(ss, [SensorData_Break1].[last_seen], '1970')

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT,
	[last_seen] BIGINT,
	[stats] NVARCHAR(MAX) AS JSON
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

END