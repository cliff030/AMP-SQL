ALTER PROCEDURE Custom_ACHReport 
AS
BEGIN

	CREATE TABLE #Custom_ACHReportTable ( 
		ClientID int,
		BatchDate datetime,
		ACHGroupID int
	)

	INSERT INTO #Custom_ACHReportTable (
		ClientID, BatchDate,ACHGroupID
	)
	(
		SELECT r.ClientID,dbo.StartOfDay(a.BatchDate),a.ACHBatchGroupID 
		FROM Receipts AS r
		INNER JOIN ACHBatch AS a
			ON a.ACHBatchID = r.ACHBatchID
		WHERE dbo.StartOfDay(a.BatchDate) >= dbo.StartOfDay(DATEADD(month, -6, GETDATE()))
	)

	SELECT COUNT(ClientID) AS 'Number of Clients',BatchDate AS 'Date',ACHGroupID 
	FROM #Custom_ACHReportTable
	GROUP BY ACHGroupID,BatchDate
	ORDER BY BatchDate DESC
END