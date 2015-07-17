ALTER PROCEDURE Custom_ACHMoneyReport 
AS
BEGIN

	CREATE TABLE #Custom_ACHMoneyReport ( 
		Amount money,
		BatchDate datetime,
		ACHGroupID int
	)

	INSERT INTO #Custom_ACHMoneyReport (
		Amount, BatchDate,ACHGroupID
	)
	(
		SELECT r.ReceiptAmount,dbo.StartOfDay(a.BatchDate),a.ACHBatchGroupID 
		FROM Receipts AS r
		INNER JOIN ACHBatch AS a
			ON a.ACHBatchID = r.ACHBatchID
		WHERE dbo.StartOfDay(a.BatchDate) >= dbo.StartOfDay(DATEADD(month, -3, GETDATE()))
	)

	SELECT SUM(Amount) AS 'Total Amount',BatchDate AS 'Date',ACHGroupID 
	FROM #Custom_ACHMoneyReport
	GROUP BY ACHGroupID,BatchDate
	ORDER BY ACHGroupID DESC
END