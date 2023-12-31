USE [master]
GO
/****** Object:  Database [PurpleAir_Data]    Script Date: 11/15/2023 11:02:59 AM ******/
CREATE DATABASE [PurpleAir_Data]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'purpleair', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\purpleair.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'purpleair_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\purpleair_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [PurpleAir_Data] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PurpleAir_Data].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PurpleAir_Data] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET ARITHABORT OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PurpleAir_Data] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PurpleAir_Data] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PurpleAir_Data] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PurpleAir_Data] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET RECOVERY FULL 
GO
ALTER DATABASE [PurpleAir_Data] SET  MULTI_USER 
GO
ALTER DATABASE [PurpleAir_Data] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PurpleAir_Data] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PurpleAir_Data] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PurpleAir_Data] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PurpleAir_Data] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PurpleAir_Data] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'PurpleAir_Data', N'ON'
GO
ALTER DATABASE [PurpleAir_Data] SET QUERY_STORE = ON
GO
ALTER DATABASE [PurpleAir_Data] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [PurpleAir_Data]
GO
/****** Object:  Table [dbo].[Location]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location](
	[Location_ID] [int] IDENTITY(1,1) NOT NULL,
	[Latitude] [float] NOT NULL,
	[Longitude] [float] NOT NULL,
	[Altitude] [int] NOT NULL,
	[PM2.5] [float] NOT NULL,
	[Humidity] [int] NOT NULL,
	[Temperature] [int] NOT NULL,
	[Pressure] [float] NOT NULL,
	[Date_Collected] [date] NOT NULL,
	[Sensor_ID] [int] NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[Location_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sensor]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor](
	[Sensor_ID] [int] NOT NULL,
	[Name] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Sensor] PRIMARY KEY CLUSTERED 
(
	[Sensor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sensor_Test]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor_Test](
	[Sensor_ID] [int] NOT NULL,
	[Name] [varchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Sensor] FOREIGN KEY([Sensor_ID])
REFERENCES [dbo].[Sensor] ([Sensor_ID])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Sensor]
GO
/****** Object:  StoredProcedure [dbo].[Bowie_High_School_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Bowie_High_School_PRO]
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
-- SET @url = 'https://api.purpleair.com/v1/sensors/131305'
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

END
GO
/****** Object:  StoredProcedure [dbo].[Charles_Flowers_HS_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Charles_Flowers_HS_PRO]
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
-- SET @url = 'https://api.purpleair.com/v1/sensors/131305'
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

-- [SensorData_Break1].[location_type], 
[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	-- [location_type] INT, 
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

/*
MERGE dbo.Location AS Target 
USING dbo.Location_Test AS Source 
ON Source.Location_ID = Target.Location_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Location_Type, Latitude, Longitude,
			Altitude, [pm2.5], Humidity,Temperature, 
			Pressure, Date_Collected, Sensor_ID)
	VALUES (Source.Location_Type, Source.Latitude, Source.Longitude,
			Source.Altitude, Source.[pm2.5], Source.Humidity,
			Source.Temperature, Source.Pressure, 
			Source.Date_Collected, Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET 
	Target.Location_Type = Source.Location_Type, 
	Target.Latitude = Source.Latitude, 
	Target.Longitude = Source.Longitude,
	Target.Altitude = Source.Altitude,
	Target.[pm2.5] = Source.[pm2.5],
	Target.Humidity = Source.Humidity,
	Target.Temperature = Source.Temperature,
	Target.Pressure = Source.Pressure,
	Target.Date_Collected = Source.Date_Collected,
	Target.Sensor_ID = Source.Sensor_ID;

-- Truncate Location test table
TRUNCATE TABLE dbo.Location_Test;
*/

END
GO
/****** Object:  StoredProcedure [dbo].[ERHS_lower_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ERHS_lower_PRO]
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

END
GO
/****** Object:  StoredProcedure [dbo].[International_HS_at_Largo_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[International_HS_at_Largo_PRO]
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

END
GO
/****** Object:  StoredProcedure [dbo].[Oxon_Hill_HS_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Oxon_Hill_HS_PRO]
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

END
GO
/****** Object:  StoredProcedure [dbo].[PGCPS_Schmidt_CenterBldg_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PGCPS_Schmidt_CenterBldg_PRO]
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

END
GO
/****** Object:  StoredProcedure [dbo].[Potomac_High_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Potomac_High_PRO]
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
-- SET @url = 'https://api.purpleair.com/v1/sensors/131305'
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

-- [SensorData_Break1].[location_type], 
[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	-- [location_type] INT, 
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

/*
MERGE dbo.Location AS Target 
USING dbo.Location_Test AS Source 
ON Source.Location_ID = Target.Location_ID

WHEN NOT MATCHED BY Target THEN
	INSERT (Location_Type, Latitude, Longitude,
			Altitude, [pm2.5], Humidity,Temperature, 
			Pressure, Date_Collected, Sensor_ID)
	VALUES (Source.Location_Type, Source.Latitude, Source.Longitude,
			Source.Altitude, Source.[pm2.5], Source.Humidity,
			Source.Temperature, Source.Pressure, 
			Source.Date_Collected, Source.Sensor_ID)

WHEN MATCHED THEN UPDATE SET 
	Target.Location_Type = Source.Location_Type, 
	Target.Latitude = Source.Latitude, 
	Target.Longitude = Source.Longitude,
	Target.Altitude = Source.Altitude,
	Target.[pm2.5] = Source.[pm2.5],
	Target.Humidity = Source.Humidity,
	Target.Temperature = Source.Temperature,
	Target.Pressure = Source.Pressure,
	Target.Date_Collected = Source.Date_Collected,
	Target.Sensor_ID = Source.Sensor_ID;

-- Truncate Location test table
TRUNCATE TABLE dbo.Location_Test;
*/

END
GO
/****** Object:  StoredProcedure [dbo].[William_S_Schmidt_PRO]    Script Date: 11/15/2023 11:02:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[William_S_Schmidt_PRO]
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
-- SET @url = 'https://api.purpleair.com/v1/sensors/131305'
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
	[name] VARCHAR(MAX),
	[sensor_index] INT

) AS SensorData_Break1

-- Merge and update/insert
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

-- Lacation Test table insert code

INSERT INTO dbo.Location (Latitude, Longitude,
							   Altitude, [PM2.5], Humidity,
						       Temperature, Pressure, Date_Collected, Sensor_ID)
SELECT 

[SensorData_Break1].[latitude],
[SensorData_Break1].[longitude],
[SensorData_Break1].[altitude],
[SensorData_Break1].[pm2.5],
[SensorData_Break1].[humidity],
[SensorData_Break1].[temperature],
[SensorData_Break1].[pressure],
DATEADD(ss, [SensorData_Break1].[last_seen], '1970'),
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
	[sensor_index] INT,
	[latitude] FLOAT,
	[longitude] FLOAT,
	[altitude] INT,
	[last_seen] BIGINT,
	[humidity] INT,
	[temperature] INT,
	[pressure] FLOAT,
	[pm2.5] FLOAT
) AS SensorData_Break1

END
GO
USE [master]
GO
ALTER DATABASE [PurpleAir_Data] SET  READ_WRITE 
GO
