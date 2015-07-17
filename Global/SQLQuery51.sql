SELECT cl.ClientID, c.CheckID, cr.CheckRunID, 'Client' AS RecipientType, 'Mail' AS  'SendMethod'
FROM Checks AS c
INNER JOIN CheckRun AS cr
	ON cr.CheckRunID = c.CheckRunID
INNER JOIN Creditors  AS cred
	ON c.CreditorID = cred.CreditorID
INNER JOIN ClientCred AS clcr
	ON clcr.CreditorID = cred.CreditorID
INNER JOIN Clients AS cl
	ON cl.ClientID = clcr.ClientID
WHERE cr.CheckRunDate >= dbo.StartofDay(GETDATE()) 
	AND cr.CheckRunDate <= dbo.StartofNextDay(DATEADD(day,1,GETDATE()))
	AND clcr.AccountNumber = 'CLIENT REFUND'
ORDER BY cl.ClientID