ALTER PROCEDURE Custom_ClientAccumulatedFunds(
	@ClientID int	
)
AS
BEGIN
	SELECT CAST(SUM(credit-debits) AS decimal(9,2)) AS 'AccumulatedFunds'
	FROM Custom_ClientTransactions
	--SELECT	c.UnusedRealAccumulatedAmount_CALCULATED + c.UnusedVirtualAccumulatedAmount_CALCULATED AS 'AccumulatedFunds'
	--FROM	Clients c (nolock)
	WHERE ClientID = @ClientID
END