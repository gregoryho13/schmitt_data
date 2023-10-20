EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'Ole Automation Procedures', 1
RECONFIGURE
GO

-- Variable declaration related to the Object.
DECLARE @token INT;
DECLARE @ret INT;

-- Variable declaration related to the Request.
DECLARE @url NVARCHAR(MAX);
DECLARE @authHeader NVARCHAR(64);
DECLARE @contentType NVARCHAR(64);
DECLARE @apiKey NVARCHAR(40);

-- Variable declaration related to the JSON string.
DECLARE @json AS TABLE(Json_Table NVARCHAR(MAX));

-- Set Authentications
--SET @authHeader = 'HTTP/1.1'
--SET @apiKey = @authHeader+'X-API-Key: A4C1A5B7-6715-11EE-A8AF-42010A80000A'
SET @contentType = 'application/json'
-- Set Authentications
SET @authHeader = '{"X-API-Key": "A4C1A5B7-6715-11EE-A8AF-42010A80000A"}'
-- SET @contentType = 'application/x-www-form-urlencoded';

-- Set api 
SET @apiKey = 'A4C1A5B7-6715-11EE-A8AF-42010A80000A'
--SET @apikey = 'A4C1A5B7-6715-11EE-A8AF-42010A80000A'

-- Define the URL
SET @url = 'https://api.purpleair.com/v1/sensors?fields=name'

-- This creates the new object.
EXEC @ret = sp_OACreate 'MSXML2.XMLHTTP', @token OUT;
IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);

-- This calls the necessary methods.
EXEC @ret = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';
EXEC @ret = sp_OAMethod @token, 'SetRequestHeader', NULL, 'X-API-Key', @apiKey;
--EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Authentication', @authHeader;
EXEC @ret = sp_OAMethod @token, 'setRequestHeader', NULL, 'Content-type', @contentType;
EXEC @ret = sp_OAMethod @token, 'send'

-- Grab the responseText property, and insert the JSON string into a table temporarily. 
-- This is very important, if you don't do this step you'll run into problems.
INSERT into @json (Json_Table) EXEC sp_OAGetProperty @token, 'responseText'

-- Select the JSON string from the Table we just inserted it into. You'll also be able to see the entire string with this statement.
SELECT * FROM @json