IF OBJECT_ID('Custom_RefundCoverLetterbyCheckRun','P') IS NOT NULL
BEGIN
DROP PROCEDURE [dbo].[Custom_RefundCoverLetterbyCheckRun]
END
GO

CREATE PROCEDURE [dbo].[Custom_RefundCoverLetterbyCheckRun](
	@CheckRunID int,
	@NoLock tinyint	
)
AS
BEGIN

IF @NoLock = 1
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
END

SELECT CAST(SUM(chk.Amount) AS DECIMAL(7,2)) AS 'Amount', 
c.ClientID, 
CAST(
	(
		SELECT TOP 1 CASE WHEN (MonthlyPayment=0) THEN (CASE WHEN (DATEDIFF(ss,(select convert(date,dateentered) FROM clients where clientid = c.ClientID),'2011-11-01') > 0) then 10.00 else 20.00 end) else MonthlyPayment end FROM ClientCred WHERE ClientID = c.ClientID AND CreditorID = 0 ORDER BY MonthlyPayment DESC
) AS DECIMAL(4,2)) 
AS 'MonthlyServiceCharge',
CAST(9.95 AS DECIMAL(4,2)) AS 'BankSetupFee',
c.LastName AS ClientLastName, 
c.FirstName AS ClientFirstName, 
co.CoAppLast AS CoAppLastName, 
co.CoAppFirst AS CoAppFirstName, 
c.Address1 AS 'ClientAddress1', 
c.Address2 AS 'ClientAddress2', 
c.City AS 'ClientCity', 
c.State AS 'ClientState', 
c.Zip AS 'ClientZip'
FROM Checks AS chk
INNER JOIN Payments AS p
	ON p.CheckID = chk.CheckID
INNER JOIN CheckRun AS cr
	ON cr.CheckRunID = chk.CheckRunID
INNER JOIN Creditors  AS cred
	ON chk.CreditorID = cred.CreditorID
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
LEFT OUTER JOIN CoApps AS co
	ON c.ClientID = co.ClientID
WHERE p.AccountNumber = 'CLIENT REFUND'
	AND cr.CheckRunID = @CheckRunID
GROUP BY c.ClientID, c.FirstName, c.LastName, co.CoAppLast, co.CoAppFirst, c.Address1, c.Address2, c.City, c.State, c.Zip
ORDER BY c.ClientID
END
GO


