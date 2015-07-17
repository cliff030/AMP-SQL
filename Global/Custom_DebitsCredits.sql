IF OBJECT_ID('Custom_DebitsCredits') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_DebitsCredits
END
GO

CREATE PROCEDURE Custom_DebitsCredits(
	@ClientID int
) 
AS
BEGIN
Declare @StartDate as Date, @EndDate as Date, @Date date

set @Date = GETDATE()

--SET @StartDate = dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1)
set @StartDate = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,@Date))-1),DATEADD(mm,0,@Date)),101)

IF DATEPART(Month,DATEADD(Day,-15,@Date)) <> DATEPART(Month,@StartDate)
BEGIN
	SET @StartDate = DATEADD(Month,-1,CONVERT(date,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1)))
END

IF DATEPART(Year,DATEADD(Month,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))) <> DATEPART(Year,@StartDate)
BEGIN
	SET @StartDate = DATEADD(Month,-1,dbo.DateSerial(datepart(year,@Date),DATEPART(month,@Date),1))
END

SET @EndDate = DATEADD(Month,1,@StartDate)


IF @EndDate < @Date
BEGIN
	SET @EndDate = DATEADD(Day,1,@Date)
END

DECLARE @StartOfMonthFunds money

SET @StartOfMonthFunds = (SELECT dbo.Custom_ClientAccumulatedFundsStartOfMonth(@ClientID))

IF @StartOfMonthFunds IS NULL
BEGIN
	SET @StartofMonthFunds = 0
END

SELECT *, @StartOfMonthFunds AS 'starting_balance' FROM Custom_ClientTransactions
WHERE ClientID = @ClientID
AND (CONVERT(date,postdate) >= @StartDate AND CONVERT(date,postdate) <= @EndDate)
ORDER BY postdate, sortorder
END
GO