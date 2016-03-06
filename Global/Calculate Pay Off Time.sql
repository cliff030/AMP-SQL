IF OBJECT_ID('Custom_CalculatePayOffTime') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_CalculatePayOffTime
END
GO

CREATE FUNCTION [dbo].[Custom_CalculatePayOffTime](
	@AvgInterest decimal(11,9),
	@TotalDebt money,
	@MonthlyPaymentAmount money
) RETURNS int
AS
BEGIN

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