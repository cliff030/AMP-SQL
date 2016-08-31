IF OBJECT_ID('Custom_NSFPercentageByLocation','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_NSFPercentageByLocation
END
GO

CREATE PROCEDURE Custom_NSFPercentageByLocation(
	@StartDate date,
	@EndDate date,
	@LocationID int
)
AS
BEGIN

DECLARE @TotalTransactions float
DECLARE @TotalReturn int, @TotalHardReturn int, @TotalSoftReturn int
DECLARE @PercentReturn float, @PercentHardReturn float, @PercentSoftreturn float

SET @TotalTransactions = ( SELECT CONVERT(float,COUNT(*)) FROM Receipts as r 
INNER JOIN Clients AS c
	ON r.ClientID = c.ClientID  WHERE CONVERT(date,r.DateReceived) >= @StartDate AND CONVERT(date,r.DateReceived) <= @EndDate ) AND c.LocationID = @LocationID

SET @TotalReturn = ( SELECT COUNT(*) FROM Receipts as r 
INNER JOIN Clients AS c
	ON r.ClientID = c.ClientID WHERE r.NSF = 1 AND CONVERT(date,r.DateReceived) >= @StartDate AND CONVERT(date,r.DateReceived) <= @EndDate ) AND c.LocationID = @LocationID
	
SET @TotalHardReturn = ( SELECT COUNT(*) FROM Receipts as r 
INNER JOIN Clients AS c
	ON r.ClientID = c.ClientID WHERE r.NSF = 1 AND r.NSFReason IN ( 'INELIGIBLE', 'NOT AUTHORIZED', 'PAYMENT STOPPED', 'PYMT REFUS', 'REVOKED', 'STOP PAY', 'UNAUTH CORP' ) AND CONVERT(date,r.DateReceived) >= @StartDate AND CONVERT(date,r.DateReceived) <= @EndDate ) AND c.LocationID = @LocationID
	
SET @TotalSoftReturn = ( SELECT COUNT(*) FROM Receipts as r 
INNER JOIN Clients AS c
	ON r.ClientID = c.ClientID WHERE r.NSF = 1 AND r.NSFReason NOT IN ( 'INELIGIBLE', 'NOT AUTHORIZED', 'PAYMENT STOPPED', 'PYMT REFUS', 'REVOKED', 'STOP PAY', 'UNAUTH CORP' ) AND CONVERT(date,r.DateReceived) >= @StartDate AND CONVERT(date,r.DateReceived) <= @EndDate ) AND c.LocationID = @LocationID

SET @PercentReturn = ( SELECT CONVERT(float,@TotalReturn) / @TotalTransactions )
SET @PercentHardReturn = ( SELECT CONVERT(float,@TotalHardReturn) / @TotalTransactions )
SET @PercentSoftReturn = ( SELECT CONVERT(float,@TotalSoftReturn) / @TotalTransactions )

SELECT @TotalTransactions AS 'TotalTransactions', @TotalReturn AS 'TotalReturn', @PercentReturn AS 'PercentReturn', @TotalHardReturn AS 'TotalHardReturn', @PercentHardReturn AS 'PercentHardReturn', @TotalSoftReturn AS 'TotalSoftReturn', @PercentSoftReturn AS 'PercentSoftReturn'

END
GO