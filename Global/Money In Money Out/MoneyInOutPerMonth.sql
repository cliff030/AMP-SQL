IF OBJECT_ID('Custom_MoneyInOutPerMonth') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_MoneyInOutPerMonth
END
GO

CREATE FUNCTION Custom_MoneyInOutPerMonth(
	@StartDate date,
	@CreditorID int
) RETURNS @MoneyInOut table( MoneyOut money, MoneyIn money )
AS
BEGIN
DECLARE @EndDate date
SET @EndDate = ( SELECT CONVERT(date,dbo.Custom_GetNextMonth(@StartDate)) )

DECLARE @MoneyOut money, @MoneyIn money

SET @MoneyOut = ( SELECT ISNULL(SUM(ReceiptAmount),0) AS 'MoneyOut' FROM Receipts
WHERE PaymentType = 'ADVANCE'
AND CONVERT(date,DateEntered) >= @StartDate
AND CONVERT(date,DateEntered) <= @EndDate )

SET @MoneyIn = ( SELECT ISNULL(SUM(Amount),0) AS 'MoneyIn' FROM Checks
WHERE CreditorID = @CreditorID
AND CONVERT(date,DateEntered) >= @StartDate
AND CONVERT(date,DateEntered) <= @EndDate )

INSERT INTO @MoneyInOut ( MoneyOut, MoneyIn ) VALUES ( @MoneyOut, @MoneyIn )

RETURN
END
GO