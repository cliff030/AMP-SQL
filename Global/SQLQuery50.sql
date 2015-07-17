-- select checkrunid from checks where startcheck = 807

select cr.checkrunid
from checkrun as cr
inner join checks as chk
on chk.checkrunid = cr.checkrunid
where cr.startcheck = 807

SELECT cl.clientid
FROM Checks AS c
INNER JOIN CheckRun AS cr
	ON cr.CheckRunID = c.CheckRunID
INNER JOIN Creditors  AS cred
	ON c.CreditorID = cred.CreditorID
INNER JOIN ClientCred AS clcr
	ON clcr.CreditorID = cred.CreditorID
INNER JOIN Clients AS cl
	ON cl.ClientID = clcr.ClientID
WHERE
	clcr.AccountNumber = 'CLIENT REFUND'
	AND cr.CheckRunID = 596