IF OBJECT_ID('Custom_ClientAccumulatedFundsByDate') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_ClientAccumulatedFundsByDate
END
GO

CREATE PROCEDURE Custom_ClientAccumulatedFundsByDate(
	@ClientID int,
	@EndDate date	
)
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SELECT CAST(SUM(credit-debits) AS decimal(9,2)) AS 'AccumulatedFunds'
	FROM Custom_ClientTransactions
	WHERE ClientID = @ClientID
	AND CONVERT(date,postdate) <= @EndDate 
END