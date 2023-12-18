-- Create PurpleAir_Data_NoFormat Database
USE master
GO
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = 'schmidt_center')
CREATE LOGIN schmidt_center WITH PASSWORD = 'williamsschmidt';
GO

-- Remake PurpleAir_Data_NoFormat database

--IF DB_ID (N'PurpleAir_Data_NoFormat') IS NOT NULL
--BEGIN
--	ALTER DATABASE [PurpleAir_Data_NoFormat] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
--	DROP DATABASE [PurpleAir_Data_NoFormat]
--END
--GO

-- Make PurpleAir_Data_NoFormat database if not exists
IF DB_ID (N'PurpleAir_Data_NoFormat') IS NULL
CREATE DATABASE [PurpleAir_Data_NoFormat];
GO

-- Create logins and schemas, particularly for organizational purposes
USE [PurpleAir_Data_NoFormat]
GO
IF NOT EXISTS(SELECT [name] FROM [sys].[database_principals] WHERE [type] = N'S' AND [name] = N'schmidt_center')
CREATE USER [schmidt_center] FROM LOGIN [schmidt_center]
GO
IF SCHEMA_ID('purple_air') IS NULL
BEGIN
	EXEC('CREATE SCHEMA [purple_air] AUTHORIZATION [schmidt_center]')
END
GO
IF EXISTS(SELECT [name] FROM [sys].[database_principals] WHERE [type] = N'S' AND [name] = N'schmidt_center')
ALTER LOGIN [schmidt_center] WITH DEFAULT_DATABASE = [PurpleAir_Data_NoFormat];
GO

--USE msdb
--CREATE USER [schmidt_center] FOR LOGIN [schmidt_center];
--ALTER ROLE SQLAgentOperatorRole ADD MEMBER [schmidt_center]
--GO

--USE [PurpleAir_Data_NoFormat]
--GO
--IF NOT EXISTS(SELECT [name] FROM [sys].[database_principals] WHERE [type] = N'S' AND [name] = N'schmidt_center')
--CREATE USER [schmidt_center] FROM LOGIN [LAPTOP];
--GO
--CREATE SCHEMA [purple_air] AUTHORIZATION [schmidt_center];
--GO
--ALTER LOGIN [schmidt_center] WITH DEFAULT_DATABASE = [PurpleAir_Data_NoFormat];
--GO
--USE msdb
--CREATE USER [LAPTOP] FOR LOGIN [LAPTOP];
--ALTER ROLE SQLAgentOperatorRole ADD MEMBER [LAPTOP]
--GO

-- Create Known_Sensor_IDs table
IF OBJECT_ID(N'[PurpleAir_Data_NoFormat].[purple_air].[Known_Sensor_IDs]', N'U') IS NULL
BEGIN
	CREATE TABLE [PurpleAir_Data_NoFormat].[purple_air].[Known_Sensor_IDs] (
		id bigint PRIMARY KEY CLUSTERED,
		name nvarchar(100) UNIQUE NULL
	);

	INSERT INTO [purple_air].[Known_Sensor_IDs] VALUES
	(134488,'William S Schmidt'),
	(102898,'PGCPS_Schmidt_CenterBldg'),
	(104790,'Oxon Hill HS'),
	(131305,'Potomac High'),
	(102830,'International HS at Largo'),
	(102884,'Charles Flowers HS'),
	(102840,'Bowie High School'),
	(102990,'ERHS lower')
	--(NULL,'Fairmont Heights HS')
END
GO
-- Compute_AQI Function required for AQ_Data
CREATE OR ALTER FUNCTION [purple_air].[compute_aqi] (@Cp float)
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
-- Create Fields table
DROP TABLE IF EXISTS [PurpleAir_Data_NoFormat].[purple_air].[Fields];
CREATE TABLE [PurpleAir_Data_NoFormat].[purple_air].[Fields] (
    field_name nvarchar(100) PRIMARY KEY CLUSTERED,
    include bit NOT NULL,
    point_cost tinyint NOT NULL,
);

