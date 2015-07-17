IF OBJECT_ID('Custom_ClientAccumulatedFundsStartOfMonthByDate','FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.Custom_ClientAccumulatedFundsStartOfMonthByDate
END
GO

CREATE FUNCTION dbo.Custom_ClientAccumulatedFundsStartOfMonthByDate(
	@ClientID int,
	@StartDate date
) RETURNS money
AS
BEGIN
DECLARE @AccumulatedFunds money

SET @AccumulatedFunds = (SELECT CAST(ISNULL(SUM(credit-debits),0) AS decimal(9,2)) AS 'AccumulatedFunds'
FROM Custom_ClientTransactions
WHERE ClientID = @ClientID
AND CONVERT(date,postdate) < @StartDate
)

RETURN @AccumulatedFunds
END
GO