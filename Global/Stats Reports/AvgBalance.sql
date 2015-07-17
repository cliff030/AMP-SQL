-- Average balance of debt
-- Returns the average of the original balance for all client accounts

ALTER FUNCTION dbo.Custom_AvgBalance(
	@StartDate date,
	@EndDate date
) RETURNS money
AS
BEGIN
	DECLARE @ClientBalances table ( Balance money )
	
	INSERT INTO @ClientBalances ( Balance )
	(
		SELECT CAST(SUM(cr.OrigDebt) AS money) 
		FROM ClientCred AS cr
		INNER JOIN Clients AS c
			ON c.ClientID = cr.ClientID
		WHERE CONVERT(date,c.DateEntered) >= @StartDate
		AND CONVERT(date,c.DateEntered) <= @EndDate
		GROUP BY cr.ClientID
	)

	RETURN (SELECT CAST(ISNULL(AVG(Balance),0) AS money) FROM @ClientBalances )
END