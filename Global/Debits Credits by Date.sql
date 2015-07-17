IF OBJECT_ID('Custom_DebitsCreditsByDate') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_DebitsCreditsByDate
END
GO

CREATE PROCEDURE Custom_DebitsCreditsByDate(
	@ClientID int,
	@StartDate date,
	@EndDate date
) 
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @StartOfMonthFunds money

SET @StartOfMonthFunds = (SELECT dbo.Custom_ClientAccumulatedFundsStartOfMonthByDate(@ClientID,@StartDate))

IF @StartOfMonthFunds IS NULL
BEGIN
	SET @StartofMonthFunds = 0
END

SELECT *, @StartOfMonthFunds AS 'starting_balance' FROM Custom_ClientTransactions
WHERE ClientID = @ClientID
AND (CONVERT(date,postdate) >= @StartDate AND CONVERT(date,postdate) <= @EndDate)
ORDER BY postdate, sortorder
END
GO