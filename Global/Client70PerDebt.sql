IF OBJECT_ID('Custom_Client70PerDebt','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_Client70PerDebt
END
GO

CREATE FUNCTION Custom_Client70PerDebt(
	@ClientID int
) RETURNS money
BEGIN

DECLARE @amount money

SET @amount = ( select isnull(cast(cast(round(SUM(origdebt) * .70,2) as money)as nvarchar),'') from dbo.DebtorProgramDebt(@ClientID,'Clientcred'))

RETURN @amount

END
GO