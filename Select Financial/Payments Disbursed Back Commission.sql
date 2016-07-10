IF OBJECT_ID('Custom_PaymentsDisbursedBackCommission') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_PaymentsDisbursedBackCommission
END
GO

CREATE PROCEDURE Custom_PaymentsDisbursedBackCommission
(
	@StartDate date,
	@EndDate date
)
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @StartOfNextDayEndDate date
SET @StartOfNextDayEndDate = CONVERT(date,dbo.StartOfNextDay(@EndDate))

SELECT CONVERT(varchar, SUM(BackCommissionSplits.BackCommission),1) as BackCommmissionTotal
FROM
(SELECT
  CONVERT(MONEY,(Case When SUM(Case
WHEN (cc.CreditorAlias LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
ELSE cc.OrigDebt END) >= 500 AND SUM(Case
WHEN (cc.CreditorAlias LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
ELSE cc.OrigDebt END) <= 15000 THEN p.Amount * 0.50 WHEN SUM(Case
WHEN (cc.CreditorAlias LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
ELSE cc.OrigDebt END) >= 15001 AND SUM(Case
WHEN (cc.CreditorAlias LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
ELSE cc.OrigDebt END) <= 25000 THEN p.Amount * 0.45 WHEN SUM(Case
WHEN (cc.CreditorAlias LIKE '%Settlement Fee%' OR cc.CreditorAlias LIKE '%CLIENT REFUND%' OR cc.CreditorAlias LIKE '%Select Financial Services%') THEN 0
ELSE cc.OrigDebt END) >= 25001 THEN p.amount * 0.40 ELSE 0 END)) As BackCommission

FROM dbo.Checks AS cks
INNER JOIN dbo.Payments AS p
ON p.CheckID = cks.CheckID AND p.BankAccountID = cks.BankAccountID
INNER JOIN dbo.Clients AS c
ON c.ClientID = p.ClientID
INNER JOIN dbo.Locations AS l
ON c.LocationID = l.LocationID
INNER JOIN dbo.Creditors AS cred
ON cks.CreditorID = cred.CreditorID
INNER JOIN dbo.BankAccounts AS ba
ON ba.BankAccountID = cks.BankAccountID
INNER JOIN dbo.ClientCred AS cc
ON cc.ClientID = c.ClientID
WHERE cks.Voided = 0 AND
((p.ClientID >= 7000000 AND p.ClientID <= 7999999) OR p.ClientID IN (208659,208704, 208807, 208815, 208820, 208890, 208899, 208900, 208907, 208929,208995,208007, 209076, 209086, 209120, 209134, 209154))
AND cks.CheckRunID IN (
SELECT CheckRunID
FROM dbo.CheckRun
WHERE dbo.StartOfDay(CheckRunDate) >= dbo.StartOfDay('2016-06-01 00:00:00')
AND dbo.StartOfDay(CheckRunDate) <= dbo.StartOfDay('2016-06-30 00:00:00')
)
AND cred.CreditorID = 4
GROUP BY p.amount) AS BackCommissionSplits

END
GO