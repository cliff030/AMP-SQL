IF OBJECT_ID('Custom_DocIsSent') IS NOT NULL
BEGIN
	DROP FUNCTION Custom_DocIsSent
END
GO

CREATE FUNCTION Custom_DocIsSent(
	@StartDate date,
	@EndDate date
) RETURNS @ClientList table(ClientID int)
AS
BEGIN

SET @EndDate = DATEADD(day,1,@EndDate)

INSERT INTO @ClientList ( ClientID )
(
	select distinct dbr.ClientID
	from DocumentBatchDetails
	inner join DocumentBatch as db
		on db.DocumentBatchID = DocumentBatchDetails.DocumentBatchID
	inner join DataSource as ds
		on ds.DataSourceID = db.DataSourceID
	inner join DocumentBatchRun as dbr
		ON dbr.DocumentBatchID = db.DocumentBatchID
	inner join receipts as r
		on r.ClientID = dbr.ClientID AND r.NSF = 1
	where ds.Name = 'AMP - NSF Letter Email'
	AND db.BatchCompletedOn IS NOT NULL
	AND 
	(
		db.BatchCompletedOn >= @StartDate
		AND db.BatchCompletedOn <= @EndDate
	)
	AND r.NSFDate > db.BatchCompletedOn
	AND dbr.ClientID IS NOT NULL
	AND dbr.Status = 1
)

RETURN

END