INSERT INTO [PurpleAir_Data_NoFormat].[purple_air].[Fields] VALUES
('api_version',				0,		0),
('time_stamp',				0,		0),
('data_time_stamp',			0,		0),
('sensor_index',			0,		0),
('last_modified',			0,		1),
('date_created',			0,		1),
('last_seen',				1,		1),
('private',					0,		1),
('is_owner',				0,		1),
('name',					0,		1),
('icon',					0,		1),
('location_type',			0,		1),
('model',					0,		1),
('hardware',				0,		1),
('led_brightness',			0,		1),
('firmware_version',		0,		1),
('firmware_upgrade',		0,		1),
('rssi',					0,		1),
('uptime',					0,		1),
('pa_latency',				0,		1),
('memory',					0,		1),
('position_rating',			0,		1),
('latitude',				1,		1),
('longitude',				1,		1),
('altitude',				1,		1),
('channel_state',			0,		1),
('channel_flags',			0,		1),
('channel_flags_manual',	0,		1),
('channel_flags_auto',		0,		1),
('confidence',				0,		1),
('confidence_auto',			0,		1),
('confidence_manual',		0,		1),
('humidity',				1,		2),
('humidity_a',				0,		1),
('humidity_b',				0,		1),
('temperature',				1,		2),
('temperature_a',			0,		1),
('temperature_b',			0,		1),
('pressure',				1,		2),
('pressure_a',				0,		1),
('pressure_b',				0,		1),
('voc',						0,		2),
('voc_a',					0,		1),
('voc_b',					0,		1),
('ozone1',					0,		1),
('analog_input',			0,		1),
('pm1.0',					0,		2),
('pm1.0_a',					0,		1),
('pm1.0_b',					0,		1),
('pm2.5',					1,		2),
('pm2.5_a',					0,		1),
('pm2.5_b',					0,		1),
('pm2.5_alt',				0,		2),
('pm2.5_alt_a',				0,		1),
('pm2.5_alt_b',				0,		1),
('pm10.0',					0,		2),
('pm10.0_a',				0,		1),
('pm10.0_b',				0,		1),
('pm2.5_10minute',			1,		2),
('pm2.5_10minute_a',		0,		1),
('pm2.5_10minute_b',		0,		1),
('pm2.5_30minute',			0,		2),
('pm2.5_30minute_a',		0,		1),
('pm2.5_30minute_b',		0,		1),
('pm2.5_60minute',			1,		2),
('pm2.5_60minute_a',		0,		1),
('pm2.5_60minute_b',		0,		1),
('pm2.5_6hour',				1,		2),
('pm2.5_6hour_a',			0,		1),
('pm2.5_6hour_b',			0,		1),
('pm2.5_24hour',			1,		2),
('pm2.5_24hour_a',			0,		1),
('pm2.5_24hour_b',			0,		1),
('pm2.5_1week',				1,		2),
('pm2.5_1week_a',			0,		1),
('pm2.5_1week_b',			0,		1),
('scattering_coefficient',	0,		2),
('scattering_coefficient_a',0,		1),
('scattering_coefficient_b',0,		1),
('deciviews',				0,		2),
('deciviews_a',				0,		1),
('deciviews_b',				0,		1),
('visual_range',			0,		2),
('visual_range_a',			0,		1),
('visual_range_b',			0,		1),
('0.3_um_count',			0,		2),
('0.3_um_count_a',			0,		1),
('0.3_um_count_b',			0,		1),
('0.5_um_count',			0,		2),
('0.5_um_count_a',			0,		1),
('0.5_um_count_b',			0,		1),
('1.0_um_count',			0,		2),
('1.0_um_count_a',			0,		1),
('1.0_um_count_b',			0,		1),
('2.5_um_count',			1,		2),
('2.5_um_count_a',			0,		1),
('2.5_um_count_b',			0,		1),
('5.0_um_count',			0,		2),
('5.0_um_count_a',			0,		1),
('5.0_um_count_b',			0,		1),
('10.0_um_count',			0,		2),
('10.0_um_count_a',			0,		1),
('10.0_um_count_b',			0,		1),
('pm1.0_cf_1',				0,		2),
('pm1.0_cf_1_a',			0,		1),
('pm1.0_cf_1_b',			0,		1),
('pm1.0_atm',				0,		2),
('pm1.0_atm_a',				0,		1),
('pm1.0_atm_b',				0,		1),
('pm2.5_atm',				0,		2),
('pm2.5_atm_a',				0,		1),
('pm2.5_atm_b',				0,		1),
('pm2.5_cf_1',				0,		2),
('pm2.5_cf_1_a',			0,		1),
('pm2.5_cf_1_b',			0,		1),
('pm10.0_atm',				0,		2),
('pm10.0_atm_a',			0,		1),
('pm10.0_atm_b',			0,		1),
('pm10.0_cf_1',				0,		2),
('pm10.0_cf_1_a',			0,		1),
('pm10.0_cf_1_b',			0,		1)
GO
-- Create AQ_Data table
IF OBJECT_ID(N'[PurpleAir_Data_NoFormat].[purple_air].[AQ_Data]', N'U') IS NULL
BEGIN
	CREATE TABLE [PurpleAir_Data_NoFormat].[purple_air].[AQ_Data] (
		ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		data_time_stamp datetime NOT NULL,
		last_seen datetime NULL,
		time_stamp datetime NULL,
		sensor_index bigint FOREIGN KEY REFERENCES [purple_air].[Known_Sensor_IDs](id) NOT NULL,
		--name nvarchar(100) NULL,
		latitude float NULL,
		longitude float NULL,
		altitude float NULL,
		temperature int NULL,
		pressure float NULL,
		humidity int NULL,
		[pm2.5] float NULL,
		calculated_AQI AS [purple_air].[compute_aqi]([pm2.5]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		calculated_AQI_rating AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5]) >= 0 THEN 'good'
			ELSE NULL END,
		max_age int NULL,
		--api_version varchar(25) NULL,
		--last_modified datetime NULL,
		--date_created datetime NULL,
		--private tinyint NULL,
		--is_owner float NULL,
		--icon int NULL,
		--location_type tinyint NULL,
		--model nvarchar(100) NULL,
		--hardware varchar(100) NULL,
		--led_brightness float NULL,
		--firmware_version varchar(25) NULL,
		--firmware_upgrade varchar(25) NULL,
		--rssi int NULL,
		--uptime int NULL,
		--pa_latency int NULL,
		--memory int NULL,
		--position_rating int NULL,
		--channel_state float NULL,
		--channel_flags float NULL,
		--channel_flags_manual float NULL,
		--channel_flags_auto float NULL,
		--confidence float NULL,
		--confidence_auto float NULL,
		--confidence_manual float NULL,
		--humidity_a int NULL,
		--humidity_b int NULL,
		--temperature_a int NULL,
		--temperature_b int NULL,
		--pressure_a float NULL,
		--pressure_b float NULL,
		--voc float NULL,
		--voc_a float NULL,
		--voc_b float NULL,
		--ozone1 float NULL,
		--analog_input float NULL,
		--[pm1.0] float NULL,
		--[pm1.0_a] float NULL,
		--[pm1.0_b] float NULL,
		--[pm2.5_a] float NULL,
		--[pm2.5_b] float NULL,
		--[pm2.5_alt] float NULL,
		--[pm2.5_alt_a] float NULL,
		--[pm2.5_alt_b] float NULL,
		--[pm10.0] float NULL,
		--[pm10.0_a] float NULL,
		--[pm10.0_b] float NULL,
		[pm2.5_10minute] float NULL,
		[calculated_AQI_10minute] AS [purple_air].[compute_aqi]([pm2.5_10minute]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_10minute] AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5_10minute]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5_10minute]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_10minute]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_10minute]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5_10minute]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5_10minute]) >= 0 THEN 'good'
			ELSE NULL END,
		--[pm2.5_10minute_a] float NULL,
		--[pm2.5_10minute_b] float NULL,
		[pm2.5_30minute] float NULL,
		[calculated_AQI_30minute] AS [purple_air].[compute_aqi]([pm2.5_30minute]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_30minute] AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5_30minute]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5_30minute]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_30minute]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_30minute]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5_30minute]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5_30minute]) >= 0 THEN 'good'
			ELSE NULL END,
		--[pm2.5_30minute_a] float NULL,
		--[pm2.5_30minute_b] float NULL,
		[pm2.5_60minute] float NULL,
		[calculated_AQI_60minute] AS [purple_air].[compute_aqi]([pm2.5_60minute]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_60minute] AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5_60minute]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5_60minute]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_60minute]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_60minute]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5_60minute]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5_60minute]) >= 0 THEN 'good'
			ELSE NULL END,
		--[pm2.5_60minute_a] float NULL,
		--[pm2.5_60minute_b] float NULL,
		[pm2.5_6hour] float NULL,
		[calculated_AQI_6hour] AS [purple_air].[compute_aqi]([pm2.5_6hour]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_6hour] AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5_6hour]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5_6hour]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_6hour]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_6hour]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5_6hour]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5_6hour]) >= 0 THEN 'good'
			ELSE NULL END,
		--[pm2.5_6hour_a] float NULL,
		--[pm2.5_6hour_b] float NULL,
		[pm2.5_24hour] float NULL,
		[calculated_AQI_24hour] AS [purple_air].[compute_aqi]([pm2.5_24hour]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_24hour] AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5_24hour]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5_24hour]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_24hour]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_24hour]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5_24hour]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5_24hour]) >= 0 THEN 'good'
			ELSE NULL END,
		--[pm2.5_24hour_a] float NULL,
		--[pm2.5_24hour_b] float NULL,
		[pm2.5_1week] float NULL,
		[calculated_AQI_1week] AS [purple_air].[compute_aqi]([pm2.5_1week]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_1week] AS CASE
			WHEN [purple_air].[compute_aqi]([pm2.5_1week]) > 300 THEN 'hazardous'
			WHEN [purple_air].[compute_aqi]([pm2.5_1week]) > 200 THEN 'very unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_1week]) > 150 THEN 'unhealthy'
			WHEN [purple_air].[compute_aqi]([pm2.5_1week]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [purple_air].[compute_aqi]([pm2.5_1week]) > 50 THEN 'moderate'
			WHEN [purple_air].[compute_aqi]([pm2.5_1week]) >= 0 THEN 'good'
			ELSE NULL END,
		--[pm2.5_1week_a] float NULL,
		--[pm2.5_1week_b] float NULL,
		--[scattering_coefficient] float NULL,
		--[scattering_coefficient_a] float NULL,
		--[scattering_coefficient_b] float NULL,
		--[deciviews] float NULL,
		--[deciviews_a] float NULL,
		--[deciviews_b] float NULL,
		--[visual_range] float NULL,
		--[visual_range_a] float NULL,
		--[visual_range_b] float NULL,
		--[0.3_um_count] float NULL,
		--[0.3_um_count_a] float NULL,
		--[0.3_um_count_b] float NULL,
		--[0.5_um_count] float NULL,
		--[0.5_um_count_a] float NULL,
		--[0.5_um_count_b] float NULL,
		--[1.0_um_count] float NULL,
		--[1.0_um_count_a] float NULL,
		--[1.0_um_count_b] float NULL,
		[2.5_um_count] float NULL
		--[2.5_um_count_a] float NULL,
		--[2.5_um_count_b] float NULL,
		--[5.0_um_count] float NULL,
		--[5.0_um_count_a] float NULL,
		--[5.0_um_count_b] float NULL,
		--[10.0_um_count] float NULL,
		--[10.0_um_count_a] float NULL,
		--[10.0_um_count_b] float NULL,
		--[pm1.0_cf_1] float NULL,
		--[pm1.0_cf_1_a] float NULL,
		--[pm1.0_cf_1_b] float NULL,
		--[pm1.0_atm] float NULL,
		--[pm1.0_atm_a] float NULL,
		--[pm1.0_atm_b] float NULL,
		--[pm2.5_atm] float NULL,
		--[pm2.5_atm_a] float NULL,
		--[pm2.5_atm_b] float NULL,
		--[pm2.5_cf_1] float NULL,
		--[pm2.5_cf_1_a] float NULL,
		--[pm2.5_cf_1_b] float NULL,
		--[pm10.0_atm] float NULL,
		--[pm10.0_atm_a] float NULL,
		--[pm10.0_atm_b] float NULL,
		--[pm10.0_cf_1] float NULL,
		--[pm10.0_cf_1_a] float NULL,
		--[pm10.0_cf_1_b] float NULL
	);
