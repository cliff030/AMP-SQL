IF OBJECT_ID('Custom_MonthlySettlementReport','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_MonthlySettlementReport
END
GO

CREATE PROCEDURE Custom_MonthlySettlementReport	(
	@StartDate date,
	@EndDate date,
	@NoLock int = 1
)
AS
BEGIN

IF @NoLock = 1
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
END

SELECT CONVERT(date,ccn.ProcessedOn) AS 'Date',
cc.ClientID,
CONVERT(date,c.DateStart) AS 'EnrollmentDate',
c.LastName,
c.FirstName,
ccn.OrigDebtAtTimeOfNegotiation AS 'OriginalBalance',
ccn.BalanceAtTimeOfNegotiation AS 'CurrentBalance',
ccn.OfferAmount AS 'SettlementAmount',
CAST((ccn.OrigDebtAtTimeOfNegotiation - ccn.OfferAmount) AS money) AS 'Savings',
CAST( ( CAST( (ccn.OrigDebtAtTimeOfNegotiation - ccn.OfferAmount) AS money) / cc.OrigDebt ) AS decimal(5,2) ) AS 'Percentage',
u.FullName AS 'Negotiator',
l.LocationName AS 'Location',
cc.CreditorAlias
FROM ClientCredNegotiation AS ccn
INNER JOIN ClientCred AS cc
	ON ccn.ClientCredID = cc.ClientCredID
INNER JOIN ezy_users AS u
	ON u.UserID = ccn.UserID
INNER JOIN Clients AS c
	ON cc.ClientID = c.ClientID
INNER JOIN Locations AS l
	ON c.LocationID = l.LocationID
WHERE ccn.Approved = 1 
AND ccn.Cancelled <> 1 
AND ccn.Processed = 1
AND CONVERT(date,ccn.ProcessedOn) >= @StartDate 
AND CONVERT(date,ccn.ProcessedOn) < @EndDate
ORDER BY 'Date' ASC

END
GO