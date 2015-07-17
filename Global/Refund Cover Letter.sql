ALTER PROCEDURE Custom_RefundCoverLetter(
	@ClientID int,
	@CheckRunID int,
	@NoLock tinyint	
)
AS
BEGIN

IF @NoLock = 1
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
END

SELECT CAST(SUM(c.Amount) AS DECIMAL(7,2)) AS 'Amount', cl.FirstName, cl.LastName
FROM Checks AS c
INNER JOIN CheckRun AS cr
	ON cr.CheckRunID = c.CheckRunID
INNER JOIN Creditors  AS cred
	ON c.CreditorID = cred.CreditorID
INNER JOIN ClientCred AS clcr
	ON clcr.CreditorID = cred.CreditorID
INNER JOIN Clients AS cl
	ON cl.ClientID = clcr.ClientID
WHERE cl.ClientID = @ClientID
	AND clcr.AccountNumber = 'CLIENT REFUND'
	AND cr.CheckRunID = @CheckRunID
GROUP BY cl.ClientID, cl.FirstName, cl.LastName
ORDER BY cl.ClientID
END