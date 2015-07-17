IF OBJECT_ID('Custom_AdvanceWithoutRepayments','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_AdvanceWithoutRepayments
END
GO

CREATE PROCEDURE Custom_AdvanceWithoutRepayments
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @CreditorID int

IF ( SELECT DB_NAME() ) = 'CSDATA8'
BEGIN
	SET @CreditorID = 9302
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_INC'
BEGIN
	SET @CreditorID = 9527
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_FFN'
BEGIN
	SET @CreditorID = 11054
END
ELSE IF ( SELECT DB_NAME() ) = 'CSDATA8_KAR'
BEGIN
	SET @CreditorID = 10915
END
ELSE
BEGIN
	SET @CreditorID = 9302
END


SELECT c.ClientID, c.LastName, c.FirstName, SUM(r.ReceiptAmount) AS 'Amount Advanced', MAX(r.DateReceived) AS 'Latest Advance Date', c.ClientStatus FROM Clients AS c
INNER JOIN Receipts AS r
	ON r.ClientID = c.ClientID
WHERE r.PaymentType = 'ADVANCE' AND r.ClientID NOT IN 
( SELECT DISTINCT r.ClientID FROM Receipts AS r
INNER JOIN ClientCred AS cc
	ON cc.ClientID = r.ClientID AND cc.CreditorID = @CreditorID
LEFT JOIN Payments AS p
	ON p.ClientID = r.ClientID AND p.CreditorID = @CreditorID	
INNER JOIN ProgramPayments as prop
	ON prop.ClientCredID = cc.ClientCredID
WHERE r.PaymentType = 'ADVANCE'
)
GROUP BY c.ClientID, c.LastName, c.FirstName, c.ClientStatus
ORDER BY SUM(r.ReceiptAmount) DESC

END
GO