IF OBJECT_ID(N'Temp_Json', N'U') IS NULL
BEGIN
CREATE TABLE Temp_Json (
json nvarchar(MAX) NOT NULL
);
END

DECLARE @fields nvarchar(max)
DECLARE @json nvarchar(max);

SELECT * FROM Temp_Json

SELECT @json = [json] FROM Temp_Json

--DECLARE @test TABLE (
--	time datetime,
--	data_Time datetime,
--	max_age float,
--	data nvarchar(max)
--);

PRINT @json

SELECT @fields = fields FROM OPENJSON(@json) WITH (fields nvarchar(max) as JSON)

PRINT @fields

--INSERT INTO @test
SELECT
	DATEADD(SS, time_stamp, '1970-01-01 00:00:00') AS time_stamp,
	DATEADD(SS, data_time_stamp, '1970-01-01 00:00:00') AS data_time_stamp,
	max_age,
	--a.fields AS 'fields_list',
	--fields_data.value AS 'values_list',
	--d.[key] AS 'field_index',
	--d.value AS 'field_value',
	--JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) AS 'field_name',
	MIN(CASE JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) WHEN 'sensor_index' THEN d.value ELSE NULL END) AS sensor_index,
	MIN(CASE JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) WHEN 'name' THEN d.value ELSE NULL END) AS sensor_name,
	MIN(CASE JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) WHEN 'model' THEN d.value ELSE NULL END) AS model,
	MIN(CASE JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) WHEN 'temperature' THEN d.value ELSE NULL END) AS temperature,
	MIN(CASE JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) WHEN 'pressure' THEN d.value ELSE NULL END) AS pressure,
	MIN(CASE JSON_VALUE(@json,CONCAT('$.fields[',d.[key],']')) WHEN 'pm2.5' THEN d.value ELSE NULL END) AS [pm2.5]
FROM OPENJSON(@json)
WITH (
	time_stamp bigint '$.time_stamp',
	data_time_stamp bigint '$.data_time_stamp',
	max_age float '$.max_age',
	fields nvarchar(max) AS JSON,
	data nvarchar(max) AS JSON
) a
CROSS APPLY OPENJSON(@json, '$.data') as fields_data
CROSS APPLY OPENJSON(fields_data.value) as d
GROUP BY time_stamp, data_time_stamp, max_age, fields_data.value;