END
GO

-- Required configurations to run procedure
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO

-- Create extract_data procedure; this procedure will be run periodically
CREATE OR ALTER PROCEDURE [purple_air].[extract_data_noformat] @apikey nvarchar(40)
AS
BEGIN

-- Requires running set_sensor_table, set_aqdata_table, and compute_aqi_func
-- Need to enable OLE automation procedures to make an HTTP request call from a stored procedure

-- Variable declaration related to the Object.
DECLARE @token INT;
DECLARE @ret INT;

-- Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX);
DECLARE @contentType NVARCHAR(64);
DECLARE @fieldsData NVARCHAR(MAX);
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

IF OBJECT_ID(N'purple_air.Known_Sensor_IDs', N'U') IS NOT NULL
BEGIN
SELECT @sensorIDs = COALESCE(@sensorIDs + ',','') + CONVERT(nvarchar(10),id) FROM [purple_air].[Known_Sensor_IDs] WHERE [id] IS NOT NULL
SET @num_sensors = (SELECT COUNT(*) FROM [purple_air].[Known_Sensor_IDs] WHERE [id] IS NOT NULL)
END
ELSE
BEGIN
SET @sensorIDs = '131305,102884' -- Sample sensor IDs
SET @num_sensors = 2
END

IF OBJECT_ID(N'purple_air.Fields', N'U') IS NOT NULL
BEGIN
SELECT @fieldsData = COALESCE(@fieldsData + ',','') + field_name FROM purple_air.Fields WHERE include=1
PRINT 'FIELDS: ' + @fieldsData
END
ELSE
BEGIN
SET @fieldsData = -- CSV fields list
'name,temperature,pressure,pm2.5' -- Sample fields to include
--'name, model, location_type, latitude, longitude, altitude, last_seen, last_modified, date_created, confidence, humidity, temperature, pressure, pm2.5, pm2.5_atm, pm2.5_cf_1'
END
--SET @fieldsData = -- CSV fields list
--'name,temperature,pressure,pm2.5' -- Sample fields to include

