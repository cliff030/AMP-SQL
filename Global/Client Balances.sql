--select * from creditors where creditorid not in (0,2,3,4)
-- select * from clientcred

SELECT c.LastName, c.FirstName, c.SSN, cred.Balance, cred.AccountNumber, cred.CreditorAlias, c.ClientID
FROM Clients AS c
INNER JOIN ClientCred AS cred
	ON c.ClientID = cred.ClientID
WHERE c.Active = 1
AND cred.CreditorID NOT IN (0,2,3,4)
AND c.ClientID <> 3
ORDER BY c.ClientID, cred.Balance ASC