CREATE FUNCTION Custom_GetClientFee (
	@ClientID int
) RETURNS money
AS
BEGIN

DECLARE @FeeChangeDate date, @DateEntered date
SET @FeeChangeDate = '2011-11-01'

DECLARE @Fee money

SET @DateEntered = ( SELECT CONVERT(date,DateEntered) FROM Clients WHERE ClientID = @ClientID )

IF DATEDIFF(ss,@DateEntered,@FeeChangeDate) > 0
BEGIN
	SET @Fee = 10.00
END
ELSE
BEGIN
	SET @Fee = 20.00
END

RETURN @Fee

END