ALTER PROCEDURE Custom_ClientCancelBeforeSettlement
AS
BEGIN
SELECT DISTINCT c.ClientID, c.LastName, c.FirstName, c.DateStart, c.DateClose, c.ClientStatus, c.CloseReason
FROM Clients AS c
INNER JOIN ClientCred AS ccr
	ON ccr.ClientID = c.ClientID
WHERE c.ClientStatus = 'CANCEL'
AND c.ClientID NOT IN (
	SELECT ccr1.ClientID
	FROM ClientCredNegotiation AS ccn1
	INNER JOIN ClientCred AS ccr1
		ON ccr1.ClientCredID = ccn1.ClientCredID
	WHERE ccn1.Approved = 1 
	AND ccn1.Cancelled = 0

	UNION

	SELECT ccr1.ClientID
	FROM ClientCredNegotiation AS ccn1
	INNER JOIN ClientCred AS ccr1
		ON ccr1.ClientCredID = ccn1.ClientCredID
	INNER JOIN Clients AS c
		ON c.ClientID = ccr1.ClientID
	WHERE c.ClientStatus = 'CANCEL'
	AND c.DateClose < ccn1.ProcessedOn
)
ORDER BY DateStart, DateClose
END