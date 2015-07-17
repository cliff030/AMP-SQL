ALTER FUNCTION Custom_ReturnClientAccumulatedFunds(
	@ClientID int	
) RETURNS decimal(9,2)
AS
BEGIN
	RETURN ( 
		SELECT CAST(SUM(credit-debits) AS decimal(9,2)) AS 'AccumulatedFunds'
		FROM Custom_ClientTransactions
		WHERE ClientID = @ClientID
	)
END