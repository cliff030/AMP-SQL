-- CancelsWithRefund
-- Returns the number of clients who cancelled and were refunded

ALTER FUNCTION Custom_CancelsWithRefund(
	@StartDate date,
	@EndDate date
)
RETURNS int
AS
BEGIN
	DECLARE @NumCancelsWithRefund int

	SET @NumCancelsWithRefund = (SELECT COUNT(DISTINCT c.ClientID)
	FROM Clients AS c 
	INNER JOIN Payments AS p
		ON p.ClientID = c.ClientID
	WHERE c.ClientStatus = 'CANCEL'
	AND p.Description = 'CLIENT REFUND'
	AND CONVERT(date,c.DateEntered) >= @StartDate
	AND CONVERT(date,c.DateEntered) <= @EndDate
	)
	
	RETURN @NumCancelsWithRefund
END