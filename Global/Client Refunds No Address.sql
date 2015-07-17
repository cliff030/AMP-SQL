IF OBJECT_ID('Custom_ClientRefundsNoAddress','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_ClientRefundsNoAddress
END
GO

CREATE PROCEDURE Custom_ClientRefundsNoAddress
AS
BEGIN

SELECT c.ClientID, cks.CheckID, cks.Amount, CONVERT(date,cks.DateCreated) AS 'DateCreated', c.ClientStatus, CONVERT(date,c.DateClose) AS 'DateClose'
FROM Checks AS cks
INNER JOIN Payments AS p
	ON p.CheckID = cks.CheckID
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
WHERE cks.Reconciled = 0 
AND cks.Voided = 0
AND cks.Cleared = 0
AND p.AccountNumber = 'CLIENT REFUND'
AND cks.BankAccountID = 0
AND c.Address1CommunicationDoNotUse = 1

END
GO