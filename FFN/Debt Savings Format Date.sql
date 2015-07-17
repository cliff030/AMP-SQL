IF OBJECT_ID('Custom_DebtSavingsFormatDate','FN') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_DebtSavingsFormatDate
END
GO

CREATE FUNCTION Custom_DebtSavingsFormatDate(
	@PayOffTime int
) RETURNS nvarchar(max)
AS
BEGIN

DECLARE @OutputText nvarchar(max)

DECLARE @YearDate int, @YearDateRemainder int

IF @PayOffTime > 12
BEGIN
	SET @YearDate = @PayOffTime / 12
	SET @YearDateRemainder = @PayOffTime % 12
	
	IF @YearDateRemainder = 0
	BEGIN
		SET @OutputText = CONVERT(nvarchar,@YearDate) + ' years'
	END
	ELSE
	BEGIN
		DECLARE @YearMonths int, @TmpYearMonths int
		SET @TmpYearMonths = @YearDate * 12
		SET @YearMonths = @PayOffTime - @TmpYearMonths
	
		SET @OutputText = CONVERT(nvarchar,@YearDate) + ' years ' + CONVERT(nvarchar,@YearMonths) + ' months'
	END
END
ELSE
BEGIN
	SET @OutputText = CONVERT(nvarchar,@PayOffTime) + ' months'
END

RETURN @OutputText

END
GO