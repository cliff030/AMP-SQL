IF OBJECT_ID('Custom_GetMonthWeekNumber','F') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_GetMonthWeekNumber
END
GO

CREATE FUNCTION Custom_GetMonthWeekNumber(
	@Date date
) RETURNS int
AS
BEGIN
	DECLARE @StartOfMonth date
	SET @StartOfMonth = CONVERT(date,dbo.Custom_StartOfMonth(@Date))
	
	DECLARE @StartOfMonthWkNo int, @WkNo int, @MonthWkNo int
	
	SET @StartOfMonthWkNo = DATEPART(wk,@StartOfMonth)
	SET @WkNo = DATEPART(wk,@Date)
	
	IF @StartOfMonthWkNo = @WkNo
	BEGIN
		SET @MonthWkNo = 1
	END
	ELSE
	BEGIN
		SET @MonthWkNo = @WkNo - @StartOfMonthWkNo
	END
	
	RETURN @MonthWkNo
END
GO