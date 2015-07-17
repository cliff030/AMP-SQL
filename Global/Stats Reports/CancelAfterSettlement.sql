-- CancelAfterSettlement
-- Returns the number of clients who cancelled after making a settlement

ALTER FUNCTION Custom_CancelAfterSettlement(
	@StartDate date,
	@EndDate date
)
RETURNS int
AS
BEGIN
	DECLARE @CancelCount int
	
	SET @CancelCount = ( 
		SELECT COUNT(DISTINCT c.ClientID)
		FROM Clients AS c
		INNER JOIN ClientCred AS cr
			ON c.ClientID = cr.ClientID
		WHERE c.ClientStatus = 'CANCEL'
		AND (
			cr.AccountStatus = 'SETTLED' 
			OR cr.AccountStatus = 'PAID IN FULL'
		)
		AND CONVERT(date,c.DateEntered) >= @StartDate AND CONVERT(date,c.DateEntered) <= @EndDate
	)
	
	RETURN @CancelCount
END