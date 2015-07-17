IF OBJECT_ID('Custom_PaymentsUnprintedByLocation') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_PaymentsUnprintedByLocation
END
GO

CREATE PROCEDURE Custom_PaymentsUnprintedByLocation
(
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
FROM	Payments P 
INNER JOIN Clients AS c
	ON c.ClientID = P.ClientID
	LEFT JOIN Creditors CRED on P.CreditorID = CRED.CreditorID
WHERE	CONVERT(date,P.Created) >= @StartDate
	AND CONVERT(date,P.Created) < @StartOfNextDayEndDate
	AND P.CheckID = 0
	AND c.LocationID = @LocationID
GROUP BY CRED.CreditorType

END
GO