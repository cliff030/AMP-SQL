IF OBJECT_ID('Custom_PaymentsUnprintedCFF') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_PaymentsUnprintedCFF
END
GO

CREATE PROCEDURE Custom_PaymentsUnprintedCFF
(
	@StartDate date,
	@EndDate date
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
	AND ((c.ClientID >= 7000000 AND c.ClientID <= 7999999) OR c.ClientID IN (208659,208704, 208807, 208815, 208820, 208890, 208899, 208900, 208907, 208929,208995,208007, 209076, 209086, 209120, 209134, 209154)) 
GROUP BY CRED.CreditorType

END
GO