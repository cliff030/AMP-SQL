IF OBJECT_ID('Custom_PaymentsPrintedByLocation') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_PaymentsPrintedByLocation
END
GO

CREATE PROCEDURE Custom_PaymentsPrintedByLocation(
	@StartDate date,
	@EndDate date,
	@LocationID int
)
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @StartOfNextDayEndDate date
SET @StartOfNextDayEndDate = CONVERT(date,dbo.StartOfNextDay(@EndDate))

SELECT	CRED.CreditorType, SUM(P.Amount) AS NET, SUM (CASE WHEN P.TYPE = 1 THEN P.Amount ELSE 0 END) AS FSCOLLECTED, 
	SUM(CASE WHEN P.TYPE = 2 THEN P.Amount ELSE 0 END) AS MONTHLYCONTRIB, SUM(CASE WHEN P.TYPE = 3 THEN P.Amount ELSE 0 END) AS FSDEDUCTED,
	SUM(CASE WHEN P.TYPE = 4 THEN P.Amount ELSE 0 END) AS GROSSPMT
FROM	Checks CKS
	INNER JOIN Payments P ON CKS.CheckID = P.CheckID AND CKS.BankAccountID = P.BankAccountID
	INNER JOIN Clients AS c ON c.ClientID = P.ClientID
	LEFT JOIN Creditors CRED on CKS.CreditorID = CRED.CreditorID
WHERE	CONVERT(date,CKS.DateCreated) >= @StartDate
	AND CONVERT(date,CKS.DateCreated) < @StartOfNextDayEndDate
	AND c.LocationID = @LocationID
GROUP BY CRED.CreditorType

END
GO