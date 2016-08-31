IF OBJECT_ID('Custom_NSFPercentagesByCategoryAndLocation','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_NSFPercentagesByCategoryAndLocation
END
GO

CREATE PROCEDURE Custom_NSFPercentagesByCategoryAndLocation(
	@StartDate date,
	@EndDate date,
	@LocationID int
)
AS
BEGIN
DECLARE @TotalNSFs float

SET @TotalNSFs = ( SELECT CONVERT(float,COUNT(*)) FROM Receipts as r 
INNER JOIN Clients AS c
	ON r.ClientID = c.ClientID WHERE CONVERT(date,r.DateReceived) >= @StartDate AND CONVERT(date,r.DateReceived) <= @EndDate AND c.LocationID = @LocationID AND r.NSF = 1 )

SELECT COUNT(r.ReceiptID) AS 'NSFCount', (COUNT(r.ReceiptID) / @TotalNSFs) AS 'NSFPercentage', r.NSFReason 
FROM Receipts as r 
INNER JOIN Clients AS c
	ON r.ClientID = c.ClientID
WHERE r.NSF = 1
AND CONVERT(date,r.DateReceived) >= @StartDate
AND CONVERT(date,r.DateReceived) <= @EndDate
AND c.LocationID = @LocationID
GROUP BY r.NSFReason 
ORDER BY r.NSFReason

END


