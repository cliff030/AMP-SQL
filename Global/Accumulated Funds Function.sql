IF OBJECT_ID('Custom_ClientAccumulatedFundsFunc', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_ClientAccumulatedFundsFunc
END
GO

CREATE FUNCTION Custom_ClientAccumulatedFundsFunc(
	@ClientID int	
)
RETURNS money
BEGIN
	DECLARE @AccumulatedFunds AS money

	SET @AccumulatedFunds = ( SELECT CAST(SUM(credit-debits) AS decimal(9,2)) AS 'AccumulatedFunds'
							FROM Custom_ClientTransactions
							WHERE ClientID = @ClientID
							)
							
	RETURN @AccumulatedFunds
END
GO