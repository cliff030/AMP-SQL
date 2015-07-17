-- AvgMonthsInProgram
-- Returns the average number of months clients are in the program

ALTER FUNCTION dbo.Custom_AvgMonthsInProgram(
	@StartDate date,
	@EndDate date
) RETURNS int
AS
BEGIN
	RETURN (SELECT ISNULL(CEILING(AVG(CAST(DATEDIFF(month,DateStart,DateClose) AS float))),0) FROM Clients where DateClose IS NOT NULL AND DATEDIFF(month,DateStart,DateClose) > 3 AND CONVERT(date,DateEntered) >= @StartDate AND CONVERT(date,DateEntered) <= @EndDate)
END