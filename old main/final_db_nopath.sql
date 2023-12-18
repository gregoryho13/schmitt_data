 /****** Object:  UserDefinedFunction [dbo].[compute_aqi]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[compute_aqi] (@Cp float)
RETURNS int
AS
BEGIN -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
	DECLARE @Ih int;
	DECLARE @Il int;
	DECLARE @BPh float;
	DECLARE @BPl float;
	IF @Cp > 350.5
	BEGIN
		SET @Ih = 500;
		SET @Il = 401;
		SET @BPh = 500.4;
		SET @BPl = 350.5;
	END
	ELSE IF @Cp > 250.5
	BEGIN
		SET @Ih = 400;
		SET @Il = 301;
		SET @BPh = 350.4;
		SET @BPl = 250.5;
	END
	ELSE IF @Cp > 150.5
	BEGIN
		SET @Ih = 300;
		SET @Il = 201;
		SET @BPh = 250.4;
		SET @BPl = 150.5;
	END
	ELSE IF @Cp > 55.5
	BEGIN
		SET @Ih = 200;
		SET @Il = 151;
		SET @BPh = 150.4;
		SET @BPl = 55.5;
	END
	ELSE IF @Cp > 35.5
	BEGIN
		SET @Ih = 150;
		SET @Il = 101;
		SET @BPh = 55.4;
		SET @BPl = 35.5;
	END
	ELSE IF @Cp > 12.1
	BEGIN
		SET @Ih = 100;
		SET @Il = 51;
		SET @BPh = 35.4;
		SET @BPl = 12.1;
	END
	ELSE IF @Cp >= 0
	BEGIN
		SET @Ih = 50;
		SET @Il = 0;
		SET @BPh = 12;
		SET @BPl = 0;
	END
	ELSE RETURN NULL

	RETURN CONVERT(int,ROUND(1.0 * (@Ih - @Il)/(@BPh - @BPl) * (@Cp - @BPl) + @Il, 0))
END
GO
/****** Object:  Table [dbo].[Location]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location](
	[Location_ID] [int] IDENTITY(1,1) NOT NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[Altitude] [int] NULL,
	[PM2.5] [float] NULL,
	[Humidity] [int] NULL,
	[Temperature] [int] NULL,
	[Pressure] [float] NULL,
	[Date_Collected] [datetime2](7) NULL,
	[Sensor_ID] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
	[Calculated_AQI] [int] NULL,
	[Calculated_AQI_Rating] [nchar](50) NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[Location_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sensor]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor](
	[Sensor_ID] [int] NOT NULL,
 CONSTRAINT [PK_Sensor] PRIMARY KEY CLUSTERED 
(
	[Sensor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sensor_Test]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor_Test](
	[Sensor_ID] [int] NOT NULL,
 CONSTRAINT [PK_Sensor_Test] PRIMARY KEY CLUSTERED 
(
	[Sensor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Sensor] FOREIGN KEY([Sensor_ID])
REFERENCES [dbo].[Sensor] ([Sensor_ID])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Sensor]
GO
/****** Object:  StoredProcedure [dbo].[Bowie_High_School_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Bowie_High_School_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/102840?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[Charles_Flowers_HS_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Charles_Flowers_HS_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/102884?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[ERHS_lower_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ERHS_lower_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/102990?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[Exec_All_Sensor_Procedures]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Exec_All_Sensor_Procedures]
AS BEGIN

Exec [dbo].[Bowie_High_School_Pro];
Exec [dbo].[Charles_Flowers_HS_Pro];
Exec [dbo].[ERHS_lower_Pro];
Exec [dbo].[International_HS_at_Largo_Pro];
Exec [dbo].[Oxon_Hill_HS_Pro];
Exec [dbo].[PGCPS_Schmidt_CenterBldg_Pro];
Exec [dbo].[Potomac_High_Pro];
Exec [dbo].[William_S_Schmidt_Pro];

END
GO
/****** Object:  StoredProcedure [dbo].[International_HS_at_Largo_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[International_HS_at_Largo_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/102830?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[Oxon_Hill_HS_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Oxon_Hill_HS_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/104790?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[PGCPS_Schmidt_CenterBldg_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PGCPS_Schmidt_CenterBldg_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/102898?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[Potomac_High_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Potomac_High_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/131305?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
GO
/****** Object:  StoredProcedure [dbo].[William_S_Schmidt_Pro]    Script Date: 11/30/2023 10:30:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[William_S_Schmidt_Pro]
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
-- Insert sensor_index number between 'sensors/' and '?' to get data for that sensor
SET @url = 'https://api.purpleair.com/v1/sensors/134488?fields=name%2C%20location_type%2C%20%20latitude%2C%20longitude%2C%20altitude%2C%20humidity%2C%20temperature%2C%20pressure%2C%20last_seen%2C%20%20pm2.5'

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
-- SELECT * FROM @json

-- The following Section will not print any outputs. You will have to run seperate select states for the tables.

-- Sensor test table insert code 

INSERT INTO dbo.Sensor_Test (Sensor_ID)
SELECT 

[SensorData_Break1].[sensor_index]

FROM OPENJSON((SELECT * FROM @json))

WITH(
	[api_version] NVARCHAR(MAX),
	[time_stamp] BIGINT,
	[data_time_stamp] BIGINT,
	[sensor] NVARCHAR (MAX) AS JSON
) AS SensorData

CROSS APPLY OPENJSON([SensorData].[sensor])
WITH(
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update Sensor table 

MERGE dbo.Sensor AS Target
USING dbo.Sensor_Test AS Source
ON Source.Sensor_ID = Target.Sensor_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Sensor_ID)
	VALUES (Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET  
	Target.Sensor_ID = Source.Sensor_ID;

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

-- Update the Calculated_AQI column on on the Location table

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
