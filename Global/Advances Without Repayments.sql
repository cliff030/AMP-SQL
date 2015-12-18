IF OBJECT_ID('Custom_AdvanceWithoutRepayments','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_AdvanceWithoutRepayments
END
GO

CREATE PROCEDURE Custom_AdvanceWithoutRepayments
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE TABLE #Custom_Creditors(
	CreditorID int
)

IF ( SELECT DB_NAME() ) = 'CSDATA8'
BEGIN
	INSERT INTO #Custom_Creditors VALUES (9302)
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_INC'
BEGIN
	INSERT INTO #Custom_Creditors VALUES (9527)
	INSERT INTO #Custom_Creditors VALUES (125465)
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_FFN'
BEGIN
	INSERT INTO #Custom_Creditors VALUES (11054)
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_KAR'
BEGIN
	INSERT INTO #Custom_Creditors VALUES (10915)
END
ELSE
BEGIN
	INSERT INTO #Custom_Creditors VALUES (9302)
END


SELECT c.ClientID, c.LastName, c.FirstName, SUM(r.ReceiptAmount) AS 'Amount Advanced', MAX(r.DateReceived) AS 'Latest Advance Date', c.ClientStatus FROM Clients AS c
INNER JOIN Receipts AS r
	ON r.ClientID = c.ClientID
WHERE r.PaymentType = 'ADVANCE' AND r.ClientID NOT IN 
( SELECT DISTINCT r.ClientID FROM Receipts AS r
INNER JOIN ClientCred AS cc
	ON cc.ClientID = r.ClientID 
LEFT JOIN Payments AS p
	ON p.ClientID = r.ClientID 
INNER JOIN ProgramPayments as prop
	ON prop.ClientCredID = cc.ClientCredID
WHERE r.PaymentType = 'ADVANCE'
AND cc.CreditorID IN (SELECT * FROM #Custom_Creditors)
)
GROUP BY c.ClientID, c.LastName, c.FirstName, c.ClientStatus
ORDER BY SUM(r.ReceiptAmount) DESC

END
GO