SET @parameters = '?'
SET @parameters = @parameters + 'show_only=' + @sensorIDs
SET @parameters = @parameters + '&fields=' + @fieldsData

-- Define the URL
SET @url = 'https://api.purpleair.com/v1/sensors' + @parameters

PRINT @url;
SELECT @col_cost = SUM([point_cost]) FROM [purple_air].[Fields] WHERE [include]=1;
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
PRINT 'Response Status: ' + @status + ' (' + @statusText + ')'; -- Status 402: Payment Required
PRINT 'Response Text: ' + @responseText;

-- Close connection
EXEC @ret = sp_OADestroy @token;
IF @ret <> 0 RAISERROR('Unable to close HTTP connection.', 10, 1);

DECLARE @json_obj nvarchar(max)
SELECT @json_obj = [json_val] FROM @json

SELECT @fields = fields FROM OPENJSON(@json_obj) WITH (fields nvarchar(max) AS JSON);

-- PRINT @json_obj

IF (OBJECT_ID('tempdb..#Temp_Json') IS NOT NULL) DROP TABLE #Temp_Json;
CREATE TABLE [purple_air].#Temp_Json (
	json_val nvarchar(max)
)

--TRUNCATE TABLE purple_air.Temp_Json
INSERT INTO #Temp_Json SELECT * FROM @json
--INSERT INTO purple_air.Temp_Json EXEC sp_OAGetProperty @token, 'responseText'


