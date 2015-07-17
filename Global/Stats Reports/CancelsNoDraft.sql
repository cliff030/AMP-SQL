-- CancelsNoDraft
-- Returns the number of cancelled clients who were never drafted

ALTER FUNCTION Custom_CancelsNoDraft(
	@StartDate date,
	@EndDate date
) RETURNS int
AS
BEGIN
	RETURN (SELECT COUNT(*) FROM Clients
	WHERE ClientID NOT IN (SELECT ClientID FROM Payments UNION SELECT ClientID FROM Receipts)
	AND ClientStatus = 'CANCEL'
	AND CONVERT(date,DateEntered) >= @StartDate
	AND CONVERT(date,DateEntered) <= @EndDate)
END