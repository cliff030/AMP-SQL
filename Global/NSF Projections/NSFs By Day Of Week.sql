IF OBJECT_ID('Custom_NSFsByDayOfWeek','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_NSFsByDayOfWeek
END
GO

CREATE PROCEDURE Custom_NSFsByDayOfWeek(
	@StartDate date,
	@EndDate date
)
AS
BEGIN

SELECT DATEPART(dw,DateReceived) AS 'DayOfWeek', COUNT(ReceiptID) AS 'NumNSFs'
FROM Receipts
WHERE NSF = 1
AND CONVERT(date,DateReceived) >= @StartDate
AND CONVERT(date,DateReceived) <= @EndDate
GROUP BY DATEPART(dw,DateReceived)
ORDER BY DATEPART(dw,DateReceived) ASC

END
GO