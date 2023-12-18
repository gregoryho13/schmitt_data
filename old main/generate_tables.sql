USE master
GO

IF NOT EXISTS (
   SELECT name
   FROM sys.databases
   WHERE name = N'Sensor'
)
CREATE DATABASE [SensorsDB]
GO

--IF NOT EXISTS (
--   SELECT name
--   FROM sys.databases
--   WHERE name = N'#Name'
--)
--CREATE DATABASE [#Name]
--GO