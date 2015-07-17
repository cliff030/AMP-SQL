CREATE PROCEDURE Custom_NSFReport (
	@StartDate datetime,
	@EndDate datetime
)
AS
BEGIN
SELECT cv.ClientID, 
cl.Lastname,
cl.Firstname,
COUNT(cv.rowid) AS 'Number of Transactions', 
(
	SELECT 
	COUNT(rowid) 
	FROM Custom_ClientTransactions AS c 
	WHERE c.ClientID = cv.ClientID 
	AND NSF = 1 
	AND dbo.StartOfDay(postdate) >=  @StartDate
	AND dbo.StartOfDay(postdate) < @EndDate
) AS 'Number of NSFs',
CAST( 
( 
	CAST( 
	( 
		SELECT 
		COUNT(rowid) 
		FROM Custom_ClientTransactions AS c 
		WHERE c.ClientID = cv.ClientID 
		AND NSF = 1 
		AND dbo.StartOfDay(postdate) >= @StartDate
		AND dbo.StartOfDay(postdate) < @EndDate 
	)
	AS decimal(9,2) ) 
) / CAST( COUNT(rowid) AS decimal(9,2) ) * 100 AS decimal(9,2) 
) AS 'NSF%',
cl.ClientStatus AS 'Client Status'
FROM Custom_ClientTransactions AS cv
INNER JOIN Clients AS cl
	ON cl.ClientID = cv.ClientID
WHERE dbo.StartOfDay(postdate) >= @StartDate 
AND dbo.StartOfDay(postdate) < @EndDate
GROUP BY cv.ClientID, cl.LastName, cl.FirstName, cl.ClientStatus
ORDER BY 'NSF%' DESC
END