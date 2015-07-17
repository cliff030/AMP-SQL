ALTER PROCEDURE Custom_ACHMonthlyReport 
AS
BEGIN

	CREATE TABLE #Custom_ACHMonthlyReport ( 
		ClientID int,
		BatchDate datetime
	)

	INSERT INTO #Custom_ACHMonthlyReport (
		ClientID, BatchDate
	)
	(
		SELECT r.ClientID,dbo.DateSerial(datepart(year,dbo.StartOfDay(a.BatchDate)),DATEPART(month,dbo.StartOfDay(a.BatchDate)),1) AS 'Month'
		FROM Receipts AS r
		INNER JOIN ACHBatch AS a
			ON a.ACHBatchID = r.ACHBatchID
		WHERE dbo.StartOfDay(a.BatchDate) >= dbo.StartOfDay(DATEADD(month, -6, GETDATE()))
	)

	SELECT COUNT(ClientID) AS 'Number of Clients',BatchDate AS 'Date'
	FROM #Custom_ACHMonthlyReport
	GROUP BY BatchDate
	ORDER BY BatchDate DESC
END