DROP PROCEDURE IF EXISTS dbo.execute_data_extraction
GO
CREATE PROCEDURE dbo.execute_data_extraction
AS BEGIN

-- Bowie High School
EXEC sensor_data_extraction @sensor_index='102840', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- Charles Flowers HS
EXEC sensor_data_extraction @sensor_index='102884', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- ERHS lower
EXEC sensor_data_extraction @sensor_index='102990', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- International HS at Largo
EXEC sensor_data_extraction @sensor_index='102830', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- Oxon Hill HS
EXEC sensor_data_extraction @sensor_index='104790', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- PGCPS_Schmidt_CenterBldg
EXEC sensor_data_extraction @sensor_index='102898', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- Potomac High
EXEC sensor_data_extraction @sensor_index='131305', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';

-- William S Schmidt
EXEC sensor_data_extraction @sensor_index='134488', @apiKey='A4C1A5B7-6715-11EE-A8AF-42010A80000A';


END 
