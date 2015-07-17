IF OBJECT_ID('Custom_ConvertedLeadsByYear') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_ConvertedLeadsByYear
END
GO

CREATE PROCEDURE Custom_ConvertedLeadsByYear(
	@CurDate date
)
AS
BEGIN
DECLARE @EndOfMonth date, @StartOfMonth date
DECLARE @LastYearEndOfMonth date, @LastYearStartOfMonth date

DECLARE @ConvertedLeadsThisYear int, @ConvertedLeadsLastYear int

IF DAY(DATEADD(day,1,@CurDate)) = 1
BEGIN
	SET @EndOfMonth = @CurDate
END
ELSE
BEGIN
	SET @EndOfMonth = ( SELECT DATEADD(day,-1,dbo.Custom_GetNextMonth(@CurDate)) )
END

SET @StartOfMonth = ( SELECT dbo.Custom_StartOfMonth(@EndOfMonth) )

SET @LastYearEndOfMonth = ( SELECT DATEADD(year,-1,@EndOfMonth) )
SET @LastYearStartOfMonth = ( SELECT DATEADD(year,-1,@StartOfMonth) )

SET @ConvertedLeadsThisYear = ( 
	SELECT COUNT(lc.ClientID)
	FROM LeadClient AS lc 
	WHERE lc.Exported = 1
	AND CONVERT(date,lc.ExportedDate) >= @StartOfMonth
	AND CONVERT(date,lc.ExportedDate) <= @EndOfMonth
)

SET @ConvertedLeadsLastYear = (
	SELECT COUNT(lc.ClientID)
	FROM LeadClient AS lc 
	WHERE lc.Exported = 1
	AND CONVERT(date,lc.ExportedDate) >= @LastYearStartOfMonth
	AND CONVERT(date,lc.ExportedDate) <= @LastYearEndOfMonth
)

SELECT @ConvertedLeadsThisYear AS 'ConvertedLeadsThisYear', @ConvertedLeadsLastYear AS 'ConvertedLeadsLastYear', @StartOfMonth AS 'ThisYear', @LastYearStartOfMonth AS 'LastYear'

END
GO