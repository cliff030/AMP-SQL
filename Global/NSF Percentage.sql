IF OBJECT_ID('Custom_NSFPercentage','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_NSFPercentage
END
GO

CREATE PROCEDURE Custom_NSFPercentage(
	@StartDate date,
	@EndDate date
)
AS
BEGIN

DECLARE @TotalTransactions float
DECLARE @TotalReturn int, @TotalHardReturn int, @TotalSoftReturn int
DECLARE @PercentReturn float, @PercentHardReturn float, @PercentSoftreturn float

SET @TotalTransactions = ( SELECT CONVERT(float,COUNT(*)) FROM Receipts WHERE CONVERT(date,DateReceived) >= @StartDate AND CONVERT(date,DateReceived) <= @EndDate )

SET @TotalReturn = ( SELECT COUNT(*) FROM Receipts WHERE NSF = 1 AND CONVERT(date,DateReceived) >= @StartDate AND CONVERT(date,DateReceived) <= @EndDate )
SET @TotalHardReturn = ( SELECT COUNT(*) FROM Receipts WHERE NSF = 1 AND NSFReason IN ( 'INELIGIBLE', 'NOT AUTHORIZED', 'PAYMENT STOPPED', 'PYMT REFUS', 'REVOKED', 'STOP PAY', 'UNAUTH CORP' ) AND CONVERT(date,DateReceived) >= @StartDate AND CONVERT(date,DateReceived) <= @EndDate )
SET @TotalSoftReturn = ( SELECT COUNT(*) FROM Receipts WHERE NSF = 1 AND NSFReason NOT IN ( 'INELIGIBLE', 'NOT AUTHORIZED', 'PAYMENT STOPPED', 'PYMT REFUS', 'REVOKED', 'STOP PAY', 'UNAUTH CORP' ) AND CONVERT(date,DateReceived) >= @StartDate AND CONVERT(date,DateReceived) <= @EndDate )

SET @PercentReturn = ( SELECT CONVERT(float,@TotalReturn) / @TotalTransactions )
SET @PercentHardReturn = ( SELECT CONVERT(float,@TotalHardReturn) / @TotalTransactions )
SET @PercentSoftReturn = ( SELECT CONVERT(float,@TotalSoftReturn) / @TotalTransactions )

SELECT @TotalTransactions AS 'TotalTransactions', @TotalReturn AS 'TotalReturn', @PercentReturn AS 'PercentReturn', @TotalHardReturn AS 'TotalHardReturn', @PercentHardReturn AS 'PercentHardReturn', @TotalSoftReturn AS 'TotalSoftReturn', @PercentSoftReturn AS 'PercentSoftReturn'

END
GO