-- Build dynamic SQL query

DECLARE @sql varchar(max);

DECLARE @NewLnChar AS CHAR(2) = CHAR(13) + CHAR(10);
DECLARE @TabChar AS CHAR(1) = CHAR(9);
DECLARE @field_name nvarchar(50);

DECLARE @i int;
DECLARE @length int = (SELECT COUNT(*) FROM OPENJSON(@fields));

DECLARE @fields_cs_list nvarchar(max);

SET @fields_cs_list = '[time_stamp], [data_time_stamp], [max_age]';
SET @i = 0;
WHILE @i < @length
BEGIN
	SET @fields_cs_list = @fields_cs_list + ', [' + JSON_VALUE(@fields,CONCAT('$[',@i,']')) + ']'
	SET @i = @i + 1
END

-- Dynamic SQL to INSERT INTO purple_air.AQ_Data
SET @sql = '
DECLARE @json_obj nvarchar(max);
SELECT @json_obj = [json_val] FROM #Temp_Json;
INSERT INTO [purple_air].[AQ_Data] ('
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
	IF @field_name = 'last_modified' OR @field_name = 'date_created' OR @field_name = 'last_seen'
		SET @sql = @sql + 'MIN(CASE JSON_VALUE(@json_obj,CONCAT(''$.fields['',d.[key],'']'')) WHEN ''' + @field_name + ''' THEN DATEADD(SS, CAST(d.value AS bigint), ''1970-01-01 00:00:00'') ELSE NULL END) AS [' + @field_name + ']'
	ELSE
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
SELECT ' + @fields_cs_list + ' FROM [purple_air].[AQ_Data];'

PRINT(@sql)

EXEC(@sql) -- Inserts into purple_air.AQ_Data

IF (OBJECT_ID('tempdb..#Temp_Json') IS NOT NULL) DROP TABLE #Temp_Json;

-- TRUNCATE TABLE [purple_air].[AQ_Data]

SELECT * FROM [purple_air].[AQ_Data]

END
GO