IF OBJECT_ID('Custom_RecCheck','P') IS NOT NULL
BEGIN
	DROP PROCEDURE Custom_RecCheck
END
GO

CREATE PROCEDURE Custom_RecCheck(
	@ClientID int,
	@Amount money,
	@CreditorID int = NULL
)
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF @CreditorID IS NULL
BEGIN

SELECT ck.CheckID, cr.Name, cr.CreditorID, CONVERT(date,ck.DateCreated) AS DateCreated, p.Amount, CONVERT(date,ck.DateCleared) AS DateCleared
FROM Payments AS p 
INNER JOIN Checks AS ck
	ON ck.CheckID = p.CheckID
INNER JOIN Creditors AS cr
	ON cr.CreditorID = ck.CreditorID
WHERE p.ClientID = @ClientID 
AND p.Amount = ABS(@Amount) 
AND ck.Voided = 0
AND ck.CreditorID NOT IN (0,3,4,9302)
ORDER BY ck.DateCreated ASC

END

ELSE
BEGIN
SELECT ck.CheckID, cr.Name, cr.CreditorID, CONVERT(date,ck.DateCreated) AS DateCreated, p.Amount, CONVERT(date,ck.DateCleared) AS DateCleared
FROM Payments AS p 
INNER JOIN Checks AS ck
	ON ck.CheckID = p.CheckID
INNER JOIN Creditors AS cr
	ON cr.CreditorID = ck.CreditorID
WHERE p.ClientID = @ClientID 
AND p.Amount = ABS(@Amount) 
AND ck.Voided = 0
AND ck.CreditorID = @CreditorID
ORDER BY ck.DateCreated ASC
END

END
GO