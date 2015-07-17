-- Cancels90Days
-- Returns the number of clients who cancel within 90 days

ALTER FUNCTION dbo.Custom_Cancels90Days(
	@StartDate date,
	@EndDate date
) RETURNS int
AS
BEGIN
RETURN (SELECT COUNT(*) FROM Clients WHERE DATEDIFF(day,DateStart,DateClose) <= 90 AND CONVERT(date,DateEntered) >= @StartDate AND CONVERT(date,DateEntered) <= @EndDate)
END