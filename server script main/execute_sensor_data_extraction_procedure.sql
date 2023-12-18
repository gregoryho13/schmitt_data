DROP PROCEDURE IF EXISTS dbo.execute_sensor_data_extraction
GO

CREATE PROCEDURE dbo.execute_sensor_data_extraction
AS BEGIN

-- API Key
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