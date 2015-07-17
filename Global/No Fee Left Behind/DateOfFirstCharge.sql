CREATE FUNCTION Custom_DateOfFirstCharge (
	@ClientID int
) RETURNS date
AS
BEGIN
DECLARE @DateOfFirstCharge date

SET @DateOfFirstCharge = ( SELECT CONVERT(date,( SELECT TOP 1 DateReceived FROM Receipts WHERE ClientID = @ClientID )) )

RETURN @DateOfFirstCharge
END