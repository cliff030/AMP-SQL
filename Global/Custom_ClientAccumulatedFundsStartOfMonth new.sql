ALTER FUNCTION dbo.Custom_ClientAccumulatedFundsStartOfMonth(
	@ClientID int	
) RETURNS money
AS
BEGIN
DECLARE @AccumulatedFunds money

Declare @StartDate as Date
DECLARE @Date date
set @Date = GETDATE()

--set @StartDate = dateadd(MONTH,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
set @StartDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@Date))-1),DATEADD(mm,0,@Date)),101)

IF DATEPART(Month,DATEADD(Day,-15,@Date)) <> DATEPART(Month,@StartDate)
BEGIN
	SET @StartDate = DATEADD(Month,-1,CONVERT(date,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1)))
END

IF DATEPART(Year,DATEADD(Month,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))) <> DATEPART(Year,@StartDate)
BEGIN
	SET @StartDate = DATEADD(Month,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
END

SET @AccumulatedFunds = (SELECT CAST(ISNULL(SUM(credit-debits),0) AS decimal(9,2)) AS 'AccumulatedFunds'
FROM Custom_ClientTransactions
WHERE ClientID = @ClientID
AND CONVERT(date,postdate) < @StartDate
)

RETURN @AccumulatedFunds
END