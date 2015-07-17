IF OBJECT_ID('Custom_NSFsByDate','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_NSFsByDate
END
GO

CREATE PROCEDURE Custom_NSFsByDate(
	@StartDate date,
	@EndDate date
)
AS
BEGIN

SELECT CONVERT(date,DateReceived) AS 'DateReceived', COUNT(ReceiptID) AS 'NumNSFs'
FROM Receipts
WHERE NSF = 1
AND CONVERT(date,DateReceived) >= @StartDate
AND CONVERT(date,DateReceived) <= @EndDate
GROUP BY CONVERT(date,DateReceived)
ORDER BY CONVERT(date,DateReceived) DESC

END
GO