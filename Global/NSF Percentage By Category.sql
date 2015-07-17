ALTER PROCEDURE Custom_NSFPercentagesByCategroy(
	@StartDate date,
	@EndDate date
)
AS
BEGIN
DECLARE @TotalNSFs float

SET @TotalNSFs = ( SELECT CONVERT(float,COUNT(*)) FROM Receipts WHERE CONVERT(date,DateReceived) >= @StartDate AND CONVERT(date,DateReceived) <= @EndDate AND NSF = 1 )

SELECT COUNT(ReceiptID) AS 'NSFCount', (COUNT(ReceiptID) / @TotalNSFs) AS 'NSFPercentage', NSFReason 
FROM Receipts 
WHERE NSF = 1
AND CONVERT(date,DateReceived) >= @StartDate
AND CONVERT(date,DateReceived) <= @EndDate
GROUP BY NSFReason 
ORDER BY NSFReason

END