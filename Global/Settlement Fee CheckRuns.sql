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
SELECT p.ClientID, c.DateStart AS 'Enrollment Date', c.WholeName AS 'Client Name', c.State, p.Created AS 'Date Created', p.Amount, 
 	Case When ((p.ClientID >= 7000000 AND p.ClientID <= 7999999) OR p.ClientID IN (208659,208704, 208807, 208815, 208820, 208890, 208899, 208900, 208907, 208929,208995,208007, 209076, 209086, 209120, 209134, 209154)) THEN CONVERT(varchar, CONVERT(MONEY,(Case When SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) >= 500 AND SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) <= 15000 THEN p.Amount * 0.50 WHEN SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) >= 15001 AND SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) <= 25000 THEN p.Amount * 0.45 WHEN SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) >= 25001 THEN p.amount * 0.40 ELSE 0 END)),1) ELSE 'N/A' END As  'Front Commission', 
	
	Case When ((p.ClientID >= 7000000 AND p.ClientID <= 7999999) OR p.ClientID IN (208659,208704, 208807, 208815, 208820, 208890, 208899, 208900, 208907, 208929,208995,208007, 209076, 209086, 209120, 209134, 209154)) THEN CONVERT(varchar,p.amount -  CONVERT(MONEY,(Case When SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) >= 500 AND SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) <= 15000 THEN p.Amount * 0.50 WHEN SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) >= 15001 AND SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) <= 25000 THEN p.Amount * 0.45 WHEN SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) >= 25001 THEN p.amount * 0.40 ELSE 0 END)),1) ELSE 'N/A' END AS 'Back Commissions', l.LocationName AS 'Location', ba.Name AS 'Bank', cks.CheckID, cred.CreditorID, 
cred.Name AS 'Creditor Name', 
SUM(Case 
	WHEN (cc.CreditorAlias  LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
	ELSE cc.OrigDebt END) AS DebtLoad
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
INNER JOIN ClientCred AS cc
ON cc.ClientID = c.ClientID
WHERE cks.Voided = 0
AND cks.CheckRunID IN (
SELECT CheckRunID
FROM CheckRun
WHERE dbo.StartOfDay(CheckRunDate) >= dbo.StartOfDay(@StartDate)
AND dbo.StartOfDay(CheckRunDate) <= dbo.StartOfDay(@EndDate)
)
AND cred.CreditorID = 4
GROUP BY p.clientID, c.DateStart, c.WholeName, c.State, p.Created, p.Amount,l.LocationID, l.LocationName, ba.name, cks.CHeckID, cred.CreditorID, cred.Name
ORDER BY p.ClientID DESC
END
GO