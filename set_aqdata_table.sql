-- Requires dbo.compute_aqi function
--DROP TABLE AQ_DATA;

IF OBJECT_ID(N'AQ_Data', N'U') IS NULL
BEGIN
	CREATE TABLE AQ_Data (
		data_time_stamp datetime NOT NULL,
		time_stamp datetime NULL,
		sensor_index bigint NOT NULL,
		name nvarchar(100) NULL,
		latitude float NULL,
		longitude float NULL,
		altitude float NULL,
		temperature int NULL,
		pressure float NULL,
		humidity int NULL,
		[pm2.5] float NULL,
		calculated_AQI AS [dbo].[compute_aqi]([pm2.5]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		calculated_AQI_rating AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5]) >= 0 THEN 'good'
			ELSE NULL END,
		max_age int NULL,
		api_version varchar(25) NULL,
		last_modified datetime NULL,
		date_created datetime NULL,
		last_seen datetime NULL,
		private tinyint NULL,
		is_owner float NULL,
		icon int NULL,
		location_type tinyint NULL,
		model nvarchar(100) NULL,
		hardware varchar(100) NULL,
		led_brightness float NULL,
		firmware_version varchar(25) NULL,
		firmware_upgrade varchar(25) NULL,
		rssi int NULL,
		uptime int NULL,
		pa_latency int NULL,
		memory int NULL,
		position_rating int NULL,
		channel_state float NULL,
		channel_flags float NULL,
		channel_flags_manual float NULL,
		channel_flags_auto float NULL,
		confidence float NULL,
		confidence_auto float NULL,
		confidence_manual float NULL,
		humidity_a int NULL,
		humidity_b int NULL,
		temperature_a int NULL,
		temperature_b int NULL,
		pressure_a float NULL,
		pressure_b float NULL,
		voc float NULL,
		voc_a float NULL,
		voc_b float NULL,
		ozone1 float NULL,
		analog_input float NULL,
		[pm1.0] float NULL,
		[pm1.0_a] float NULL,
		[pm1.0_b] float NULL,
		[pm2.5_a] float NULL,
		[pm2.5_b] float NULL,
		[pm2.5_alt] float NULL,
		[pm2.5_alt_a] float NULL,
		[pm2.5_alt_b] float NULL,
		[pm10.0] float NULL,
		[pm10.0_a] float NULL,
		[pm10.0_b] float NULL,
		[pm2.5_10minute] float NULL,
		[calculated_AQI_10minute] AS [dbo].[compute_aqi]([pm2.5_10minute]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_10minute] AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5_10minute]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5_10minute]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_10minute]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_10minute]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5_10minute]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5_10minute]) >= 0 THEN 'good'
			ELSE NULL END,
		[pm2.5_10minute_a] float NULL,
		[pm2.5_10minute_b] float NULL,
		[pm2.5_30minute] float NULL,
		[calculated_AQI_30minute] AS [dbo].[compute_aqi]([pm2.5_30minute]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_30minute] AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5_30minute]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5_30minute]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_30minute]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_30minute]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5_30minute]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5_30minute]) >= 0 THEN 'good'
			ELSE NULL END,
		[pm2.5_30minute_a] float NULL,
		[pm2.5_30minute_b] float NULL,
		[pm2.5_60minute] float NULL,
		[calculated_AQI_60minute] AS [dbo].[compute_aqi]([pm2.5_60minute]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_60minute] AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5_60minute]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5_60minute]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_60minute]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_60minute]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5_60minute]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5_60minute]) >= 0 THEN 'good'
			ELSE NULL END,
		[pm2.5_60minute_a] float NULL,
		[pm2.5_60minute_b] float NULL,
		[pm2.5_6hour] float NULL,
		[calculated_AQI_6hour] AS [dbo].[compute_aqi]([pm2.5_6hour]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_6hour] AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5_6hour]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5_6hour]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_6hour]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_6hour]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5_6hour]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5_6hour]) >= 0 THEN 'good'
			ELSE NULL END,
		[pm2.5_6hour_a] float NULL,
		[pm2.5_6hour_b] float NULL,
		[pm2.5_24hour] float NULL,
		[calculated_AQI_24hour] AS [dbo].[compute_aqi]([pm2.5_24hour]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_24hour] AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5_24hour]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5_24hour]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_24hour]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_24hour]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5_24hour]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5_24hour]) >= 0 THEN 'good'
			ELSE NULL END,
		[pm2.5_24hour_a] float NULL,
		[pm2.5_24hour_b] float NULL,
		[pm2.5_1week] float NULL,
		[calculated_AQI_1week] AS [dbo].[compute_aqi]([pm2.5_1week]), -- From https://community.purpleair.com/t/how-to-calculate-the-us-epa-pm2-5-aqi/877
		[calculated_AQI_rating_1week] AS CASE
			WHEN [dbo].[compute_aqi]([pm2.5_1week]) > 300 THEN 'hazardous'
			WHEN [dbo].[compute_aqi]([pm2.5_1week]) > 200 THEN 'very unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_1week]) > 150 THEN 'unhealthy'
			WHEN [dbo].[compute_aqi]([pm2.5_1week]) > 100 THEN 'unhealthy for sensitive groups'
			WHEN [dbo].[compute_aqi]([pm2.5_1week]) > 50 THEN 'moderate'
			WHEN [dbo].[compute_aqi]([pm2.5_1week]) >= 0 THEN 'good'
			ELSE NULL END,
		[pm2.5_1week_a] float NULL,
		[pm2.5_1week_b] float NULL,
		[scattering_coefficient] float NULL,
		[scattering_coefficient_a] float NULL,
		[scattering_coefficient_b] float NULL,
		[deciviews] float NULL,
		[deciviews_a] float NULL,
		[deciviews_b] float NULL,
		[visual_range] float NULL,
		[visual_range_a] float NULL,
		[visual_range_b] float NULL,
		[0.3_um_count] float NULL,
		[0.3_um_count_a] float NULL,
		[0.3_um_count_b] float NULL,
		[0.5_um_count] float NULL,
		[0.5_um_count_a] float NULL,
		[0.5_um_count_b] float NULL,
		[1.0_um_count] float NULL,
		[1.0_um_count_a] float NULL,
		[1.0_um_count_b] float NULL,
		[2.5_um_count] float NULL,
		[2.5_um_count_a] float NULL,
		[2.5_um_count_b] float NULL,
		[5.0_um_count] float NULL,
		[5.0_um_count_a] float NULL,
		[5.0_um_count_b] float NULL,
		[10.0_um_count] float NULL,
		[10.0_um_count_a] float NULL,
		[10.0_um_count_b] float NULL,
		[pm1.0_cf_1] float NULL,
		[pm1.0_cf_1_a] float NULL,
		[pm1.0_cf_1_b] float NULL,
		[pm1.0_atm] float NULL,
		[pm1.0_atm_a] float NULL,
		[pm1.0_atm_b] float NULL,
		[pm2.5_atm] float NULL,
		[pm2.5_atm_a] float NULL,
		[pm2.5_atm_b] float NULL,
		[pm2.5_cf_1] float NULL,
		[pm2.5_cf_1_a] float NULL,
		[pm2.5_cf_1_b] float NULL,
		[pm10.0_atm] float NULL,
		[pm10.0_atm_a] float NULL,
		[pm10.0_atm_b] float NULL,
		[pm10.0_cf_1] float NULL,
		[pm10.0_cf_1_a] float NULL,
		[pm10.0_cf_1_b] float NULL
	);
END

--SELECT * FROM AQ_Data;