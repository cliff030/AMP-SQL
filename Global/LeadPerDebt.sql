IF OBJECT_ID('Custom_LeadPerDebt','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_LeadPerDebt
END
GO

CREATE FUNCTION Custom_LeadPerDebt(
	@LeadClientID int,
	@Percentage decimal(3,2)
) RETURNS money
BEGIN

DECLARE @amount money

SET @amount = ( select isnull(cast(cast(round(SUM(origdebt) * @Percentage,2) as money)as nvarchar),'') from dbo.DebtorProgramDebt(@LeadClientID,'LeadClientcred'))

RETURN @amount

END
GO