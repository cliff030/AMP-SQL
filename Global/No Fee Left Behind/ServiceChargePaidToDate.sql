CREATE FUNCTION Custom_ServiceChargePaidToDate (
	@ClientID int
) RETURNS money
AS
BEGIN
RETURN ( SELECT SUM(Amount) FROM Payments WHERE ClientID = @ClientID AND CreditorID = 0 )
END