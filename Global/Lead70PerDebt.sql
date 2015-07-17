IF OBJECT_ID('Custom_Lead70PerDebt','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_Lead70PerDebt
END
GO

CREATE FUNCTION Custom_Lead70PerDebt(
	@LeadClientID int
) RETURNS money
BEGIN

DECLARE @amount money

SET @amount = ( select isnull(cast(cast(round(SUM(origdebt) * .70,2) as money)as nvarchar),'') from dbo.DebtorProgramDebt(@LeadClientID,'LeadClientcred'))

RETURN @amount

END
GO