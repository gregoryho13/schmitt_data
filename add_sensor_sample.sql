USE [PurpleAir_Data_NoFormat]
GO
INSERT INTO [purple_air].Known_Sensor_IDs VALUES (
	12345, 'test' 
)

DELETE FROM purple_air.Known_Sensor_IDs WHERE id=12345;