IF OBJECT_ID('Custom_LeadAnalysis_GetNumberOfPayments', 'FN') IS NOT NULL
BEGIN
	DROP FUNCTION dbo.Custom_LeadAnalysis_GetNumberOfPayments
END
GO

CREATE FUNCTION dbo.Custom_LeadAnalysis_GetNumberOfPayments(
	@ClientID int
) 
RETURNS int
AS
BEGIN
	DECLARE @NumMonths int

	DECLARE @Custom_LeadDebts table( Name nvarchar(250), OrigDebt money, OrigMonthly money, InitialAPR decimal(11,9))
	
	INSERT INTO @Custom_LeadDebts (Name, OrigDebt, OrigMonthly, InitialAPR) 
	(
	SELECT c.Name AS 'Creditor Name', lcc.OrigDebt AS 'Balance', lcc.OrigMonthly AS 'Monthly Payment', lcc.InitialAPR AS 'Interest Rate'
	FROM LeadClientCred AS lcc
	INNER JOIN Creditors AS c
		ON lcc.CreditorID = c.CreditorID
	WHERE lcc.ClientID = @ClientID
	AND lcc.CreditorID <> 0
	AND lcc.CreditorID <> 3
	)
	
	DECLARE @TotalDebt money, @AvgInterest decimal(11,9), @MonthlyPaymentAmount money
	SET @TotalDebt = ( SELECT SUM(OrigDebt) FROM @Custom_LeadDebts )
	SET @AvgInterest = ( SELECT AVG(InitialAPR) FROM @Custom_LeadDebts )
	SET @MonthlyPaymentAmount = ( SELECT SUM(OrigMonthly) FROM @Custom_LeadDebts )
	
	SET @NumMonths = ( SELECT dbo.Custom_CalculatePayOffTime(@AvgInterest, @TotalDebt, @MonthlyPaymentAmount) )
	
	RETURN @NumMonths
END
GO