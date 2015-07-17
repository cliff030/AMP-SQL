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
	
	DECLARE @mnthlyI float, @step1 float, @PV float, @step2 float, @step3 float, @NumMonths int
	SET @mnthlyI = @AvgInterest / 12
	SET @step1 = 1 + @mnthlyI
	SET @PV = @mnthlyI * @TotalDebt 
	SET @step2 = @PV / @MonthlyPaymentAmount
	SET @step2 = @step2 - 1
	SET @step2 = @step2 * -1
	
	IF @step2 > 0
	BEGIN
		SET @step3 = LOG(@step2) / LOG(@step1)
		SET @NumMonths = CEILING(-1 * @step3)
	END
	ELSE
	BEGIN
		SET @NumMonths = 0
	END
	
	RETURN @NumMonths
END
GO