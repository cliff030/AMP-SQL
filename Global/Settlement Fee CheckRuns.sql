IF OBJECT_ID('Custom_SettlementFeeCheckRuns') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_SettlementFeeCheckRuns
END
GO

CREATE PROCEDURE Custom_SettlementFeeCheckRuns (
	@StartDate datetime,
	@EndDate datetime
)
AS
BEGIN
SELECT p.ClientID, c.DateStart AS 'Enrollment Date', c.WholeName AS 'Client Name', c.State, p.Created AS 'Date Created', p.Amount, l.LocationName AS 'Location', ba.Name AS 'Bank', cks.CheckID, cred.CreditorID, cred.Name AS 'Creditor Name'
FROM Checks AS cks
INNER JOIN Payments AS p
	ON p.CheckID = cks.CheckID AND p.BankAccountID = cks.BankAccountID   
INNER JOIN Clients AS c
	ON c.ClientID = p.ClientID
INNER JOIN Locations AS l
	ON c.LocationID = l.LocationID 
INNER JOIN Creditors AS cred     
	ON cks.CreditorID = cred.CreditorID
INNER JOIN BankAccounts AS ba
	ON ba.BankAccountID = cks.BankAccountID
WHERE cks.Voided = 0 
AND cks.CheckRunID IN (
	SELECT CheckRunID 
	FROM CheckRun
	WHERE dbo.StartOfDay(CheckRunDate) >= dbo.StartOfDay(@StartDate)
	AND dbo.StartOfDay(CheckRunDate) <= dbo.StartOfDay(@EndDate)
)  
AND cred.Name = 'Settlement Fee'     
ORDER BY Created ASC
END
GO