IF OBJECT_ID('Custom_CompletedClientsByDateRange','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_CompletedClientsByDateRange
END
GO

CREATE PROCEDURE Custom_CompletedClientsByDateRange(
	@StartDate date,
	@EndDate date
)
AS
BEGIN

DECLARE @SelectClause nvarchar(200)
DECLARE @WhereClause nvarchar(200)
DECLARE @SqlString nvarchar(max)
DECLARE @ParmDefinition nvarchar(max)

SET @ParmDefinition = N'@StartDate date, @EndDate date'

SET @SelectClause = 'SELECT ClientID, WholeName, ClientStatus, CONVERT(date,DateClose) AS ''DateClose'' FROM Clients '

IF DB_NAME() = 'CSDATA8'
BEGIN
	SET @WhereClause = N'WHERE ClientStatus = ''COMPLETED'''
END
IF DB_NAME() = 'CSDATA8_INC'
BEGIN
	SET @WhereClause = N'WHERE ClientStatus = ''PROGRAM COMPLETED'''
END
IF DB_NAME() = 'CSDATA8_FFN'
BEGIN
	SET @WhereClause = N'WHERE ClientStatus = ''PROGRAM COMPLETED'''
END
ELSE
BEGIN
	SET @WhereClause = N'WHERE ClientStatus = ''COMPLETED'''
END

SET @WhereClause = @WhereClause + ' AND CONVERT(date,DateClose) >= @StartDate AND CONVERT(date,DateClose) <= @EndDate ORDER BY ''DateClose'' DESC, ClientID ASC'

SET @SqlString = @SelectClause + @WhereClause

EXEC sp_executesql @SqlString, @ParmDefinition, @StartDate, @EndDate

END
GO