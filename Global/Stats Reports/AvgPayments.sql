-- AvgPayments
-- Returns the average payment amount for all clients

ALTER FUNCTION Custom_AvgPayment(
	@StartDate date,
	@EndDate date
) RETURNS money
AS
BEGIN
DECLARE @AvgPayment money
SET @AvgPayment = (SELECT CONVERT(money,ISNULL(AVG(ach.Amount),0) )
FROM ACHBatchDetails AS ach
INNER JOIN Clients AS c 
	ON ach.ClientID = c.ClientID
INNER JOIN ACHBatch AS achb
ON achb.ACHBatchID = ach.ACHBatchID
WHERE ach.status IS NULL
AND CONVERT(date,achb.BatchDate) >= CONVERT(date,c.DateStart)
AND CONVERT(date,c.DateEntered) >= @StartDate
AND CONVERT(date,c.DateEntered) <= @EndDate
)

RETURN @AvgPayment
END