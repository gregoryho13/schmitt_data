USE [master]
GO
/****** Object:  Database [test4]    Script Date: 12/9/2023 8:32:25 AM ******/
CREATE DATABASE [test4]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'test4', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\test4.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'test4_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\test4_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [test4] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [test4].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [test4] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [test4] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [test4] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [test4] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [test4] SET ARITHABORT OFF 
GO
ALTER DATABASE [test4] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [test4] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [test4] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [test4] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [test4] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [test4] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [test4] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [test4] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [test4] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [test4] SET  ENABLE_BROKER 
GO
ALTER DATABASE [test4] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [test4] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [test4] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [test4] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [test4] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [test4] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [test4] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [test4] SET RECOVERY FULL 
GO
ALTER DATABASE [test4] SET  MULTI_USER 
GO
ALTER DATABASE [test4] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [test4] SET DB_CHAINING OFF 
GO
ALTER DATABASE [test4] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [test4] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [test4] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [test4] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'test4', N'ON'
GO
ALTER DATABASE [test4] SET QUERY_STORE = ON
GO
ALTER DATABASE [test4] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [test4]
GO
/****** Object:  UserDefinedFunction [dbo].[compute_aqi]    Script Date: 12/9/2023 8:32:25 AM ******/
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
/****** Object:  Table [dbo].[Location]    Script Date: 12/9/2023 8:32:25 AM ******/
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
/****** Object:  Table [dbo].[Sensor]    Script Date: 12/9/2023 8:32:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor](
	[Sensor_ID] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
 CONSTRAINT [PK_Sensor] PRIMARY KEY CLUSTERED 
(
	[Sensor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sensor_Test]    Script Date: 12/9/2023 8:32:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sensor_Test](
	[Sensor_ID] [int] NOT NULL,
	[Name] [nvarchar](max) NULL,
 CONSTRAINT [PK_Sensor_Test] PRIMARY KEY CLUSTERED 
(
	[Sensor_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Location]  WITH CHECK ADD  CONSTRAINT [FK_Location_Sensor] FOREIGN KEY([Sensor_ID])
REFERENCES [dbo].[Sensor] ([Sensor_ID])
GO
ALTER TABLE [dbo].[Location] CHECK CONSTRAINT [FK_Location_Sensor]
GO
/****** Object:  StoredProcedure [dbo].[execute_sensor_data_extraction]    Script Date: 12/9/2023 8:32:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[execute_sensor_data_extraction]
AS BEGIN

DECLARE @key NVARCHAR(50) = 'A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- Bowie High School
EXEC sensor_data_extraction @sensor_index='102840', @apiKey=@key;

-- Charles Flowers HS
EXEC sensor_data_extraction @sensor_index='102884', @apiKey=@key;

-- ERHS lower
EXEC sensor_data_extraction @sensor_index='102990', @apiKey=@key;

-- International HS at Largo
EXEC sensor_data_extraction @sensor_index='102830', @apiKey=@key;

-- Oxon Hill HS
EXEC sensor_data_extraction @sensor_index='104790', @apiKey=@key;

-- PGCPS_Schmidt_CenterBldg
EXEC sensor_data_extraction @sensor_index='102898', @apiKey=@key;

-- Potomac High
EXEC sensor_data_extraction @sensor_index='131305', @apiKey=@key;

-- William S Schmidt
EXEC sensor_data_extraction @sensor_index='134488', @apiKey=@key;

-- [ Replace this with the name of the new sensor. On the next line, remove (--) and update sensor_index with a sensor code]
-- EXEC sensor_data_extraction @sensor_index='', @apiKey=@key;


END 
GO
/****** Object:  StoredProcedure [dbo].[sensor_data_extraction]    Script Date: 12/9/2023 8:32:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sensor_data_extraction] @sensor_index NVARCHAR(20), @apiKey NVARCHAR(40) 
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
GO
USE [master]
GO
ALTER DATABASE [test4] SET  READ_WRITE 
GO
