DROP PROCEDURE IF EXISTS dbo.sensor_data_extraction
GO

CREATE PROCEDURE dbo.sensor_data_extraction @sensor_index NVARCHAR(20), @apiKey NVARCHAR(40) 
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
DECLARE @url2 NVARCHAR(MAX);
DECLARE @url3 NVARCHAR(MAX);
DECLARE @contentType NVARCHAR(64);

-- Variable declaration related to the JSON string.
DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX));

-- Set Content Type

SET @contentType = 'application/json'

-- Define the URL

SET @url = 'https://api.purpleair.com/v1/sensors/'
SET @url2 = '?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'
SET @url3 = @url + @sensor_index + @url2

-- This creates the new object.

EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- This calls the necessary methods.

EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url3, 'false';
EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'X-API-Key', @apiKey;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
EXEC @ret = sp_OAMethod @token, 'send'

-- Grab the responseText property, and insert the JSON string into a temporary table. 

INSERT into @json (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

-- See the Json_Table in @Json variable.
-- SELECT * FROM @json

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID, Name)
SELECT 

[SensorData_Break1].[sensor_index],
[SensorData_Break1].[name]

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
	[name] VARCHAR(MAX)

) AS SensorData_Break1

-- Merge and update Sensor table using test sensor table

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID, Name)
	VALUES (Source.Sensor_ID, Source.Name)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID,
	Target.Name = Source.Name;

-- Truncate Sensor test table

TRUNCATE TABLE dbo.Sensor_Test;


-- Lacation table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID, Name)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(SS, [SensorData_Break1].[last_seen], '1970-01-01 00:00:00'),
[SensorData_Break1].[sensor_index],
[SensorData_Break1].[name]

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
	[latitude] FLOAT,
	[name] VARCHAR(MAX),
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

-- Update the Calculated_AQI column on the Location table

UPDATE dbo.Location
SET [Calculated_AQI] = [dbo].[compute_aqi]([PM2.5])

-- Update the Calculated_AQI_Rating column on the Location table

UPDATE dbo.Location
SET [Calculated_AQI_Rating] = CASE
			WHEN [Calculated_AQI] > 300 THEN 'Hazardous'
			WHEN [Calculated_AQI] > 200 THEN 'Very unhealthy'
			WHEN [Calculated_AQI] > 150 THEN 'Unhealthy'
			WHEN [Calculated_AQI] > 100 THEN 'Unhealthy for sensitive groups'
			WHEN [Calculated_AQI] > 50 THEN 'Moderate'
			WHEN [Calculated_AQI] >= 0 THEN 'Good'
			ELSE NULL END

END